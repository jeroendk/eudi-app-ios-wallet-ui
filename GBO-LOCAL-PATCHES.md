# GBO Demo Wallet — local changes

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
  `nl.dekokdigital.gbo.wallet`. The display name is `GBO Demo Wallet`; the ID Provider extension is no longer built or
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
  PoDoFo, is retained. On 11 November 2026, Jeroen explicitly chose to leave the
  PDF signing library unchanged and not create an additional fork. The signing
  SDK therefore retains its default theme and two embedded EU wallet logo assets.
  This is an accepted branding exception for now; the signing screens are not
  fully branded as GBO Demo Wallet. The local asset replacement proposal is not used
  by the application and has not been published.
- `LICENSE.txt` is byte-for-byte unchanged. Upstream `NOTICE.txt` is preserved
  with a GBO modification notice appended. The `.orig` local backup is excluded
  locally and is never tracked.

## Verification

- Xcode 27.0 (27A266a), Debug Dev, iPhone 17 / iOS 26.5: build succeeded.
- The build used clean checkouts of both pinned GBO dependency commits. Since
  their tags have not been pushed, this verification used temporary Git URL
  redirects to the sibling local clones, scoped to the build process only.
- Final built app `CFBundleName` and `CFBundleDisplayName`: `GBO Demo Wallet`;
  identifier: `nl.dekokdigital.gbo.wallet.dev`. The system authentication alert
  was visually checked with this name. The menu title uses the existing
  `my_eu_wallet` catalog key, whose English value is now the GBO name; upstream
  had looked up a different literal key and displayed its old fallback.
- All four configuration names, bundle identifiers, entitlements and icon-set
  references were checked. All asset catalogs parse successfully.
- Primary body text, secondary text, links and primary buttons meet 4.5:1 in
  both appearances (lowest checked text ratio: 7.01:1). Icon lettering: 5.24:1.
- Xcode 27 Device Hub provides the simulator UI. The absence of the former
  `Simulator.app` does not mean simulator interaction is unavailable. On
  11 November, home, documents, add-document, offer, presentation request and
  About were checked in both appearances; captures are outside the repo.
- Issuance smoke test passed on 11 November: `Demo-inkomen 2025` was requested
  through the existing mock DigiD login and stored as a valid credential.
  It initially remained deferred because the running demo adapter reported
  `activated source snapshot expired outside stale grace`. One normal source
  reconciliation refreshed the metadata; the pending credential then arrived.
  No application or backend source/configuration change was needed.
- Jeroen explicitly approved adding the existing GBO test PID with fictitious
  data for the presentation smoke test, without changing trust settings.
  Test-PID issuance passed. Presentation to `Demo unsecured source` passed:
  the request asked only for the fictitious BSN, Jeroen confirmed with his PIN,
  and the wallet displayed `Data shared` and a new credential offer from the
  source. That additional offer was closed, since issuance was already tested.
  The wallet retains the test PID and the issued income credential.
- Remaining EUDI references are source attribution, upstream documentation and
  licenses, Swift/package/project identifiers, preserved imageset identifiers,
  previews, and existing issuer/trust/RQES service configuration. These are not
  GBO product names. The upstream trust-mark source config remains unused by
  the welcome/about screen; no trust configuration was changed.

## Before TestFlight (Jeroen)

1. Review the light/dark screenshots and smoke-test results in the external
   review folder. Check the retained PDF-signing branding exception before
   external distribution. The signing flow itself was not part of this smoke test.
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


## Name update (11 November 2026)

Jeroen selected **GBO Demo Wallet** as the final visible name, reflecting its use
with the simulation environment. Display names, in-app product text and the
internal `CFBundleName` use this name; the latter is also used by the system
web-authentication consent dialog. Bundle identifiers remain unchanged.
The GBO wordmark and icons do not change. The PDF signing library remains
unchanged as explicitly requested. No fourth fork is created.


## GBO LoTE profile (#614, 11 November 2026)

This supersedes the static GBO trust configuration described above. The wallet
uses only the four centrally signed GBO LoTE URLs, with SchemeTerritory NL and
an explicit GBO demo profile. The scheme signer is anchored to an independent
public root supplied per build. No credential/reader/registrar root or end
certificate remains pinned in GboTrust, and there is no static fallback.

The NL PID vct urn:eudi:pid:nl:1 is classified as PID. The demo maps non-PID
attestations to PubEAA, preserves the existing trust enforcement/warning choices,
and keeps PKIX revocation disabled as an explicit demo shortcut. The local SDK
patch supplies the missing PubEAA mapping and uses CA path validation rather
than EU end-certificate profiles. Registration trust uses WRPRC from the same
central provider. The registration toggle retains its existing behavior.

Build endpoints and the public LoTE root are explicit inputs; there is no
hardcoded simulation hostname. The issuer list contains rvig, belastingdienst,
demo-unsecured and test-pid. Both anchor caches use one hour. Android's file
cache is patched to actually refresh hourly and to preserve a verified cache
until signed NextUpdate after an outage. iOS has a verified memory-only JWT
cache and uses normal URLSession TLS. See GBO-demo/wallet-patches/README.md for
cache limits, source revisions, verification fixtures and reproducible commands.

All SDK source patches remain local and unpublished; there is no new GitHub
fork or published binary. Existing branding and PDF signing work is preserved.
The full Android build and Kotlin verifier fixture tests pass. Swift verifier
fixture tests pass; the manual wallet acceptance tests are not complete.

The iOS issuer registry now uses the complete issuer URL, preserving all four
providers sharing a host. The existing wallet-kit SDK also needs the local
metadata-cache fix: its global dictionary was written concurrently, causing a
SIGSEGV while loading the four issuers. The patch synchronizes access and makes
the existing cacheIssuerMetadata=false setting effective. Builds use the prepared
GBO_SECURITY_PACKAGE_PATH and GBO_WALLET_KIT_PACKAGE_PATH packages.

Use normal simulator signing and preserve first-run preferences when updating.
An unsigned build cannot access keychain/app-group data, and a build that the
app treats as a first run removes the existing documents through the upstream
first-run cleanup.
