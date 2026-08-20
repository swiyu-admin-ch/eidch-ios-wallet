import BITL10n
import BITNavigation
import BITQRCode
import BITTheming
import Factory
import SwiftUI

// MARK: - ProximityEngagementView

struct ProximityEngagementView: View {

  // MARK: Lifecycle

  init() {
    _viewModel = State(wrappedValue: Container.shared.proximityEngagementViewModel())
  }

  // MARK: Internal

  var body: some View {
    Content(
      qrCodePayload: viewModel.qrCodePayload,
      isErrorPopupPresented: $viewModel.isErrorPopupPresented,
      error: $viewModel.error,
      closeAction: { navigator.returnToHomeSafely() },
      closeErrorViewAction: viewModel.closeErrorView)
      .navigate(to: $viewModel.destination)
      .bluetoothPermission { state in
        if state == .authorized {
          viewModel.start()
        }
      }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @State private var viewModel: ProximityEngagementViewModel
}

// MARK: ProximityEngagementView.Content

extension ProximityEngagementView {
  fileprivate struct Content: View {

    // MARK: Lifecycle

    init(
      qrCodePayload: String?,
      isErrorPopupPresented: Binding<Bool>,
      error: Binding<Error?>,
      closeAction: @escaping () -> Void = {},
      closeErrorViewAction: @escaping () -> Void = {})
    {
      self.qrCodePayload = qrCodePayload
      self.closeAction = closeAction
      self.closeErrorViewAction = closeErrorViewAction
      self.isErrorPopupPresented = isErrorPopupPresented
      self.error = error
    }

    // MARK: Internal

    let tipViewMaxWidth: CGFloat = 350

    var body: some View {
      AdaptiveColumnsView(
        primaryContent: qrCodeCard,
        secondaryContent: qrText)
        .onAppear {
          UIAccessibility.post(notification: .screenChanged, argument: L10n.tkProximityEngagementTitle)
        }
        .background {
          ThemingAssets.Background.secondary.swiftUIColor
            .ignoresSafeArea()
        }
        .popup(isPresented: isErrorPopupPresented) {
          if let error = error.wrappedValue {
            if orientation.isPortrait {
              errorView(error)
            } else {
              HStack {
                Spacer()
                errorView(error)
              }
            }
          }
        } customize: {
          $0.type(.floater())
            .appearFrom(.bottomSlide)
            .autohideIn(voiceOverEnabled ? nil : 7)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .navigationTitle(L10n.tkProximityEngagementTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Private

    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled

    @Orientation private var orientation

    private let qrCodePayload: String?
    private let closeAction: () -> Void
    private let closeErrorViewAction: () -> Void
    private let isErrorPopupPresented: Binding<Bool>
    private let error: Binding<Error?>

    private func qrText() -> some View {
      Text(L10n.tkProximityEngagementPrimary)
        .font(.custom.footnote)
        .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
        .multilineTextAlignment(.center)
        .padding(.horizontal, .x8)
    }

    private func qrCodeCard() -> some View {
      Card(background: .color(ThemingAssets.Brand.Core.white.swiftUIColor)) {
        ZStack {
          EdrQRCodeView(content: qrCodePayload ?? "", correctionLevel: .medium)
            .aspectRatio(1, contentMode: .fit)
            .opacity(qrCodePayload == nil ? 0 : 1)
            .accessibilityLabel(L10n.tkProximityEngagementQrCodeAltText)
            .accessibilityHidden(qrCodePayload == nil)
          progressView()
            .opacity(qrCodePayload == nil ? 1 : 0)
            .accessibilityHidden(qrCodePayload != nil)
        }
      }
      .padding(.horizontal, .x4)
      .accessibilityElement(children: .combine)
    }

    private func progressView() -> some View {
      ProgressViewLabelBadge(
        text: L10n.tkGlobalPleasewait,
        background: ThemingAssets.Background.tertiary.swiftUIColor,
        foreground: ThemingAssets.Label.primary.swiftUIColor,
        accessibilityLabel: L10n.tkQrscannerProcessingAlt)
    }

    @ViewBuilder
    private func errorView(_ error: Error) -> some View {
      let invitationError = error as? InvitationError ?? .invalidQRCode()
      Notification(
        image: invitationError.icon,
        imageColor: ThemingAssets.Label.primary.swiftUIColor,
        title: invitationError.primaryText,
        titleColor: ThemingAssets.Label.primary.swiftUIColor,
        content: invitationError.secondaryText ?? String(),
        contentColor: ThemingAssets.Label.secondary.swiftUIColor,
        closeAction: closeErrorViewAction,
        background: ThemingAssets.Background.tertiary.swiftUIColor,
        closeButtonStyle: .secondary)
        .frame(maxWidth: orientation.isPortrait ? .infinity : tipViewMaxWidth)
        .padding(.horizontal, orientation.isPortrait ? .x3 : .x1)
    }
  }
}

#if DEBUG
#Preview {
  NavigationStack {
    ProximityEngagementView.Content(qrCodePayload: "https://swiyu", isErrorPopupPresented: .constant(false), error: .constant(nil))
  }
}
#endif
