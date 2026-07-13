//
//  BatchingAnalytics.swift
//  AppServices
//
//  Created by AnhPT on 13/07/2026.
//

import Foundation

/// Uploads a batch of events to a backend. Throw to signal a **transient** failure
/// (e.g. offline / 5xx): the events stay queued and retry on the next flush.
public protocol AnalyticsUploader: Sendable {
    func upload(_ events: [AnalyticsEvent]) async throws
}

/// Buffers analytics events and uploads them in batches, keeping unsent events in
/// an in-memory queue so a failed upload (offline, server error) retries later
/// instead of dropping data.
///
/// - Events flush automatically once the queue reaches `batchSize`; call
///   ``flush()`` on background/foreground transitions to drain the rest.
/// - The queue is capped at `maxQueueSize`; when full, the **oldest** events are
///   dropped so the newest are always kept.
///
/// ```swift
/// let analytics = BatchingAnalytics(uploader: myUploader, batchSize: 20)
/// await analytics.log(.documentExported(pages: 3))
/// // …on scenePhase .background:
/// await analytics.flush()
/// ```
public actor BatchingAnalytics {
    private let uploader: AnalyticsUploader
    private let batchSize: Int
    private let maxQueueSize: Int

    private var queue: [AnalyticsEvent] = []
    private var isFlushing = false

    public init(uploader: AnalyticsUploader, batchSize: Int = 20, maxQueueSize: Int = 500) {
        self.uploader = uploader
        self.batchSize = max(1, batchSize)
        self.maxQueueSize = max(batchSize, maxQueueSize)
    }

    /// Number of events waiting to be uploaded.
    public var pendingCount: Int { queue.count }

    /// Enqueue an event, auto-flushing once a full batch has accumulated.
    public func log(_ event: AnalyticsEvent) async {
        queue.append(event)
        if queue.count > maxQueueSize {
            queue.removeFirst(queue.count - maxQueueSize)   // drop oldest
        }
        if queue.count >= batchSize {
            await flush()
        }
    }

    /// Upload queued events in batches. On the first failing batch, stops and keeps
    /// the remaining events queued for a later retry.
    ///
    /// - Returns: `true` if the queue fully drained, `false` if an upload failed.
    @discardableResult
    public func flush() async -> Bool {
        guard !isFlushing, !queue.isEmpty else { return queue.isEmpty }
        isFlushing = true
        defer { isFlushing = false }

        while !queue.isEmpty {
            let batch = Array(queue.prefix(batchSize))
            do {
                try await uploader.upload(batch)
                queue.removeFirst(batch.count)
            } catch {
                return false   // transient failure — keep the rest queued (offline)
            }
        }
        return true
    }
}
