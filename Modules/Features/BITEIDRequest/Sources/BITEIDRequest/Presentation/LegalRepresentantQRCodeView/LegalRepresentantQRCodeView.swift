import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - LegalRepresentantQRCodeView

struct LegalRepresentantQRCodeView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, caseId: String) {
    _viewModel = StateObject(wrappedValue: Container.shared.legalRepresentantQRCodeViewModel((router, caseId)))
  }

  // MARK: Internal

  var body: some View {
    InformationView(
      image: image(),
      backgroundColor: ThemingAssets.Background.secondary.swiftUIColor,
      content: {
        DefaultInformationContentView(
          primary: L10n.tkGetEidGuardianConsentPrimary,
          secondary: L10n.tkGetEidGuardianConsentSecondary)
      },
      footer: {
        viewFooter()
      })
      .task {
        await viewModel.getVerificationQRCode()
      }
  }

  // MARK: Private

  @StateObject private var viewModel: LegalRepresentantQRCodeViewModel

  private let qrCodeSize = 200.0
}

extension LegalRepresentantQRCodeView {

  @ViewBuilder
  private func image() -> some View {
    switch viewModel.state {
    case .loading: loadingView()
    case .error: errorView()
    case .result: qrCodeView()
    }
  }

  @ViewBuilder
  private func errorView() -> some View {
    VStack(spacing: .x6) {
      VStack {
        Assets.emergency.swiftUIImage
        Text(L10n.tkGetEidGuardianConsentQrError)
          .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
          .font(.custom.body)
          .multilineTextAlignment(.center)
      }

      Button(L10n.tkGetEidGuardianConsentQrButtonRetry) {
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
        .accessibilityLabel(L10n.tkGetEidGuardianConsentQrAlt)
    }
  }

  @ViewBuilder
  private func viewFooter() -> some View {
    if case .result(_, let qrCodeURL) = viewModel.state {
      ShareLink(item: qrCodeURL) {
        Button(action: { }) {
          Text(L10n.tkGetEidGuardianConsentButtonShare)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.bezeledLight)
        .controlSize(.large)
        .allowsHitTesting(false) // Disable the button without changing its background color
      }
      .disabled(viewModel.isShareQRCodeDisabled)
    } else {
      Button(action: { }) {
        Text(L10n.tkGetEidGuardianConsentButtonShare)
          .multilineTextAlignment(.center)
          .lineLimit(1)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bezeledLight)
      .controlSize(.large)
      .disabled(true)
    }

    Button(action: viewModel.finish) {
      Text(L10n.tkGetEidGuardianConsentButtonFinish)
        .multilineTextAlignment(.center)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
    .buttonStyle(.filledPrimary)
    .controlSize(.large)
  }
}

#Preview {
  LegalRepresentantQRCodeView(router: EIDRequestRouter(), caseId: "caseId")
}
