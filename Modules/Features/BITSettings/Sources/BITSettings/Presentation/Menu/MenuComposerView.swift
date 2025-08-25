import BITAppAuth
import BITAppInfo
import BITCore
import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - MenuComposerView

public struct MenuComposerView: View {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public var body: some View {
    content
      .navigationTitle(L10n.settingsTitle)
  }

  // MARK: Private

  @State private var isImpressumPresented = false
  @State private var isDatenschutzPresented = false
  @State private var isLicensesPresented = false
  @State private var isVerificationInstructionPresented = false

  private var content: some View {
    ScrollView {
      VStack(spacing: .x10) {
        MenuSection {
          MenuCell(systemImage: "lock", text: L10n.settingsSecurity, disclosureIndicator: .navigation) {
            isDatenschutzPresented.toggle()
          }.hasDivider(false)
        }
        .padding(.top, .x6)

        MenuSection {
          MenuCell(systemImage: "globe", text: L10n.settingsLanguage, disclosureIndicator: .externalLink) {
            openLink(UIApplication.openSettingsURLString)
          }

          MenuCell(systemImage: "questionmark.circle", text: L10n.settingsHelp, disclosureIndicator: .externalLink) {
            openLink(L10n.settingsHelpLink)
          }
          MenuCell(systemImage: "envelope", text: L10n.settingsContact, disclosureIndicator: .externalLink) {
            openLink(L10n.settingsContactLink)
          }
          MenuCell(systemImage: "text.bubble", text: L10n.tkMenuSettingWalletFeedback, disclosureIndicator: .externalLink) {
            openLink(L10n.tkMenuSettingWalletFeedbackLinkValue)
          }
          .hasDivider(false)
        }

        MenuSection {
          MenuCell(systemImage: "info.circle", text: L10n.settingsImpressum, disclosureIndicator: .navigation) { isImpressumPresented.toggle() }
          MenuCell(systemImage: "doc", text: L10n.settingsLicences, disclosureIndicator: .navigation) { isLicensesPresented.toggle() }
            .hasDivider(false)
        }
      }

      NavigationLink(destination: PrivacyView(), isActive: $isDatenschutzPresented) {
        EmptyView()
      }

      NavigationLink(destination: ImpressumView(), isActive: $isImpressumPresented) {
        EmptyView()
      }

      NavigationLink(destination: LicencesListView(), isActive: $isLicensesPresented) {
        EmptyView()
      }
    }
    .font(.custom.body)
    .padding(.horizontal, .x4)
  }

  private func openLink(_ link: String) {
    guard let url = URL(string: link) else { return }
    UIApplication.shared.open(url)
  }

}

// MARK: - MenuListComposerView_Previews

#Preview {
  MenuComposerView()
}
