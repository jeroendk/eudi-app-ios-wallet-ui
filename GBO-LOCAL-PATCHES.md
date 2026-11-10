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

Dependency changes (in the SwiftPM checkout, re-apply after a package reset):
- eudi-lib-ios-openid4vci-swift v0.55.2, `Sources/Main/Authorisers/AuthorizationServerClient.swift`,
  pre-authorized token request: `authServerId: tokenEndpoint` ->
  `URL(string: authorizationServerMetadata.issuer ?? "") ?? tokenEndpoint`.
  draft-ietf-oauth-attestation-based-client-auth -07/-08: the PoP `aud` MUST be
  the authorization server's issuer identifier.
- eudi-lib-ios-wallet-kit 0.54.5, `Sources/EudiWalletKit/Services/OpenId4VciService.swift`,
  `submissionUseCase`: send `.identifierBased` with the credential identifier
  from the token response when there is one. OpenID4VCI 1.0 section 8.2.

Build for the iPhone: the same command with `-destination 'id=<device udid>' -allowProvisioningUpdates`
and without the signing overrides.

Build (simulator, ad-hoc signed so the keychain works):
xcodebuild -project EudiReferenceWallet.xcodeproj -scheme "EUDI Wallet Dev" -configuration "Debug Dev" \
  -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath <dd> -clonedSourcePackagesDirPath <dd>/SourcePackages \
  -skipPackagePluginValidation -skipMacroValidation -disableAutomaticPackageResolution \
  CODE_SIGN_IDENTITY="-" CODE_SIGN_STYLE=Manual DEVELOPMENT_TEAM="" PROVISIONING_PROFILE_SPECIFIER="" build
