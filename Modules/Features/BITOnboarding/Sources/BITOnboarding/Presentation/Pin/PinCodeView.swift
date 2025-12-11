import BITL10n
import BITTheming
import Factory
import PopupView
import SwiftUI

// MARK: - PinCodeView

struct PinCodeView: View {

  // MARK: Lifecycle

  init(router: OnboardingInternalRoutes) {
    _viewModel = StateObject(wrappedValue: Container.shared.pinCodeViewModel(router))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "pinCodeContent"
    case pinField
    case continueButton
    case errorMessage
  }

  var body: some View {
    content()
      .navigationTitle(L10n.tkOnboardingPasswordTitle)
      .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
      .background(
        ThemingAssets.Gradient.gradient4.swiftUIImage
          .resizable()
          .ignoresSafeArea()
          .accessibilityHidden(true))
      .task {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          focus = .input
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Private

  private enum Defaults {
    static let errorAnimation = Animation.interpolatingSpring(stiffness: 500, damping: 30)
  }

  private enum Focus: Hashable {
    case input, inputText, continueButton, error
  }

  @StateObject private var viewModel: PinCodeViewModel
  @FocusState private var inputFocused: Bool
  @AccessibilityFocusState private var focus: Focus?
  @Environment(\.sizeCategory) private var sizeCategory

  @Orientation private var orientation

  @ViewBuilder
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

  @ViewBuilder
  private func landscapeLayout() -> some View {
    VStack(alignment: .leading) {
      HStack {
        secureField()

        continueButton()
      }

      inputFieldMessage(viewModel.inputFieldMessage)
        .padding(.horizontal, .x3)
    }
  }

  @ViewBuilder
  private func portraitLayout() -> some View {
    VStack(alignment: .leading) {
      secureField()

      inputFieldMessage(viewModel.inputFieldMessage)
        .padding(.horizontal, .x3)
    }
    .padding(.top, sizeCategory.isAccessibilityCategory ? 0 : 100)
    .accessibilityElement(children: .combine)

    Spacer()
  }

  @ViewBuilder
  private func footerView() -> some View {
    HStack {
      Spacer()

      continueButton()
        .accessibilitySortPriority(600)
    }
    .padding(.horizontal, .x6)
    .padding(.bottom, .x4)
  }

  @ViewBuilder
  private func secureField() -> some View {
    SecureTextField(
      text: $viewModel.pinCode,
      prompt: L10n.tkOnboardingPasswordInputPlaceholder,
      textColor: ThemingAssets.Label.primary.light,
      tintColor: ThemingAssets.Label.tertiary.light)
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
    .accessibilityLabel(L10n.tkOnboardingPasswordInputAlt)
    .accessibilitySortPriority(800)
    .accessibilityFocused($focus, equals: .input)
    .secureTextFieldAccessibilityIdentifier(AccessibilityIdentifier.pinField.rawValue)
  }

  @ViewBuilder
  private func continueButton() -> some View {
    Button {
      viewModel.validate()
    } label: {
      Text(L10n.tkGlobalContinue)
    }
    .environment(\.colorScheme, .light)
    .buttonStyle(.primary)
    .controlSize(.large)
    .accessibilityFocused($focus, equals: .continueButton)
    .accessibilityIdentifier(AccessibilityIdentifier.continueButton.rawValue)
  }

  @ViewBuilder
  private func inputFieldMessage(_ message: String) -> some View {
    Text(message)
      .font(.custom.footnote)
      .multilineTextAlignment(.leading)
      .accessibilitySortPriority(700)
      .accessibilityFocused($focus, equals: .inputText)
      .accessibilityIdentifier(AccessibilityIdentifier.errorMessage.rawValue)
  }

}

#Preview {
  PinCodeView(router: OnboardingRouter())
}
