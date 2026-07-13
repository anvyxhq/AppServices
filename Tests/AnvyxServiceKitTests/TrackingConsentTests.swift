//
//  TrackingConsentTests.swift
//  AppServices
//
//  Created by AnhPT on 13/07/2026.
//

import XCTest
import AppTrackingTransparency
@testable import AnvyxServiceKit

final class TrackingConsentTests: XCTestCase {

    func testStatusMappingCoversEveryCase() {
        XCTAssertEqual(TrackingConsentStatus(.authorized), .authorized)
        XCTAssertEqual(TrackingConsentStatus(.denied), .denied)
        XCTAssertEqual(TrackingConsentStatus(.restricted), .restricted)
        XCTAssertEqual(TrackingConsentStatus(.notDetermined), .notDetermined)
    }

    func testStatusIsQueryableWithoutCrashing() {
        // On a fresh Simulator this is .notDetermined; the point is it doesn't trap.
        _ = TrackingConsent.status
        _ = TrackingConsent.isAuthorized
    }

    func testAdvertisingIdentifierIsNilWhenNotAuthorized() {
        // Not authorized in the test host → no usable IDFA.
        if !TrackingConsent.isAuthorized {
            XCTAssertNil(TrackingConsent.advertisingIdentifier)
        }
    }
}
