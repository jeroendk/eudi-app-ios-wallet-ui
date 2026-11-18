import Foundation
import EudiEtsi1196x2

/// Build-supplied GBO simulation endpoints and independent public scheme root.
/// There are no credential, reader or registrar pins and no static fallback.
enum GboTrust {
  static let nlPid = DocumentTypeIdentifier.nlPid.rawValue
  static func setting(_ name: String) -> String { Bundle.main.object(forInfoDictionaryKey: name) as? String ?? "" }
  static var issuerBase: String { setting("GBO_ISSUER_BASE_URL").trimmingCharacters(in: CharacterSet(charactersIn: "/")) }
  static var issuerUrls: [String] { ["rvig", "belastingdienst", "demo-unsecured", "test-pid"].map { "\(issuerBase)/\($0)/eudi" } }
  static var locations: SupportedLists<NSString> {
    let base = setting("GBO_TRUST_BASE_URL").trimmingCharacters(in: CharacterSet(charactersIn: "/"))
    func location(_ role: String) -> NSString? {
      guard let url = URL(string: base), url.scheme == "https", url.host != nil else { return nil }
      return "\(base)/lote/\(role)Providers.jwt" as NSString
    }
    return SupportedLists(pidProviders: location("PID"), walletProviders: nil,
                          wrpacProviders: location("WRPAC"), wrprcProviders: location("WRPRC"),
                          pubEaaProviders: location("PubEAA"), qeaProviders: nil, eaaProviders: [:])
  }
  static let verifier = GboLoTEVerifier(root: Data(base64Encoded: setting("GBO_LOTE_ROOT_BASE64")) ?? Data())
  static let loader = GboLoTELoader(verifier: verifier)
}

final class GboLoTELoader: NSObject, IosLoadLoTE, @unchecked Sendable {
  private let cache: GboLoTECache
  init(verifier: GboLoTEVerifier) { cache = GboLoTECache(verifier: verifier) }
  func loadLoTE(uri: String) async throws -> any LoadLoTEOutcome {
    do {
      let compact: Swift.String = try await cache.load(uri)
      return LoadLoTEOutcomeLoaded<NSString>(content: compact as NSString)
    }
    catch { return LoadLoTEOutcomeNotFound(cause: nil) }
  }
}

private actor GboLoTECache {
  struct Entry { let jwt: String; let loaded: Date }
  private var entries: [String: Entry] = [:]
  private let verifier: GboLoTEVerifier
  init(verifier: GboLoTEVerifier) { self.verifier = verifier }
  func load(_ uri: String) async throws -> String {
    guard let url = URL(string: uri), url.scheme == "https", url.host != nil,
          ["PID", "PubEAA", "WRPAC", "WRPRC"].contains(where: { url.lastPathComponent == "\($0)Providers.jwt" }) else { throw GboLoTEVerifier.Failure.invalidList }
    let now = Date()
    if let entry = entries[uri], now.timeIntervalSince(entry.loaded) < 3600,
       (try? verifier.verify(entry.jwt, now: now)) != nil { return entry.jwt }
    do {
      var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
      request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
      let session = URLSession(configuration: .ephemeral)
      defer { session.invalidateAndCancel() }
      let (data, response) = try await session.data(for: request)
      guard let http = response as? HTTPURLResponse, http.statusCode == 200,
            response.url == url, data.count <= 4 * 1024 * 1024,
            let jwt = String(data: data, encoding: .utf8) else { throw GboLoTEVerifier.Failure.invalidList }
      let compact = jwt.trimmingCharacters(in: .whitespacesAndNewlines)
      try verifier.verify(compact)
      // The role in the signed document must also match the URL requested.
      let parts = compact.split(separator: ".")
      let claims = try JSONSerialization.jsonObject(with: GboLoTEVerifier.decode(String(parts[1]))) as! [String: Any]
      let info = (claims["LoTE"] as! [String: Any])["ListAndSchemeInformation"] as! [String: Any]
      let role = url.lastPathComponent.replacingOccurrences(of: "Providers.jwt", with: "")
      guard info["LoTEType"] as? String == "http://uri.etsi.org/19602/LoTEType/EU\(role)ProvidersList" else { throw GboLoTEVerifier.Failure.invalidList }
      entries[uri] = Entry(jwt: compact, loaded: Date())
      return compact
    } catch {
      // Last successfully verified list, only while still signed and current.
      if let entry = entries[uri], (try? verifier.verify(entry.jwt)) != nil { return entry.jwt }
      throw error
    }
  }
}

extension GboLoTEVerifier: VerifyJwtSignature {
  func invoke(jwt: String) async throws -> any VerifyJwtSignatureOutcome {
    try verify(jwt)
    return VerifyJwtSignatureOutcomeVerified(jwt: jwt)
  }
}
