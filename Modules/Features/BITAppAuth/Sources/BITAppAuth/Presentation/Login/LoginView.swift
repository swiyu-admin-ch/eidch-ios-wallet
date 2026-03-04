import BITCore
import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - LoginView

public struct LoginView: View {

  // MARK: Lifecycle

  public init(viewModel: LoginViewModel) {
    _viewModel = StateObject(wrappedValue: viewModel)
  }

  // MARK: Public

  public var body: some View {
    content()
      .foregroundStyle(ThemingAssets.Grays.white.swiftUIColor)
      .background(
        ThemingAssets.Gradient.gradient4.swiftUIImage
          .resizable()
          .ignoresSafeArea()
          .accessibilityHidden(true))
      .task {
        UIAccessibility.post(notification: .screenChanged, argument: L10n.tkLoginPasswordAlt)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
          focus = .input
        }
      }
      .accessibilityElement(children: .contain)
      .accessibilityIdentifier(AccessibilityIdentifier.content.rawValue)
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case content = "loginContent"
    case loginButton
    case pinField
  }

  // MARK: Private

  private enum Focus: Hashable {
    case title, subtitle, input, inputText, loginButton, biometricButton, helpButton
  }

  @Environment(\.sizeCategory) private var sizeCategory
  @FocusState private var inputFocused: Bool
  @AccessibilityFocusState private var focus: Focus?
  @StateObject private var viewModel: LoginViewModel

  @Orientation private var orientation

  private func content() -> some View {
    VStack {
      switch viewModel.state {
      case .loginBiometrics:
        loginBiometricsView()
          .task {
            viewModel.biometricViewDidAppear()
          }
      case .loginPassword:
        loginPasswordView()
      case .locked:
        lockedView()
      case .loading:
        loadingView()
      }
    }
  }
}

// MARK: - Loading

extension LoginView {

  private func loadingView() -> some View {
    VStack {
      Spacer()
      ProgressView()
        .controlSize(.large)
        .tint(ThemingAssets.Grays.white.swiftUIColor)
      Spacer()
    }
    .frame(maxWidth: .infinity)
  }

}

// MARK: - Locked

extension LoginView {

  private func lockedView() -> some View {
    VStack {
      Spacer()
      VStack(spacing: .x2) {
        Spacer()
        Assets.lock.swiftUIImage
          .accessibilityHidden(true)
        Text(L10n.tkLoginLockedTitle)
          .font(.custom.title)
          .accessibilitySortPriority(1000)
          .accessibilityFocused($focus, equals: .title)
          .multilineTextAlignment(.center)
        if let timeLeft = viewModel.timeLeft {
          Text(timeLeft)
            .multilineTextAlignment(.center)
            .accessibilitySortPriority(900)
            .accessibilityFocused($focus, equals: .subtitle)
        }
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .padding([.horizontal, .bottom], .x4)
      .padding(.top, .x2)
      .accessibilityElement(children: .combine)

      Spacer()

      Group {
        if orientation.isLandscape {
          HStack(spacing: .x2) {
            Spacer()
            lockedViewFooter()
            Spacer()
          }
        } else {
          lockedViewFooter()
            .padding(.bottom, .x4)
        }
      }
      .padding(.horizontal, .x3)
      .padding(.bottom, .x1)
    }
  }

  @ViewBuilder
  private func lockedViewFooter() -> some View {
    if viewModel.isBiometricAuthenticationAvailable {
      biometricButton()
        .buttonStyle(.primary)
        .accessibilitySortPriority(800)
        .controlSize(.large)
    }

    Button {
      viewModel.openHelp()
    } label: {
      Text(L10n.tkLoginLockedSecondarybuttonText)
    }
    .buttonStyle(.secondary)
    .environment(\.colorScheme, .light)
    .controlSize(.large)
    .accessibilitySortPriority(700)
    .accessibilityFocused($focus, equals: .helpButton)
  }

}

// MARK: - Login Biometrics

extension LoginView {

  private func loginBiometricsView() -> some View {
    VStack {
      Spacer()
      VStack {
        Assets.login.swiftUIImage
          .accessibilityHidden(true)
        Text(L10n.tkGlobalWelcomeback)
          .font(.custom.title)
          .accessibilityFocused($focus, equals: .title)
        Text(L10n.tkLoginVariantBody)
          .accessibilityFocused($focus, equals: .subtitle)
      }
      .accessibilityElement(children: .combine)
      Spacer()
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
    .padding(.x6)
  }

}

// MARK: - Login Password

extension LoginView {

  private func loginPasswordView() -> some View {
    ScrollView {
      VStack {
        if orientation.isLandscape {
          loginLandscapeLayout()
        } else {
          loginPortraitLayout()
        }
      }
      .frame(maxWidth: .infinity)
      .multilineTextAlignment(.center)
      .padding(.horizontal, .x6)
      .padding(.vertical, .x2)
    }
    .safeAreaInset(edge: .bottom) {
      if !orientation.isLandscape {
        loginFooterView()
      }
    }
  }

  private func loginLandscapeLayout() -> some View {
    VStack(alignment: .leading) {
      HStack {
        secureField()

        loginButton()

        if viewModel.isBiometricAuthenticationAvailable {
          biometricButton()
            .buttonStyle(.secondary)
        }
      }

      attemptsMessageView()
        .padding(.horizontal, .x3)
    }
  }

  @ViewBuilder
  private func loginPortraitLayout() -> some View {
    VStack {
      if !sizeCategory.isAccessibilityCategory {
        Assets.login.swiftUIImage
          .accessibilityHidden(true)
      }
      Text(L10n.tkGlobalWelcomeback)
        .font(.custom.title)
        .accessibilityFocused($focus, equals: .title)
      Text(L10n.tkLoginFacenotrecognised2Body)
        .accessibilityFocused($focus, equals: .subtitle)
    }
    .accessibilityElement(children: .combine)

    VStack(alignment: .leading) {
      secureField()
      attemptsMessageView()
        .padding(.horizontal, .x3)
    }
    .accessibilityElement(children: .combine)

    Spacer()
  }

  private func loginFooterView() -> some View {
    HStack {
      if viewModel.isBiometricAuthenticationAvailable {
        biometricButton()
          .buttonStyle(.secondary)
          .accessibilitySortPriority(500)
      }

      Spacer()

      loginButton()
        .accessibilitySortPriority(600)
    }
    .padding(.horizontal, .x6)
    .padding(.vertical, .x2)
  }

  private func secureField() -> some View {
    SecureTextField(
      text: $viewModel.pinCode,
      prompt: L10n.tkLoginPasswordNote,
      textColor: ThemingAssets.Label.primary.light,
      tintColor: ThemingAssets.Label.tertiary.light)
    {
      viewModel.pinCodeAuthentication()
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
    .onChange(of: viewModel.attemptsLeft) { _ in
      UIAccessibility.post(notification: .announcement, argument: viewModel.inputFieldMessage)
    }
    .accessibilitySortPriority(800)
    .accessibilityFocused($focus, equals: .input)
    .secureTextFieldAccessibilityIdentifier(AccessibilityIdentifier.pinField.rawValue)
  }

  @ViewBuilder
  private func attemptsMessageView() -> some View {
    if viewModel.attemptsLeft < viewModel.attemptsLimit {
      Text(viewModel.inputFieldMessage)
        .font(.custom.footnote)
        .multilineTextAlignment(.leading)
        .accessibilitySortPriority(700)
        .accessibilityFocused($focus, equals: .inputText)
    }
  }

}

// MARK: - General

extension LoginView {

  private func biometricButton() -> some View {
    Button {
      Task {
        await viewModel.promptBiometricAuthentication()
      }
    } label: {
      if viewModel.state == .locked {
        Label(L10n.tkGlobalLoginfaceidPrimarybutton(viewModel.biometricType.text), systemImage: viewModel.biometricType.icon)
      } else {
        viewModel.biometricType.image
          .padding(2)
      }
    }
    .controlSize(.large)
    .accessibilityFocused($focus, equals: .biometricButton)
    .environment(\.colorScheme, .light)
  }

  private func loginButton() -> some View {
    Button {
      viewModel.pinCodeAuthentication()
    } label: {
      Text(L10n.tkGlobalLoginPrimarybutton)
    }
    .environment(\.colorScheme, .light)
    .buttonStyle(.primary)
    .controlSize(.large)
    .accessibilityFocused($focus, equals: .loginButton)
    .accessibilityIdentifier(AccessibilityIdentifier.loginButton.rawValue)
  }

}

#if DEBUG
#Preview {
  LoginView(viewModel: LoginViewModel(router: LoginRouter(), state: .locked))
}
#endif
