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
 * the Licence is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
 * ANY KIND, either express or implied. See the Licence for the specific language
 * governing permissions and limitations under the Licence.
 */
// Modified by Jeroen de Kok for GBO Wallet, 2026-11-10.
import SwiftUI
import logic_ui
import logic_resources

struct TrustMarkView<Router: RouterHost>: View {

  @State private var viewModel: TrustMarkViewModel<Router>

  init(with viewModel: TrustMarkViewModel<Router>) {
    self._viewModel = State(wrappedValue: viewModel)
  }

  var body: some View {
    ContentScreenView(
      padding: .zero,
      canScroll: true,
      navigationTitle: viewModel.viewState.config.isWelcome ? nil : .trustMarkAboutTitle,
      toolbarContent: viewModel.toolbarContent()
    ) {
      ScrollView {
        VStack(alignment: .leading, spacing: SPACING_LARGE_MEDIUM) {
          Theme.shared.image.logo
            .resizable()
            .scaledToFit()
            .frame(width: 160, height: 80)
            .accessibilityLabel(Text(.trustMarkImageDescription))

          if viewModel.viewState.config.isWelcome {
            Text(.trustMarkWelcomeTitle)
              .typography(Theme.shared.font.titleLarge)
          }

          Text(.trustMarkWalletName)
            .typography(Theme.shared.font.displayLarge)

          Text(.trustMarkCertificationDescription([
            LocalizableStringKey.trustMarkCertifiedWalletsLink.toString
          ]))
          .typography(Theme.shared.font.bodyLarge)

          if let upstream = URL(string: "https://github.com/eu-digital-identity-wallet/eudi-app-ios-wallet-ui") {
            Link(destination: upstream) {
              Text(.trustMarkCertifiedWalletsLink)
                .underline()
                .foregroundStyle(Theme.shared.color.accent)
            }
          }

          Text(.trustMarkCertificationInformationDescription([
            LocalizableStringKey.trustMarkCertificationInformationLink.toString
          ]))
          .typography(Theme.shared.font.bodyLarge)

          if let source = URL(string: "https://github.com/jeroendk/eudi-app-ios-wallet-ui/tree/gbo/main") {
            Link(destination: source) {
              Text(.trustMarkCertificationInformationLink)
                .underline()
                .foregroundStyle(Theme.shared.color.accent)
            }
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(Theme.shared.color.primaryLabel)
        .tint(Theme.shared.color.accent)
        .padding(Theme.shared.dimension.padding)
      }
      .safeAreaInset(edge: .bottom, spacing: .zero) {
        if viewModel.viewState.config.isWelcome {
          WrapButtonView(
            style: .primary,
            title: .continueButton,
            isEnabled: !viewModel.viewState.isCompleting && !viewModel.viewState.isNavigating,
            onAction: viewModel.onContinue()
          )
          .padding(.horizontal, SPACING_MEDIUM)
          .padding(.top, SPACING_MEDIUM)
          .padding(.bottom, SPACING_LARGE_MEDIUM)
          .background(Theme.shared.color.background)
        }
      }
    }
  }
}
