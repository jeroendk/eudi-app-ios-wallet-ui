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
import Foundation
import XCTest
@testable import logic_core

final class TestGboLoTESignerProfile: XCTestCase {
  private let now = ISO8601DateFormatter().date(from: "2026-11-11T12:00:00Z")!

  private func data(_ name: String) throws -> Data {
    let url = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: nil, subdirectory: "GboLoTE"))
    return try Data(contentsOf: url)
  }

  func testEndEntitySignerProfilesMatchAndroid() throws {
    let verifier = GboLoTEVerifier(root: try data("signer-profile-root.der"))
    for name in ["valid-signer.jwt", "no-key-usage.jwt", "no-basic-constraints.jwt"] {
      XCTAssertNoThrow(try verifier.verify(String(decoding: data(name), as: UTF8.self), now: now), name)
    }
  }

  func testCaAndNonSigningCertificatesAreRejected() throws {
    let verifier = GboLoTEVerifier(root: try data("signer-profile-root.der"))
    for name in ["ca-signer.jwt", "ca-digital-signature.jwt", "non-signing-leaf.jwt"] {
      XCTAssertThrowsError(try verifier.verify(String(decoding: data(name), as: UTF8.self), now: now), name)
    }
  }

  func testExistingListVerificationFixtures() throws {
    let verifier = GboLoTEVerifier(root: try data("root.der"))
    XCTAssertNoThrow(try verifier.verify(String(decoding: data("valid.jwt"), as: UTF8.self), now: now))
    for name in ["eu-territory", "wrong-role", "expired", "future", "wrong-alg", "bad-signature"] {
      XCTAssertThrowsError(try verifier.verify(String(decoding: data(name + ".jwt"), as: UTF8.self), now: now), name)
    }
    let wrong = GboLoTEVerifier(root: try data("wrong-root.der"))
    XCTAssertThrowsError(try wrong.verify(String(decoding: data("valid.jwt"), as: UTF8.self), now: now))
  }
}
