//
//  BatchingAnalyticsTests.swift
//  AppServices
//
//  Created by AnhPT on 13/07/2026.
//

import XCTest
@testable import AnvyxServiceKit

private struct UploadFailure: Error {}

/// Records uploaded batches; can be toggled to simulate being offline.
private actor MockUploader: AnalyticsUploader {
    private(set) var batches: [[AnalyticsEvent]] = []
    private var offline = false

    func setOffline(_ value: Bool) { offline = value }
    var totalUploaded: Int { batches.reduce(0) { $0 + $1.count } }
    var uploadedNames: [String] { batches.flatMap { $0 }.map(\.name) }

    func upload(_ events: [AnalyticsEvent]) async throws {
        if offline { throw UploadFailure() }
        batches.append(events)
    }
}

final class BatchingAnalyticsTests: XCTestCase {

    private func events(_ n: Int) -> [AnalyticsEvent] {
        (0..<n).map { AnalyticsEvent(name: "e\($0)") }
    }

    func testAutoFlushesAtBatchSize() async {
        let uploader = MockUploader()
        let analytics = BatchingAnalytics(uploader: uploader, batchSize: 3)

        for event in events(3) { await analytics.log(event) }

        let pending = await analytics.pendingCount
        let total = await uploader.totalUploaded
        XCTAssertEqual(pending, 0)
        XCTAssertEqual(total, 3)
    }

    func testFailedUploadKeepsEventsQueuedAndRetries() async {
        let uploader = MockUploader()
        await uploader.setOffline(true)
        let analytics = BatchingAnalytics(uploader: uploader, batchSize: 2)

        await analytics.log(AnalyticsEvent(name: "a"))
        await analytics.log(AnalyticsEvent(name: "b"))   // triggers a flush that fails

        let queuedWhileOffline = await analytics.pendingCount
        let uploadedWhileOffline = await uploader.totalUploaded
        XCTAssertEqual(queuedWhileOffline, 2, "offline events stay queued")
        XCTAssertEqual(uploadedWhileOffline, 0)

        await uploader.setOffline(false)                 // back online
        let drained = await analytics.flush()
        let pendingAfter = await analytics.pendingCount
        let uploadedAfter = await uploader.totalUploaded
        XCTAssertTrue(drained)
        XCTAssertEqual(pendingAfter, 0)
        XCTAssertEqual(uploadedAfter, 2)
    }

    func testFlushUploadsMultipleBatches() async {
        let uploader = MockUploader()
        await uploader.setOffline(true)
        let analytics = BatchingAnalytics(uploader: uploader, batchSize: 2, maxQueueSize: 100)

        for event in events(5) { await analytics.log(event) }
        let queued = await analytics.pendingCount
        XCTAssertEqual(queued, 5)

        await uploader.setOffline(false)
        _ = await analytics.flush()

        let pendingAfter = await analytics.pendingCount
        let batchSizes = await uploader.batches.map(\.count)
        XCTAssertEqual(pendingAfter, 0)
        XCTAssertEqual(batchSizes, [2, 2, 1])
    }

    func testQueueCapDropsOldest() async {
        let uploader = MockUploader()
        await uploader.setOffline(true)
        let analytics = BatchingAnalytics(uploader: uploader, batchSize: 3, maxQueueSize: 3)

        for event in events(5) { await analytics.log(event) }   // e0…e4, all uploads fail
        let capped = await analytics.pendingCount
        XCTAssertEqual(capped, 3)

        await uploader.setOffline(false)
        _ = await analytics.flush()
        let names = await uploader.uploadedNames
        XCTAssertEqual(names, ["e2", "e3", "e4"], "oldest events are dropped when capped")
    }
}
