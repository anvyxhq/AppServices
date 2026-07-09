//
//  OnboardingState.swift
//  AppServices
//
//  Created by AnhPT on 02/07/2026.
//

import Foundation
import Observation

/// Tracks first-run onboarding completion and "what's new" per app version,
/// persisted in `UserDefaults`. Uses the Observation framework (iOS 17+).
@MainActor
@Observable
public final class OnboardingState {
    public private(set) var hasCompletedOnboarding: Bool

    @ObservationIgnored private let defaults: UserDefaults
    @ObservationIgnored private var lastSeenVersion: String

    private enum Keys {
        static let completed = "anvyx.onboarding.completed"
        static let lastVersion = "anvyx.onboarding.lastSeenVersion"
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.hasCompletedOnboarding = defaults.bool(forKey: Keys.completed)
        self.lastSeenVersion = defaults.string(forKey: Keys.lastVersion) ?? ""
    }

    private var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }

    /// `true` when the app updated to a new version the user hasn't seen yet.
    public var shouldShowWhatsNew: Bool {
        hasCompletedOnboarding && lastSeenVersion != currentVersion
    }

    public func completeOnboarding() {
        hasCompletedOnboarding = true
        defaults.set(true, forKey: Keys.completed)
        markWhatsNewSeen()
    }

    public func markWhatsNewSeen() {
        lastSeenVersion = currentVersion
        defaults.set(currentVersion, forKey: Keys.lastVersion)
    }
}
