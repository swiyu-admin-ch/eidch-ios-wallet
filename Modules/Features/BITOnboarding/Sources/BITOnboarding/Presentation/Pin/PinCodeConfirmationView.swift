import BITL10n
import BITTheming
import Factory
import Foundation
import SwiftUI

// MARK: - PinCodeConfirmationView

struct PinCodeConfirmationView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    _viewModel = State(initialValue: Container.shared.pinCodeConfirmationViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "pinCodeConfirmationContent"
    case pinField
    case continueButton
    case wrongPinError
  }

  var body: some View {
    content()
      .navigationTitle(L10n.tkOnboardingPasswordConfirmationTitle)
      .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
      .background(
        ThemingAssets.Gradient.gradient4.swiftUIImage
          .resizable()
          .ignoresSafeArea()
          .accessibilityHidden(true))
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  @State private var viewModel: PinCodeConfirmationViewModel
  @FocusState private var inputFocused: Bool
  @Environment(\.sizeCategory) private var sizeCategory

  @Orientation private var orientation

  private func content() -> some View {
    ScrollView {
      VStack {
        if orientation.isLandscape {
          landscapeLayout()
        } else {
          portraitLayout()
        }
      }
      .frame(maxWidth: .infinity)
      .multilineTextAlignment(.center)
      .padding(.horizontal, .x6)
      .padding(.vertical, .x2)
    }
    .safeAreaInset(edge: .bottom) {
      if !orientation.isLandscape {
        footerView()
      }
    }
  }

  private func landscapeLayout() -> some View {
    VStack(alignment: .leading) {
      HStack {
        secureField()

        continueButton()
          .buttonStyle(.primary)
      }

      if let message = viewModel.inputFieldMessage {
        inputFieldMessage(message)
          .padding(.horizontal, .x3)
      }
    }
  }

  @ViewBuilder
  private func portraitLayout() -> some View {
    VStack(alignment: .leading) {
      secureField()

      if let message = viewModel.inputFieldMessage {
        inputFieldMessage(message)
          .padding(.horizontal, .x3)
      }
    }
    .padding(.top, sizeCategory.isAccessibilityCategory ? 0 : 100)

    Spacer()
  }

  private func footerView() -> some View {
    HStack {
      Spacer()

      continueButton()
        .accessibilitySortPriority(600)
    }
    .padding(.horizontal, .x6)
    .padding(.vertical, .x2)
  }

  private func secureField() -> some View {
    SecureTextField(
      text: $viewModel.pinCode,
      prompt: L10n.tkOnboardingPasswordConfirmationInputPlaceholder,
      textColor: ThemingAssets.Label.primary.light,
      tintColor: ThemingAssets.Label.secondary.light)
    {
      viewModel.validate()
    }
    .submitLabel(.done)
    .frame(height: 52)
    .padding(.horizontal, .x3)
    .background(ThemingAssets.Grays.white.swiftUIColor)
    .cornerRadius(10)
    .focused($inputFocused)
    .modifier(ShakeEffect(animatableData: CGFloat(viewModel.attempts)))
    .onAppear {
      inputFocused = false
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
        inputFocused = true
      }
    }
    .accessibilityLabel(L10n.tkOnboardingPasswordConfirmationInputAlt)
    .accessibilitySortPriority(800)
    .secureTextFieldAccessibilityIdentifier(AccessibilityIdentifier.pinField.rawValue)
  }

  private func continueButton() -> some View {
    Button {
      viewModel.validate()
    } label: {
      Text(L10n.tkGlobalContinue)
    }
    .environment(\.colorScheme, .light)
    .buttonStyle(.primary)
    .controlSize(.large)
    .accessibilityIdentifier(AccessibilityIdentifier.continueButton.rawValue)
  }

  private func inputFieldMessage(_ message: String) -> some View {
    Text(message)
      .font(.custom.footnote)
      .multilineTextAlignment(.leading)
      .accessibilitySortPriority(700)
      .accessibilityIdentifier(AccessibilityIdentifier.wrongPinError.rawValue)
  }

}

#Preview {
  PinCodeConfirmationView(router: OnboardingRouter())
}
