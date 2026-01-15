import BITL10n
import BITTheming
import Factory
import Foundation
import NavigatorUI
import SwiftUI

// MARK: - WalletPairingListView

struct WalletPairingListView: View {

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case closeButton
  }

  var body: some View {
    List {
      header()
      sectionCurrentDevice()
      sectionAdditionalDevices()
    }
    .listStyle(.plain)
    .safeAreaInset(edge: .bottom) {
      footer()
    }
    .navigationBarBackButtonHidden(viewModel.isBackButtonHidden)
    .toolbar(content: toolbarContent)
    .frame(maxWidth: 568)
    .toastMessage(
      isPresented: $viewModel.isToastPresented,
      message: viewModel.toastMessage,
      clearAction: viewModel.clearToast)
    .onFirstAppear {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        isHeaderFocused = true
      }
    }
    .task {
      await viewModel.fetchStatus()
    }
    .navigate(to: $viewModel.destination)
    .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
  }

  // MARK: Private

  @AccessibilityFocusState private var isHeaderFocused: Bool

  @InjectedObject(\.walletPairingListViewModel) private var viewModel

  @ViewBuilder
  private func header() -> some View {
    Section {
      VStack(alignment: .leading, spacing: .x6) {
        Text(L10n.tkEidRequestWalletPairingPrimary)
          .font(.custom.title)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
          .accessibilityHeading(.h1)
          .accessibilityAddTraits(.isHeader)
          .accessibilityFocused($isHeaderFocused)
        Text(L10n.tkEidRequestWalletPairingSecondary)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
      }
      .multilineTextAlignment(.leading)
    }
    .listSectionSeparator(.hidden)
  }

  @ViewBuilder
  private func sectionAdditionalDevices() -> some View {
    Section {
      if viewModel.pairedDevicesCounter > 0 {
        HStack {
          Text(L10n.tkEidRequestWalletPairingAdditionalDeviceCounter(viewModel.pairedDevicesCounter))
          Spacer()
          checkmark()
            .accessibilityHidden(true)
        }
        .accessibilityElement(children: .combine)
        .padding(.vertical, .x2)
      }

      if !viewModel.isLimitReached {
        VStack {
          Button {
            Task {
              await viewModel.pairDevice(.other)
            }
          } label: {
            Text(L10n.tkEidRequestWalletPairingAdditionalDeviceButtonPrimary)
              .foregroundStyle(ThemingAssets.Brand.Accent.link.swiftUIColor)
          }
          .padding(.vertical, .x2)
          .accessibilitySortPriority(AccessibilityPriority.x4.rawValue)
        }
      }
    }
    header: { sectionHeader(L10n.tkEidRequestWalletPairingAdditionalDeviceSectionTitle) }
    footer: {
      if viewModel.isLimitReached {
        Text(L10n.tkEidRequestWalletPairingAdditionalDeviceSectionFooter)
          .font(.custom.footnote)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
          .padding(.top, .x1)
          .listRowSeparator(.hidden, edges: .bottom)
      }
    }
  }

  @ViewBuilder
  private func footer() -> some View {
    ButtonSheet {
      Button(action: viewModel.primaryAction, label: {
        Text(L10n.tkEidRequestWalletPairingButtonPrimary)
          .frame(maxWidth: .infinity)
      })
      .accessibilitySortPriority(AccessibilityPriority.x5.rawValue)
      .buttonStyle(.primary)
      .controlSize(.large)
      .disabled(viewModel.isPrimaryButtonDisabled)
    }
  }

  @ViewBuilder
  private func sectionHeader(_ text: String) -> some View {
    Text(text)
      .font(.custom.footnoteEmphasized)
      .textCase(.uppercase)
      .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
      .padding(.bottom, .x1)
  }

  @ViewBuilder
  private func checkmark() -> some View {
    Image(systemName: "checkmark.circle.fill")
      .foregroundStyle(ThemingAssets.Brand.Core.firGreen.swiftUIColor)
  }

  @ToolbarContentBuilder
  private func toolbarContent() -> some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button(action: viewModel.close, label: {
        ThemingAssets
          .close.swiftUIImage
      })
      .accessibilityLabel(L10n.tkGlobalClose)
      .accessibilityIdentifier(AccessibilityIdentifier.closeButton.rawValue)
    }
  }

}

// MARK: - Pair current device components

extension WalletPairingListView {

  @ViewBuilder
  private func sectionCurrentDevice() -> some View {
    Section {
      VStack {
        switch viewModel.currentDevicePairingState {
        case .initial: pairingCurrentDeviceButton()
        case .loading: pairingCurrentDeviceProgressView()
        case .paired(let currentDevicePairingDate): pairingCurrentDeviceResultView(date: currentDevicePairingDate)
        }
      }
      .padding(.vertical, .x2)
    }
    header: { sectionHeader(L10n.tkEidRequestWalletPairingCurrentDeviceSectionTitle) }
  }

  @ViewBuilder
  private func pairingCurrentDeviceButton() -> some View {
    Button {
      Task {
        await viewModel.pairDevice(.current)
      }
    } label: {
      Text(L10n.tkEidRequestWalletPairingCurrentDeviceButtonPrimary)
        .foregroundStyle(ThemingAssets.Brand.Accent.link.swiftUIColor)
    }
    .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
  }

  @ViewBuilder
  private func pairingCurrentDeviceProgressView() -> some View {
    HStack {
      ProgressView()
        .controlSize(.mini)

      Text(L10n.tkEidRequestWalletPairingCurrentDeviceLoadingTitle)
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
    }
  }

  @ViewBuilder
  private func pairingCurrentDeviceResultView(date: String) -> some View {
    HStack {
      #warning("Update the name of the device")
      Text("Device 1")
        .font(.custom.body)

      Spacer()

      HStack {
        Text(date)
          .font(.custom.body)
          .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)

        checkmark()
      }
    }
  }
}

#Preview {
  WalletPairingListView()
}
