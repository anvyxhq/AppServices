//
//  Analytics.swift
//  AppServices
//
//  Created by AnhPT on 02/07/2026.
//

import Foundation
import OSLog

/// A vendor-agnostic analytics interface. Implement it with Firebase, Amplitude,
/// etc., and keep the rest of the app decoupled from the SDK.
public protocol AnalyticsService: Sendable {
    func log(event name: String, parameters: [String: Any])
    func setUserProperty(_ value: String?, for name: String)
    func setUserID(_ id: String?)
}

public extension AnalyticsService {
    func log(event name: String) { log(event: name, parameters: [:]) }
}

/// Default implementation that prints to the unified log — handy in DEBUG or as
/// a fallback before a real provider is wired up.
public struct ConsoleAnalytics: AnalyticsService {
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "AppServices", category: "analytics")
    public init() {}

    public func log(event name: String, parameters: [String: Any]) {
        log.debug("event: \(name) \(parameters.isEmpty ? "" : "\(parameters)")")
    }
    public func setUserProperty(_ value: String?, for name: String) {
        log.debug("userProperty: \(name) = \(value ?? "nil")")
    }
    public func setUserID(_ id: String?) {
        log.debug("userID = \(id ?? "nil")")
    }
}

/// Fan-out analytics: forwards every call to multiple providers at once.
public struct CompositeAnalytics: AnalyticsService {
    private let providers: [AnalyticsService]
    public init(_ providers: [AnalyticsService]) { self.providers = providers }

    public func log(event name: String, parameters: [String: Any]) {
        providers.forEach { $0.log(event: name, parameters: parameters) }
    }
    public func setUserProperty(_ value: String?, for name: String) {
        providers.forEach { $0.setUserProperty(value, for: name) }
    }
    public func setUserID(_ id: String?) {
        providers.forEach { $0.setUserID(id) }
    }
}
