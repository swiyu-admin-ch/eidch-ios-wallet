import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI
import UIKit

struct OTPEmailView: View {

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case emailField
    case emailFieldError
    case continueButton
  }

  var body: some View {
    ZStack {
      ThemingAssets.Background.system.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()

      Form {
        Section(footer: sectionFooter) {
          emailCard
        }
        .textCase(nil)
      }
      .formStyle(.grouped)
      .scrollContentBackground(.hidden)
      .frame(maxWidth: 635)
    }
    .navigationTitle(L10n.tkEidRequestOtpEmailTitle)
    .navigationBarTitleDisplayMode(.inline)
    .navigationCheckpoint(OTPCheckpoints.email)
    .navigate(to: $viewModel.destination)
    .disabled(viewModel.isSubmitting)
    .safeAreaInset(edge: .bottom) {
      footer
    }
    .toast(
      Binding(
        get: { viewModel.toast },
        set: { viewModel.toast = $0 }))
    .loadingOverlay(
      isPresented: viewModel.isSubmitting,
      message: L10n.tkPresentReviewLoading,
      accessibility: .voiceOver())
    .toolbar {
      CloseButtonToolbar {
        navigator.dismiss()
      }
    }
    .task {
      guard !viewModel.isSubmitting else { return }
      focusEmailField()
    }
    .onChange(of: viewModel.errorMessage) { _, errorMessage in
      guard let errorMessage else { return }
      announce(errorMessage)
      focusEmailField(forceAccessibilityFocus: true)
    }
    .onChange(of: viewModel.isSubmitting) { _, isSubmitting in
      guard isSubmitting == false, viewModel.errorMessage != nil else { return }
      Task { @MainActor in
        try? await Task.sleep(nanoseconds: 200_000_000)
        focusEmailField()
      }
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @FocusState private var isEmailFieldFocused: Bool
  @AccessibilityFocusState private var isEmailFieldAccessibilityFocused: Bool

  @InjectedObservable(\.otpEmailViewModel) private var viewModel

  private var emailCard: some View {
    VStack(alignment: .leading, spacing: .x2) {
      Text(L10n.tkEidRequestOtpEmailFieldTitle)
        .font(.custom.bodyEmphasized)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityHidden(true)

      TextField(L10n.tkEidRequestOtpEmailFieldPlaceholder, text: Binding(
        get: { viewModel.email },
        set: viewModel.onEmailChange))
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .keyboardType(.emailAddress)
        .textContentType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused($isEmailFieldFocused)
        .accessibilityFocused($isEmailFieldAccessibilityFocused)
        .submitLabel(.send)
        .accessibilityLabel(L10n.tkEidRequestOtpEmailFieldTitle)
        .accessibilityIdentifier(AccessibilityIdentifier.emailField.rawValue)
        .onSubmit {
          guard viewModel.isSubmitEnabled else { return }
          Task {
            await viewModel.submit()
          }
        }

      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
          .font(.custom.caption1)
          .foregroundStyle(ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor)
          .accessibilityIdentifier(AccessibilityIdentifier.emailFieldError.rawValue)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var sectionFooter: some View {
    VStack(alignment: .leading, spacing: .x4) {
      Text(L10n.tkEidRequestOtpEmailBodyPrimary)
      Text(L10n.tkEidRequestOtpEmailBodySecondary)
    }
    .font(.custom.footnote)
    .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
    .fixedSize(horizontal: false, vertical: true)
    .accessibilityElement(children: .combine)
  }

  private var footer: some View {
    VStack(spacing: .x2) {
      Button {
        Task {
          await viewModel.submit()
        }
      } label: {
        Text(L10n.tkGlobalContinue)
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.primary)
      .controlSize(.large)
      .disabled(!viewModel.isSubmitEnabled)
      .accessibilityHidden(!viewModel.isSubmitEnabled)
      .accessibilityIdentifier(AccessibilityIdentifier.continueButton.rawValue)
    }
    .padding(.vertical, .x2)
    .padding(.horizontal, .x6)
    .frame(maxWidth: 635)
  }

  private func focusEmailField(forceAccessibilityFocus: Bool = false) {
    isEmailFieldFocused = true
    if forceAccessibilityFocus || UIAccessibility.isVoiceOverRunning == false {
      isEmailFieldAccessibilityFocused = true
    }
  }

  private func announce(_ message: String) {
    var announcement = AttributedString(message)
    announcement.accessibilitySpeechAnnouncementPriority = .high
    AccessibilityNotification.Announcement(announcement).post()
  }
}

#Preview {
  OTPEmailView()
}
