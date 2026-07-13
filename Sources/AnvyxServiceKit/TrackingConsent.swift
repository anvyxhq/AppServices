//
//  TrackingConsent.swift
//  AppServices
//
//  Created by AnhPT on 13/07/2026.
//

import AppTrackingTransparency
import AdSupport
import Foundation

/// App Tracking Transparency authorization state (a `Sendable` mirror of
/// `ATTrackingManager.AuthorizationStatus`).
public enum TrackingConsentStatus: String, Sendable {
    case notDetermined, restricted, denied, authorized

    init(_ status: ATTrackingManager.AuthorizationStatus) {
        switch status {
        case .authorized:    self = .authorized
        case .denied:        self = .denied
        case .restricted:    self = .restricted
        case .notDetermined: self = .notDetermined
        @unknown default:    self = .notDetermined
        }
    }
}

/// App Tracking Transparency (ATT) consent — request permission to track the user
/// (access the IDFA) and read the current status.
///
/// Requires an `NSUserTrackingUsageDescription` in Info.plist; the system prompt
/// is shown at most once. Call ``requestAuthorization()`` at an appropriate moment
/// (not at launch), then gate ad/analytics personalization on the result.
///
/// ```swift
/// let status = await TrackingConsent.requestAuthorization()
/// if status == .authorized, let idfa = TrackingConsent.advertisingIdentifier { … }
/// ```
public enum TrackingConsent {

    /// The current authorization status.
    public static var status: TrackingConsentStatus {
        TrackingConsentStatus(ATTrackingManager.trackingAuthorizationStatus)
    }

    public static var isAuthorized: Bool { status == .authorized }

    /// Present the ATT prompt if the status is undetermined, and return the
    /// resolved status. Safe to call again — the system won't re-prompt.
    @discardableResult
    public static func requestAuthorization() async -> TrackingConsentStatus {
        TrackingConsentStatus(await ATTrackingManager.requestTrackingAuthorization())
    }

    /// The advertising identifier (IDFA) when tracking is authorized, otherwise
    /// `nil` (the system returns an all-zero UUID when not authorized).
    public static var advertisingIdentifier: UUID? {
        guard isAuthorized else { return nil }
        let identifier = ASIdentifierManager.shared().advertisingIdentifier
        return identifier.uuidString == "00000000-0000-0000-0000-000000000000" ? nil : identifier
    }
}
