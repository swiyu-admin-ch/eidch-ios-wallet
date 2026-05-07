import BITL10n
import BITNavigation
import BITTheming
import Factory
import NavigatorUI
import SwiftUI
import UIKit

struct OTPCodeView: View {

  // MARK: Lifecycle

  init(email: String, onToastMessage: @escaping (String) -> Void = { _ in }) {
    _viewModel = State(initialValue: Container.shared.otpCodeViewModel((email, Callback<String>(handler: onToastMessage))))
  }

  // MARK: Internal

  enum AccessibilityIdentifier: String {
    case codeField
    case codeFieldError
  }

  var body: some View {
    ZStack {
      ThemingAssets.Background.system.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()

      Form {
        Section(footer: sectionFooter) {
          codeCard
        }
        .textCase(nil)
      }
      .formStyle(.grouped)
      .scrollContentBackground(.hidden)
      .frame(maxWidth: 635)
    }
    .navigationTitle(L10n.tkEidRequestOtpCodeTitle)
    .navigationBarTitleDisplayMode(.inline)
    .navigate(to: $viewModel.destination)
    .navigationBack(onChangeOf: $viewModel.isBackTriggered)
    .disabled(viewModel.isSubmitting)
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
      focusCodeField()
    }
    .onChange(of: viewModel.errorMessage) { _, errorMessage in
      guard let errorMessage else { return }
      var announcement = AttributedString(errorMessage)
      announcement.accessibilitySpeechAnnouncementPriority = .high
      AccessibilityNotification.Announcement(announcement).post()
      focusCodeField()
    }
    .onChange(of: viewModel.isSubmitting) { _, isSubmitting in
      guard isSubmitting == false, viewModel.errorMessage != nil else { return }
      Task { @MainActor in
        try? await Task.sleep(nanoseconds: 200_000_000)
        focusCodeField()
      }
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator
  @FocusState private var isCodeFieldFocused: Bool

  @State private var viewModel: OTPCodeViewModel

  private var codeCard: some View {
    VStack(alignment: .leading, spacing: .x2) {
      Text(L10n.tkEidRequestOtpCodeFieldTitle)
        .font(.custom.bodyEmphasized)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityHidden(true)

      TextField(L10n.tkEidRequestOtpCodeFieldPlaceholder, text: Binding(
        get: { viewModel.code },
        set: viewModel.onCodeChange))
        .font(.custom.body)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .keyboardType(.numberPad)
        .textContentType(.oneTimeCode)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .focused($isCodeFieldFocused)
        .submitLabel(.send)
        .accessibilityLabel(L10n.tkEidRequestOtpCodeFieldTitle)
        .accessibilityIdentifier(AccessibilityIdentifier.codeField.rawValue)
        .onSubmit {
          Task {
            await viewModel.submit()
          }
        }

      if let errorMessage = viewModel.errorMessage {
        Text(errorMessage)
          .font(.custom.caption1)
          .foregroundStyle(ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor)
          .accessibilityIdentifier(AccessibilityIdentifier.codeFieldError.rawValue)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var sectionFooter: some View {
    VStack(alignment: .leading, spacing: .x4) {
      Text(LocalizedStringKey(L10n.tkEidRequestOtpCodeBodySent(viewModel.email)))
      Text(L10n.tkEidRequestOtpCodeBodyValidity)
      Text(L10n.tkEidRequestOtpCodeBodyHelp)
    }
    .font(.custom.footnote)
    .foregroundStyle(ThemingAssets.Label.secondary.swiftUIColor)
    .fixedSize(horizontal: false, vertical: true)
    .accessibilityElement(children: .combine)
  }

  private func focusCodeField() {
    isCodeFieldFocused = true
  }
}

#Preview {
  OTPCodeView(email: "firstname.lastname@example.admin.ch")
}
