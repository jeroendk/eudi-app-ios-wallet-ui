# Local GBO demo build (not upstream)

App changes (in this clone):
- `Modules/logic-core/Sources/Config/GboTrust.swift`: GBO roots and pinned leaves.
- `Modules/logic-core/Sources/Config/WalletKitConfig.swift`: static trust source
  (`.directTrust`) with the GBO access certificates (WRPAC) and registrar leaves,
  instead of the EU trusted lists. iOS validates a static chain only with a
  revocation response, which the development certificates cannot give. The
  pinned leaves are the WRPACs of the three sources, the test PID provider,
  the reference QTSP and the ASI authorization server as verifier
  (eudi-wallet-verifier, GBO-demo #639); a new certificate needs a new build. The DEV issuer
  list also holds the own credential issuer's `eudi` identifiers of the three
  sources (rvig, belastingdienst, demo-unsecured), for wallet-initiated
  issuance with the authorization code flow (#614 phase 3).
- `EudiReferenceWallet.xcodeproj/project.pbxproj` (original in `.orig`), "Debug Dev"
  of the app target: automatic signing, team UX8N9S62CQ, bundle id
  `nl.dekokdigital.gbo.eudiwallet.dev`, entitlements `EudiWallet.gbo.entitlements`
  (keychain and app group only); the ID Provider extension is no longer built or
  embedded (it needs Apple's identity document services entitlement).

Dependency changes are versioned in public forks (Apache 2.0):
- https://github.com/jeroendk/eudi-lib-ios-openid4vci-swift, exact tag `0.55.2-gbo.1`:
  preserve the authorization server issuer identifier as the client-attestation PoP audience.
- https://github.com/jeroendk/eudi-lib-ios-wallet-kit, exact tag `0.54.5-gbo.1`:
  preserve `credential_identifier` in credential requests and pin the OpenID4VCI fork.

The app pins WalletKit in `Modules/logic-core/Package.swift`; WalletKit pins
OpenID4VCI in its own `Package.swift`. `Package.resolved` records both revisions.
No edits to SwiftPM checkouts or post-resolve patch scripts are required.
Publish the dependency commits and tags before resolving on another machine.
Until push approval, these commits and tags exist locally only.

Build for the iPhone: the same command with `-destination 'id=<device udid>' -allowProvisioningUpdates`
and without the signing overrides.

Build (simulator, ad-hoc signed so the keychain works):
xcodebuild -project EudiReferenceWallet.xcodeproj -scheme "EUDI Wallet Dev" -configuration "Debug Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath <dd> -clonedSourcePackagesDirPath <dd>/SourcePackages \
  -skipPackagePluginValidation -skipMacroValidation -disableAutomaticPackageResolution \
  CODE_SIGN_IDENTITY="-" CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="" PROVISIONING_PROFILE_SPECIFIER="" build
