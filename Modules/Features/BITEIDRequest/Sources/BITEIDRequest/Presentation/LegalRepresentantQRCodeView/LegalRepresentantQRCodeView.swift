import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - LegalRepresentantQRCodeView

struct LegalRepresentantQRCodeView: View {

  // MARK: Lifecycle

  init(caseId: String) {
    _viewModel = State(initialValue: Container.shared.legalRepresentantQRCodeViewModel(caseId))
  }

  // MARK: Internal

  var body: some View {
    InformationView2(
      contents: [
        .heroCard { card() },
        .title(L10n.tkEidRequestGuardianConsentPrimary, identifier: "primaryText"),
        .body(L10n.tkEidRequestGuardianConsentSecondary, identifier: "secondaryText"),
      ],
      actions: actions)
      .toolbar(.visible)
      .navigationDismiss(trigger: $viewModel.isNavigationCloseTriggered)
      .navigate(to: $viewModel.destination)
      .task {
        await viewModel.getVerificationQRCode()
      }
  }

  // MARK: Private

  @State private var viewModel: LegalRepresentantQRCodeViewModel

  private let qrCodeSize = 200.0
}

extension LegalRepresentantQRCodeView {

  private var actions: [InformationView2.ActionType] {
    [
      .anyView { shareActionView() },
      .primaryAsync(L10n.tkEidRequestGuardianConsentButtonFinish, actionOptions: [.showProgressView], { _ in
        await viewModel.finish()
      }),
    ]
  }

  private func card() -> some View {
    Card(background: .color(ThemingAssets.Background.secondary.swiftUIColor)) {
      switch viewModel.state {
      case .loading: loadingView()
      case .error: errorView()
      case .result: qrCodeView()
      }
    }
  }

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
  private func shareActionView() -> some View {
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
  }
}

#Preview {
  LegalRepresentantQRCodeView(caseId: "caseId")
}
