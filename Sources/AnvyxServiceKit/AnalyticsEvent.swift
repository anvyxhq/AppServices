//
//  AnalyticsEvent.swift
//  AppServices
//
//  Created by AnhPT on 02/07/2026.
//

import Foundation

/// A structured analytics event — define a catalogue as static factory methods
/// so event names and parameters stay consistent across the app.
///
/// ```swift
/// extension AnalyticsEvent {
///     static func documentExported(pages: Int) -> AnalyticsEvent {
///         .init(name: "document_exported", parameters: ["pages": pages])
///     }
/// }
/// analytics.log(.documentExported(pages: 3))
/// ```
public struct AnalyticsEvent: Sendable {
    public let name: String
    public let parameters: [String: any Sendable]

    public init(name: String, parameters: [String: any Sendable] = [:]) {
        self.name = name
        self.parameters = parameters
    }
}

public extension AnalyticsService {
    func log(_ event: AnalyticsEvent) {
        log(event: event.name, parameters: event.parameters)
    }

    /// Time how long a block takes and log it as a duration parameter (ms).
    func measure<T>(_ name: String, _ block: () throws -> T) rethrows -> T {
        let start = DispatchTime.now()
        defer {
            let ms = Double(DispatchTime.now().uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000
            log(event: name, parameters: ["duration_ms": ms])
        }
        return try block()
    }
}
