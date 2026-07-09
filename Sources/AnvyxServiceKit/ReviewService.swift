//
//  ReviewService.swift
//  AppServices
//
//  Created by AnhPT on 02/07/2026.
//

import StoreKit
import SwiftUI

/// Requests an App Store review prompt, gated by a launch counter so you only ask
/// engaged users and never more than the system allows.
@MainActor
public enum ReviewService {
    @AppStorage("anvora.review.significantEvents") private static var events = 0
    @AppStorage("anvora.review.lastRequestVersion") private static var lastVersion = ""

    /// Record a meaningful action (export, save, share…) and prompt once the
    /// threshold is reached — at most once per app version.
    public static func registerSignificantEvent(threshold: Int = 5) {
        events += 1
        guard events >= threshold else { return }

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        guard version != lastVersion else { return }

        requestReview()
        lastVersion = version
        events = 0
    }

    /// Ask immediately, bypassing the counter.
    public static func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
