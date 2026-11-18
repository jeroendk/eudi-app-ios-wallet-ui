import Foundation
import Security
import CryptoKit
import X509

/// GBO demo profile, independently anchored. The JWT's x5c never supplies trust.
final class GboLoTEVerifier: NSObject, @unchecked Sendable {
  enum Failure: Error { case invalidList }
  private let root: Data
  init(root: Data) { self.root = root }

  func verify(_ jwt: String, now: Date = Date()) throws {
    func check(_ condition: Bool) throws { if !condition { throw Failure.invalidList } }
    let parts = jwt.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
    try check(parts.count == 3 && jwt.utf8.count <= 4 * 1024 * 1024)
    guard let header = try JSONSerialization.jsonObject(with: Self.decode(parts[0])) as? [String: Any],
          header["alg"] as? String == "ES256", header["crit"] == nil, header["b64"] == nil,
          let chain = header["x5c"] as? [String], (1...5).contains(chain.count),
          let anchor = SecCertificateCreateWithData(nil, root as CFData) else { throw Failure.invalidList }
    let certificates = try chain.map { value -> SecCertificate in
      guard let der = Data(base64Encoded: value), let cert = SecCertificateCreateWithData(nil, der as CFData) else { throw Failure.invalidList }
      return cert
    }
    try check(SecCertificateCopyData(certificates[0]) as Data != root)
    // Require an end-entity signing key, matching the Android LoTE profile.
    let signer = try X509.Certificate(derEncoded: Array(SecCertificateCopyData(certificates[0]) as Data))
    if let constraints = try signer.extensions.basicConstraints,
       case .isCertificateAuthority = constraints {
      throw Failure.invalidList
    }
    if let usage = try signer.extensions.keyUsage {
      try check(usage.digitalSignature)
    }
    var trust: SecTrust?
    try check(SecTrustCreateWithCertificates(certificates as CFArray, SecPolicyCreateBasicX509(), &trust) == errSecSuccess)
    guard let trust else { throw Failure.invalidList }
    try check(SecTrustSetAnchorCertificates(trust, [anchor] as CFArray) == errSecSuccess)
    try check(SecTrustSetAnchorCertificatesOnly(trust, true) == errSecSuccess)
    SecTrustSetNetworkFetchAllowed(trust, false)
    SecTrustSetVerifyDate(trust, now as CFDate)
    try check(SecTrustEvaluateWithError(trust, nil))
    guard let key = SecCertificateCopyKey(certificates[0]),
          let encoded = SecKeyCopyExternalRepresentation(key, nil) as Data? else { throw Failure.invalidList }
    let publicKey = try P256.Signing.PublicKey(x963Representation: encoded)
    let signature = try P256.Signing.ECDSASignature(rawRepresentation: Self.decode(parts[2]))
    try check(publicKey.isValidSignature(signature, for: Data((parts[0] + "." + parts[1]).utf8)))
    guard let payload = try JSONSerialization.jsonObject(with: Self.decode(parts[1])) as? [String: Any],
          let lote = payload["LoTE"] as? [String: Any],
          let info = lote["ListAndSchemeInformation"] as? [String: Any],
          info["SchemeTerritory"] as? String == "NL",
          info["LoTEVersionIdentifier"] as? Int == 1,
          let sequence = info["LoTESequenceNumber"] as? Int, sequence > 0,
          let operators = info["SchemeOperatorName"] as? [[String: Any]],
          operators.contains(where: { $0["value"] as? String == "GBO Demo" }),
          let type = info["LoTEType"] as? String,
          let role = ["PID", "PubEAA", "WRPAC", "WRPRC"].first(where: { type == "http://uri.etsi.org/19602/LoTEType/EU\($0)ProvidersList" }),
          let issue = info["ListIssueDateTime"] as? String, let next = info["NextUpdate"] as? String,
          let from = ISO8601DateFormatter().date(from: issue), let until = ISO8601DateFormatter().date(from: next),
          let entities = lote["TrustedEntitiesList"] as? [[String: Any]], !entities.isEmpty else { throw Failure.invalidList }
    try check(from <= now && now < until && from < until)
    for entity in entities {
      guard let services = entity["TrustedEntityServices"] as? [[String: Any]], !services.isEmpty else { throw Failure.invalidList }
      for service in services {
        guard let si = service["ServiceInformation"] as? [String: Any],
              let type = si["ServiceTypeIdentifier"] as? String,
              ["Issuance", "Revocation"].contains(where: { type == "http://uri.etsi.org/19602/SvcType/\(role)/\($0)" }) else { throw Failure.invalidList }
      }
    }
  }

  static func decode(_ part: String) throws -> Data {
    var value = part.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/")
    value += String(repeating: "=", count: (4 - value.count % 4) % 4)
    guard let data = Data(base64Encoded: value) else { throw Failure.invalidList }
    return data
  }
}
