//
//  ABTestingTests.swift
//  AppServices
//
//  Created by AnhPT on 13/07/2026.
//

import XCTest
@testable import AnvyxServiceKit

private enum Checkout: String, CaseIterable, Sendable { case control, treatment }

final class ABTestingTests: XCTestCase {

    private let experiment = Experiment<Checkout>(name: "checkout_flow")

    func testAssignmentIsStablePerParticipant() {
        let first = experiment.variant(for: "user-123")
        let second = experiment.variant(for: "user-123")
        XCTAssertEqual(first, second, "the same participant must always get the same variant")
    }

    func testDistributesRoughlyEvenlyAcrossVariants() {
        var counts: [Checkout: Int] = [:]
        let n = 2000
        for i in 0..<n { counts[experiment.variant(for: "user-\(i)"), default: 0] += 1 }

        XCTAssertEqual(Set(counts.keys), Set(Checkout.allCases), "both variants are used")
        for variant in Checkout.allCases {
            let ratio = Double(counts[variant] ?? 0) / Double(n)
            XCTAssertGreaterThan(ratio, 0.4, "\(variant) share too small")
            XCTAssertLessThan(ratio, 0.6, "\(variant) share too large")
        }
    }

    func testFlagOverrideForcesVariant() {
        let flags = StaticFeatureFlags(["checkout_flow_variant": "treatment"])
        // Whatever the sticky assignment would be, the flag wins.
        XCTAssertEqual(flags.variant(for: experiment, participant: "anyone"), .treatment)
    }

    func testInvalidOverrideFallsBackToAssignment() {
        let flags = StaticFeatureFlags(["checkout_flow_variant": "not-a-variant"])
        XCTAssertEqual(
            flags.variant(for: experiment, participant: "user-7"),
            experiment.variant(for: "user-7"))
    }

    func testNoFlagFallsBackToAssignment() {
        let flags = StaticFeatureFlags()
        XCTAssertEqual(
            flags.variant(for: experiment, participant: "user-7"),
            experiment.variant(for: "user-7"))
    }
}
