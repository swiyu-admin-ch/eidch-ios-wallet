import BITL10n
import BITTheming
import Factory
import SwiftUI

struct DataPrivacyView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    viewModel = Container.shared.dataPrivacyViewModel(router)
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: Assets.shield.swiftUIImage,
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkEidRequestDataPrivacyTitle,
          secondary: L10n.tkEidRequestDataPrivacyBody,
          tertiary: L10n.tkEidRequestDataPrivacyLinkText,
          tertiaryAction: viewModel.openHelp)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkEidRequestDataPrivacyPrimaryButton,
          primaryButtonAction: viewModel.primaryAction)
      })
      .toolbar { CloseButtonToolbar(action: viewModel.close) }
  }

  // MARK: Private

  private var viewModel: DataPrivacyViewModel
}

#Preview {
  DataPrivacyView(router: EIDRequestRouter())
}
