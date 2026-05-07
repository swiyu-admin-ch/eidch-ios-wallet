import BITL10n
import BITTheming
import Factory
import Foundation
import NavigatorUI
import Observation

// MARK: - OTPEmailViewModel

@MainActor
@Observable
class OTPEmailViewModel {

  // MARK: Lifecycle

  init() { }

  // MARK: Internal

  var email = ""
  var errorMessage: String?
  var isEmailFormatValid = false
  var isSubmitting = false
  var destination: OTPDestinations?
  var toast: Toast?

  var isSubmitEnabled: Bool {
    isEmailFormatValid && !isSubmitting && errorMessage == nil
  }

  func onEmailChange(_ value: String) {
    let normalizedValue = normalize(value)
    guard normalizedValue != email else { return }

    email = normalizedValue
    errorMessage = nil
    debounceValidation()
  }

  func submit() async {
    let normalizedEmail = normalize(email)
    email = normalizedEmail

    guard validate(normalizedEmail) else {
      return
    }

    isSubmitting = true
    errorMessage = nil
    defer { isSubmitting = false }

    do {
      try await requestOTPUseCase(email: normalizedEmail)
      destination = .code(email: normalizedEmail, onToastMessage: Callback<String> { [weak self] message in
        Task { @MainActor in
          self?.showToast(message)
        }
      })
    } catch let error as OTPError {
      handle(error)
    } catch {
      handle(.unknown)
    }
  }

  func skip() {
    destination = .external(.eidRequest)
  }

  func clearToast() {
    toast = nil
  }

  // MARK: Private

  private static let emailRegex = #/^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/#

  @ObservationIgnored @Injected(\.requestOTPUseCase) private var requestOTPUseCase

  @ObservationIgnored private var validationTask: Task<Void, Never>?

  private func validate(_ email: String) -> Bool {
    isEmailFormatValid = !email.isEmpty && email.wholeMatch(of: Self.emailRegex) != nil
    return isEmailFormatValid
  }

  private func debounceValidation() {
    validationTask?.cancel()
    validationTask = Task { [weak self] in
      try? await Task.sleep(nanoseconds: 300_000_000)
      guard let self, !Task.isCancelled else { return }

      _ = validate(email)
    }
  }

  private func normalize(_ value: String) -> String {
    value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
  }

  private func showToast(_ message: String) {
    toast = Toast(message, type: .error)
  }

  private func handle(_ error: OTPError) {
    switch error {
    case .serviceDeactivated:
      destination = .error(.OTP.unavailable)
    case .forbiddenEmail,
         .invalidFormat:
      errorMessage = error.inlineMessage
    case .invalidClientAttestation:
      destination = .error(.Setup.clientAttestation)
    case .otpExpired,
         .tooManyRequests,
         .unknown:
      destination = .error(.retry(error, retryAction))
    }
  }

  private func retryAction(_ navigator: Navigator) {
    destination = nil
    isSubmitting = false
    navigator.pop()
  }
}

// MARK: - OTPError + LocalizedError

extension OTPError: LocalizedError {
  var inlineMessage: String? {
    switch self {
    case .invalidFormat:
      L10n.tkEidRequestOtpEmailErrorInvalidFormat
    case .forbiddenEmail:
      L10n.tkEidRequestOtpEmailErrorForbidden
    case .invalidClientAttestation,
         .otpExpired,
         .serviceDeactivated,
         .tooManyRequests,
         .unknown:
      nil
    }
  }

  var errorDescription: String? {
    switch self {
    case .invalidFormat:
      L10n.tkEidRequestOtpEmailErrorInvalidFormat
    case .forbiddenEmail:
      L10n.tkEidRequestOtpEmailErrorForbidden
    case .invalidClientAttestation,
         .otpExpired,
         .serviceDeactivated,
         .tooManyRequests,
         .unknown:
      L10n.tkEidRequestOtpEmailErrorGeneric
    }
  }
}
