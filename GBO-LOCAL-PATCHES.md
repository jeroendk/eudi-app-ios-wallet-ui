# GBO Wallet — local changes

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
- `EudiReferenceWallet.xcodeproj/project.pbxproj`: all app configurations use
  automatic signing, team UX8N9S62CQ and `EudiWallet.gbo.entitlements`
  (keychain and app group only). Debug configurations use
  `nl.dekokdigital.gbo.wallet.dev`; Release configurations use
  `nl.dekokdigital.gbo.wallet`. The display name is `GBO Wallet`; the ID Provider extension is no longer built or
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


## Branding and provenance (10 November 2026)

- Jeroen selected **GBO Wallet**, the existing GBO wordmark and the colors of
  https://gbo.simulatie.datastelsel.nl/. See `Branding/README.md` for the palette.
- Both app-icon sets contain opaque 1024×1024 icons with light/dark appearances.
  Xcode derives the device sizes. Both in-app logo imagesets and the OS launch
  screen use the GBO wordmark. Existing imageset identifiers remain unchanged.
- The welcome/about screen identifies the European Commission’s EUDI reference
  wallet and EUPL 1.2, links to upstream and the GBO fork, and states that this is
  a modified simulation build, not an official EU wallet. It does not fetch or
  display the upstream wallet certification badge. Credential trust and issuer
  configuration are unchanged.
- Jeroen chose to retain PDF signing (RQES). Its dependency chain, including
  PoDoFo, is retained. The signing SDK retains its own default theme and two embedded EU logo assets.
  A local proposal replaces those two assets only; publication in an additional
  RQES UI fork is awaiting Jeroen’s decision. Do not treat signing-screen
  rebranding as complete until that decision and the follow-up build.
- `LICENSE.txt` is byte-for-byte unchanged. Upstream `NOTICE.txt` is preserved
  with a GBO modification notice appended. The `.orig` local backup is excluded
  locally and is never tracked.

## Verification

- Xcode 27.0 (27A266a), Debug Dev, iPhone 17 / iOS 26.5: build succeeded.
- The build used clean checkouts of both pinned GBO dependency commits. Since
  their tags have not been pushed, this verification used temporary Git URL
  redirects to the sibling local clones, scoped to the build process only.
- Built app display name and identifier: `GBO Wallet`, `nl.dekokdigital.gbo.wallet.dev`.
- All four configuration names, bundle identifiers, entitlements and icon-set
  references were checked. All asset catalogs parse successfully.
- Primary body text, secondary text, links and primary buttons meet 4.5:1 in
  both appearances (lowest checked text ratio: 7.01:1). Icon lettering: 5.24:1.
- Simulator launch and welcome-screen captures are available outside the repo.
  The complete screenshot sequence and credential issuance/presentation smoke
  test are still pending: native simulator interaction was unavailable.
- Remaining EUDI references are source attribution, upstream documentation and
  licenses, Swift/package/project identifiers, preserved imageset identifiers,
  previews, and existing issuer/trust/RQES service configuration. These are not
  GBO product names. The upstream trust-mark source config remains unused by
  the welcome/about screen; no trust configuration was changed.

## Before TestFlight (Jeroen)

1. Complete the light/dark screenshots for splash, onboarding, document list,
   add document, offer, presentation and About; run one issuance and presentation.
2. Approve publication, then push the two dependency branches and exact tags,
   followed by the app branch. Until then, remote forks contain upstream only.
3. Select the simulation scheme and Release configuration; verify its existing
   issuer/trust configuration against the separately approved trust-list plan.
4. Replace upstream `MARKETING_VERSION = yyyy.mm.v` with a valid release version
   and choose a unique build number before archiving. Do not upload the placeholder.
5. In App Store Connect, create the app for `nl.dekokdigital.gbo.wallet`, verify
   signing/capabilities, privacy information and the encryption declaration.
6. Prepare accurate beta notes, review instructions, an external test group and
   a public TestFlight link. Clearly identify the simulation environment and
   European Commission reference-wallet origin. App Store Connect is not changed
   by this work.
