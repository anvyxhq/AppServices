//
//  FeatureFlags.swift
//  AppServices
//
//  Created by AnhPT on 02/07/2026.
//

import Foundation

/// A vendor-agnostic remote-config / feature-flag interface. Back it with
/// Firebase Remote Config, a JSON endpoint, or the bundled default provider.
public protocol FeatureFlagProvider: Sendable {
    func bool(_ key: String, default value: Bool) -> Bool
    func string(_ key: String, default value: String) -> String
    func int(_ key: String, default value: Int) -> Int
}

/// In-memory provider seeded from a dictionary — useful for defaults and tests.
public struct StaticFeatureFlags: FeatureFlagProvider {
    private let values: [String: any Sendable]
    public init(_ values: [String: any Sendable] = [:]) { self.values = values }

    public func bool(_ key: String, default value: Bool) -> Bool {
        values[key] as? Bool ?? value
    }
    public func string(_ key: String, default value: String) -> String {
        values[key] as? String ?? value
    }
    public func int(_ key: String, default value: Int) -> Int {
        values[key] as? Int ?? value
    }
}
