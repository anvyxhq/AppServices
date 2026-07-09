//
//  AppServicesTests.swift
//  AppServices
//
//  Created by AnhPT on 02/07/2026.
//

import XCTest
@testable import AnvyxServiceKit

final class AppServicesTests: XCTestCase {
    func testStaticFeatureFlags() {
        let flags = StaticFeatureFlags(["pro_enabled": true, "max_pages": 10])
        XCTAssertTrue(flags.bool("pro_enabled", default: false))
        XCTAssertEqual(flags.int("max_pages", default: 0), 10)
        XCTAssertEqual(flags.string("missing", default: "fallback"), "fallback")
    }

    func testCompositeAnalyticsForwards() {
        final class Spy: AnalyticsService, @unchecked Sendable {
            var events: [String] = []
            func log(event name: String, parameters: [String: Any]) { events.append(name) }
            func setUserProperty(_ value: String?, for name: String) {}
            func setUserID(_ id: String?) {}
        }
        let spy = Spy()
        let analytics = CompositeAnalytics([spy, ConsoleAnalytics()])
        analytics.log(event: "open")
        XCTAssertEqual(spy.events, ["open"])
    }
}
