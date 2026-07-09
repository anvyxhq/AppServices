//
//  RemoteConfigService.swift
//  AppServices
//
//  Created by AnhPT on 02/07/2026.
//

import Foundation

/// An async remote-config source you can fetch and then read synchronously.
/// Wrap Firebase Remote Config, a JSON endpoint, etc.
public protocol RemoteConfigService: FeatureFlagProvider {
    /// Fetch and activate the latest values. Throwing implementations should
    /// keep the last good values on failure.
    func fetch() async throws
}

/// Fetches a flat JSON object of flags from a URL and serves them via
/// `FeatureFlagProvider`. Thread-safe: an internal lock guards the values so
/// reads stay synchronous while `fetch()` runs concurrently. Falls back to the
/// provided defaults until the first successful fetch.
public final class JSONRemoteConfig: RemoteConfigService, @unchecked Sendable {
    private let url: URL
    private let session: URLSession
    private let lock = NSLock()
    private var values: [String: Any]

    public init(url: URL, defaults: [String: Any] = [:], session: URLSession = .shared) {
        self.url = url
        self.values = defaults
        self.session = session
    }

    public func fetch() async throws {
        let (data, _) = try await session.data(from: url)
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else { return }
        lock.withLock { values = object }
    }

    public func bool(_ key: String, default value: Bool) -> Bool {
        read(key) as? Bool ?? value
    }
    public func string(_ key: String, default value: String) -> String {
        read(key) as? String ?? value
    }
    public func int(_ key: String, default value: Int) -> Int {
        read(key) as? Int ?? value
    }

    private func read(_ key: String) -> Any? {
        lock.withLock { values[key] }
    }
}
