//
//  MPKitFirebaseGA4SwiftTests.swift
//  mParticle-Google-Analytics-Firebase-GA4
//
//  Created by Nick Dimitrakas on 9/12/25.
//

import XCTest
@testable import mParticle_Google_Analytics_Firebase_GA4

final class MPKitFirebaseGA4AnalyticsTests: XCTestCase {
    var kit: MPKitFirebaseGA4Analytics!

    override func setUp() {
        super.setUp()
        kit = MPKitFirebaseGA4Analytics()
        kit.configuration = [:]
    }

    override func tearDown() {
        kit = nil
        super.tearDown()
    }

    // MARK: - resolvedConsentForPurpose

    func testResolvedConsentForPurpose_whenConsentGranted_returnsYES() {
        let consent = MPGDPRConsent()
        consent.consented = true
        let gdprConsents = ["analytics": consent]

        let result = kit.resolvedConsent(forPurpose: "analytics", gdprConsents: gdprConsents)

        XCTAssertEqual(result, true)
    }

    func testResolvedConsentForPurpose_whenConsentDenied_returnsNO() {
        let consent = MPGDPRConsent()
        consent.consented = false
        let gdprConsents = ["ads": consent]

        let result = kit.resolvedConsent(forPurpose: "ads", gdprConsents: gdprConsents)

        XCTAssertEqual(result, false)
    }

    func testResolvedConsentForPurpose_whenConsentMissing_returnsNil() {
        let gdprConsents: [String: MPGDPRConsent] = [:]

        let result = kit.resolvedConsent(forPurpose: "ads", gdprConsents: gdprConsents)

        XCTAssertNil(result)
    }

    // MARK: - resolvedConsentFromDefault

    func testResolvedConsentFromDefault_whenGranted_returnsYES() {
        kit.configuration = ["purpose_default": "Granted"]

        let result = kit.resolvedConsent(fromDefault: "purpose_default")

        XCTAssertEqual(result, true)
    }

    func testResolvedConsentFromDefault_whenDenied_returnsNO() {
        kit.configuration = ["purpose_default": "Denied"]

        let result = kit.resolvedConsent(fromDefault: "purpose_default")

        XCTAssertEqual(result, false)
    }

    func testResolvedConsentFromDefault_whenMissing_returnsNil() {
        kit.configuration = [:]

        let result = kit.resolvedConsent(fromDefault: "purpose_default")

        XCTAssertNil(result)
    }

    // MARK: - resolvedConsentForMappingKey

    func testResolvedConsentForMappingKey_prefersGDPRConsentOverDefault() {
        let consent = MPGDPRConsent()
        consent.consented = true
        let gdprConsents = ["analytics": consent]

        let mapping = ["tracking": "analytics"]
        kit.configuration = ["tracking_default": "Denied"]

        let result = kit.resolvedConsent(forMappingKey: "tracking",
                                         defaultKey: "tracking_default",
                                         gdprConsents: gdprConsents,
                                         mapping: mapping)

        // Should return GDPR (true) instead of config (Denied/false)
        XCTAssertEqual(result, true)
    }

    func testResolvedConsentForMappingKey_fallsBackToDefaultWhenNoGDPR() {
        let gdprConsents: [String: MPGDPRConsent] = [:]
        let mapping = ["tracking": "ads"]
        kit.configuration = ["tracking_default": "Granted"]

        let result = kit.resolvedConsent(forMappingKey: "tracking",
                                         defaultKey: "tracking_default",
                                         gdprConsents: gdprConsents,
                                         mapping: mapping)

        XCTAssertEqual(result, true)
    }

    func testResolvedConsentForMappingKey_returnsNilWhenNeitherFound() {
        let gdprConsents: [String: MPGDPRConsent] = [:]
        let mapping = ["tracking": "ads"]
        kit.configuration = [:]

        let result = kit.resolvedConsent(forMappingKey: "tracking",
                                         defaultKey: "tracking_default",
                                         gdprConsents: gdprConsents,
                                         mapping: mapping)

        XCTAssertNil(result)
    }
}
