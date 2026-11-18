/*
 * Copyright (c) 2026 European Commission
 *
 * Licensed under the EUPL, Version 1.2 or - as soon they will be approved by the European
 * Commission - subsequent versions of the EUPL (the "Licence"); You may not use this work
 * except in compliance with the Licence.
 *
 * You may obtain a copy of the Licence at:
 * https://joinup.ec.europa.eu/software/page/eupl
 *
 * Unless required by applicable law or agreed to in writing, software distributed under
 * the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
import XCTest
@testable import logic_core

final class TestGboPidClassification: XCTestCase {
  func testDutchPidIsRecognizedWithoutChangingItsVct() {
    let identifier = DocumentTypeIdentifier(rawValue: "urn:eudi:pid:nl:1")
    XCTAssertTrue(identifier.isPid)
    XCTAssertEqual(identifier.rawValue, "urn:eudi:pid:nl:1")
    XCTAssertTrue(DocumentTypeIdentifier.pidTypes.contains(identifier))
    XCTAssertNotEqual(identifier, .sdJwtPid)
  }

  func testExistingPidTypesRemainRecognized() {
    XCTAssertTrue(DocumentTypeIdentifier(rawValue: "eu.europa.ec.eudi.pid.1").isPid)
    XCTAssertTrue(DocumentTypeIdentifier(rawValue: "urn:eudi:pid:1").isPid)
  }

  func testOtherAttestationsAreNotPid() {
    for vct in ["urn:example:income:1", "org.iso.18013.5.1.mDL", "urn:eudi:pid:nl:other", ""] {
      XCTAssertFalse(DocumentTypeIdentifier(rawValue: vct).isPid)
    }
  }

  func testPidSelectionIncludesStoredDutchPidAndExcludesOtherDocuments() {
    let documents = ["urn:example:income:1", "urn:eudi:pid:nl:1", "urn:eudi:pid:1"]
      .map(DocumentTypeIdentifier.init(rawValue:))
    let selected = documents.filter(DocumentTypeIdentifier.pidTypes.contains)
    XCTAssertEqual(selected.map(\.rawValue), ["urn:eudi:pid:nl:1", "urn:eudi:pid:1"])
  }
}
