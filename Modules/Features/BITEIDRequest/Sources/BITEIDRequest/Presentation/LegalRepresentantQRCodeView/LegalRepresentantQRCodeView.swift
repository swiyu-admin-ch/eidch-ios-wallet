import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - LegalRepresentantQRCodeView

struct LegalRepresentantQRCodeView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    _viewModel = StateObject(wrappedValue: Container.shared.legalRepresentantQRCodeViewModel(caseId))
  }

  // MARK: Internal

  var body: some View {
    AdaptiveColumnsView(primaryContent: card) {
      DefaultInformationContentView(
        primary: L10n.tkEidRequestGuardianConsentPrimary,
        secondary: L10n.tkEidRequestGuardianConsentSecondary)
        .padding(.horizontal, .x6)
    } footer: {
      viewFooter()
    }
    .toolbar(.visible)
    .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
    .navigate(to: $viewModel.destination)
    .task {
      await viewModel.getVerificationQRCode()
    }
  }

  // MARK: Private

  @StateObject private var viewModel: LegalRepresentantQRCodeViewModel
  @Environment(\.navigator) private var navigator

  private let qrCodeSize = 200.0
}

extension LegalRepresentantQRCodeView {

  @ViewBuilder
  private func card() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
      switch viewModel.state {
      case .loading: loadingView()
      case .error: errorView()
      case .result: qrCodeView()
      }
    }
  }

  @ViewBuilder
  private func errorView() -> some View {
    VStack(spacing: .x6) {
      VStack {
        Assets.emergency.swiftUIImage
          .accessibilityHidden(true)
        Text(L10n.tkEidRequestGuardianConsentQrError)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .font(.custom.body)
          .multilineTextAlignment(.center)
      }

      Button(L10n.tkEidRequestGuardianConsentQrButtonRetry) {
        Task {
          await viewModel.getVerificationQRCode()
        }
      }
      .buttonStyle(.bezeled)
    }
    .frame(maxWidth: qrCodeSize)
  }

  @ViewBuilder
  private func loadingView() -> some View {
    ProgressView()
      .controlSize(.large)
  }

  @ViewBuilder
  private func qrCodeView() -> some View {
    if case .result(let imageData, _) = viewModel.state {
      Image(data: imageData)
        .frame(maxWidth: qrCodeSize, maxHeight: qrCodeSize)
        .accessibilityLabel(L10n.tkEidRequestGuardianConsentQrAlt)
    }
  }

  @ViewBuilder
  private func viewFooter() -> some View {
    ButtonSheet {
      VStack(spacing: .x4) {
        if case .result(_, let qrCodeURL) = viewModel.state {
          ShareLink(item: qrCodeURL) {
            Button(action: { }) {
              Text(L10n.tkEidRequestGuardianConsentButtonShare)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.secondary)
            .controlSize(.large)
            .allowsHitTesting(false) // Disable the button without changing its background color
          }
          .disabled(viewModel.isShareQRCodeDisabled)
        } else {
          Button(action: { }) {
            Text(L10n.tkEidRequestGuardianConsentButtonShare)
              .multilineTextAlignment(.leading)
              .frame(maxWidth: .infinity)
          }
          .buttonStyle(.secondary)
          .controlSize(.large)
          .disabled(true)
        }

        AsyncButton(
          action: { await viewModel.finish() },
          actionOptions: [.showProgressView],
          label: {
            Text(L10n.tkEidRequestGuardianConsentButtonFinish)
              .multilineTextAlignment(.leading)
          })
          .buttonStyle(.primary)
          .controlSize(.large)
      }
    }
  }
}

#Preview {
  LegalRepresentantQRCodeView(caseId: "caseId")
}
