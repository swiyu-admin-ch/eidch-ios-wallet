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
          primary: L10n.tkGetEidDataPrivacyTitle,
          secondary: L10n.tkGetEidDataPrivacyBody,
          tertiary: L10n.tkGetEidDataPrivacyLinkText,
          tertiaryAction: viewModel.openHelp)
      },
      footer: {
        DefaultInformationFooterView(
          primaryButtonLabel: L10n.tkGetEidDataPrivacyPrimaryButton,
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
