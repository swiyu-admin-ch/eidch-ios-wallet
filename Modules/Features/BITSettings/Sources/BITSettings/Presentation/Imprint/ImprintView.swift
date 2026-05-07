import BITL10n
import BITTheming
import SwiftUI

// MARK: - ImprintView

public struct ImprintView: View {

  // MARK: Lifecycle

  public init() {
    _viewModel = State(initialValue: ImprintViewModel())
  }

  // MARK: Public

  public var body: some View {
    SettingsPage(title: L10n.tkSettingsImprintTitle) {
      SettingsSection {
        VStack(alignment: .leading, spacing: 0) {
          Text(L10n.tkSettingsImprintAppInformationBody)
            .multilineTextAlignment(.leading)
            .font(.custom.body)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .padding(.horizontal, .x6)
          SettingsItem(title: L10n.tkSettingsImprintAppInformationBuildNumber, detail: viewModel.buildNumber)
          SettingsItem(title: L10n.tkSettingsImprintAppInformationAppVersion, detail: viewModel.appVersion)
          if let url = URL(string: L10n.tkSettingsImprintAppInformationGithubLinkValue) {
            CustomLink(to: url, label: L10n.tkSettingsImprintAppInformationGithubLinkText)
              .padding(.top, .x4)
              .padding(.horizontal, .x6)
          }
        }
        .padding(.vertical, .x4)
      }
      SettingsSection(title: L10n.tkSettingsImprintPublisherSectionTitle) {
        VStack(alignment: .leading, spacing: .x4) {
          Assets.swissLogo.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityLabel("") // This prevents VoiceOver to read out image name as it magically reads the text in the image
          if let url = URL(string: L10n.tkSettingsImprintPublisherLinkValue) {
            CustomLink(to: url, label: L10n.tkSettingsImprintPublisherLinkText)
          }
        }
        .padding(.vertical, .x4)
        .padding(.horizontal, .x6)
      }
      SettingsSection(title: L10n.tkSettingsImprintLegalSectionTitle) {
        VStack(alignment: .leading, spacing: 0) {
          SettingsItem(
            image: Assets.terms.swiftUIImage,
            title: L10n.tkSettingsImprintLegalTermsOfUseLinkText,
            type: .link(L10n.tkSettingsImprintLegalTermsOfUseLinkValue))
            .padding(.bottom, .x2_5)
          Text(L10n.tkSettingsImprintLegalDisclaimerPrimary)
            .multilineTextAlignment(.leading)
            .font(.custom.body)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .padding(.horizontal, .x6)
          Text(L10n.tkSettingsImprintLegalDisclaimerSecondary)
            .multilineTextAlignment(.leading)
            .font(.custom.caption1)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .padding(.horizontal, .x6)
        }
        .padding(.vertical, .x4)
      }
    }
  }

  // MARK: Private

  @State private var viewModel: ImprintViewModel
}

#Preview {
  ImprintView()
}
