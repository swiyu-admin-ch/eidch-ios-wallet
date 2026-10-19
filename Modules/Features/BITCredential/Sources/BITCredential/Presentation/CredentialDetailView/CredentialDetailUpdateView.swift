import BITCredentialShared
import BITL10n
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

struct CredentialDetailUpdateView: View {

  // MARK: Lifecycle

  init(credential: CredentialProtocol) {
    _viewModel = State(initialValue: Container.shared.credentialDetailUpdateViewModel(credential))
  }

  // MARK: Internal

  var body: some View {
    List {
      Section {
        HeaderCell(
          image: Assets.credentialUpdate.swiftUIImage,
          title: viewModel.title,
          bodyText: viewModel.body)
      }
      .listRowBackground(ThemingAssets.Background.groupedRow.swiftUIColor)

      if viewModel.isRefreshable {
        Section {
          Button(action: { Task { await buttonAction(navigator) } }) {
            Text(L10n.tkDisplayrefreshButtonPrimarybutton)
              .font(.custom.body)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
          .tint(.blue)
          .disabled(!viewModel.isUpdateEnabled)
          .accessibilityIdentifier(AccessibilityIdentifier.refreshPrimaryButton.rawValue)
        } footer: {
          if !viewModel.isUpdateEnabled {
            Text(L10n.tkDisplayrefreshButtonFooter)
              .font(.custom.footnote)
              .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          }
        }
        .listRowBackground(ThemingAssets.Background.groupedRow.swiftUIColor)
      }

      Section {
        HStack(alignment: .center, spacing: .x3) {
          NormalizedLogoCircular(viewModel.issuerDisplay?.image)
            .controlSize(.mini)

          Text(viewModel.issuerDisplay?.name ?? L10n.tkErrorNotregisteredTitle)
            .font(.custom.body)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .multilineTextAlignment(.leading)
        }
      } header: {
        Text(L10n.tkActivityActivityDetailIssuerTitle)
          .foregroundStyle(ThemingAssets.Label.sectionHeader.swiftUIColor)
          .font(.custom.headline)
          .accessibilityAddTraits(.isHeader)
      }
      .listRowBackground(ThemingAssets.Background.groupedRow.swiftUIColor)
    }
    .listSectionSpacing(.x3)
    .contentMargins(.top, .x2, for: .scrollContent)
    .scrollContentBackground(.hidden)
    .disabled(viewModel.isLoading)
    .loadingOverlay(
      isPresented: viewModel.isLoading,
      message: L10n.tkDisplayrefreshLoadingTitle,
      accessibility: .voiceOver())
    .overlay(alignment: .top) {
      if viewModel.isErrorPresented {
        Notification(
          systemImageName: "exclamationmark.triangle",
          imageColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor,
          title: L10n.tkErrorGenericPrimary,
          titleColor: ThemingAssets.Brand.Core.swissRed.swiftUIColor,
          content: L10n.tkErrorGenericSecondary,
          contentColor: ThemingAssets.Label.secondary.swiftUIColor,
          closeAction: viewModel.hideError,
          background: ThemingAssets.Brand.Bright.swissRed.swiftUIColor,
          closeButtonStyle: .secondary)
          .padding(.horizontal, .x4)
          .padding(.top, .x4)
          .accessibilityElement(children: .combine)
          .accessibilityIdentifier(AccessibilityIdentifier.refreshErrorNotification.rawValue)
          .transition(.move(edge: .top).combined(with: .opacity))
      }
    }
    .animation(.easeInOut(duration: 0.2), value: viewModel.isErrorPresented)
    .accessibilityIdentifier(AccessibilityIdentifier.refreshContent.rawValue)
    .background(ThemingAssets.Background.secondary.swiftUIColor.ignoresSafeArea())
    .navigationTitle(viewModel.title)
    .navigationBarTitleDisplayMode(.inline)
  }

  // MARK: Private

  private enum AccessibilityIdentifier: String {
    case refreshContent = "credentialDetailRefreshContent"
    case refreshPrimaryButton = "credentialDetailRefreshPrimaryButton"
    case refreshErrorNotification = "credentialDetailRefreshErrorNotification"
  }

  @Environment(\.navigator) private var navigator

  @State private var viewModel: CredentialDetailUpdateViewModel

  private func buttonAction(_ navigator: Navigator) async {
    await viewModel.primaryAction { refreshedCredential in
      navigator.returnToCheckpoint(CredentialDetailCheckpoints.refreshedCredential, value: refreshedCredential)
    }
  }

}
