import BITL10n
import Factory
import Foundation
import NavigatorUI
import Observation

@MainActor
@Observable
final class OTPCodeViewModel {

  // MARK: Lifecycle

  init(email: String, onToastMessage: @escaping (String) -> Void = { _ in }) {
    self.email = email
    self.onToastMessage = onToastMessage
  }

  // MARK: Internal

  let email: String
  var code = ""
  var errorMessage: String?
  var isSubmitting = false
  var destination: OTPDestinations?
  var isBackTriggered = false

  var isSubmissionAllowed: Bool {
    code.count == 6 && !isSubmitting && errorMessage == nil
  }

  func onCodeChange(_ value: String) {
    let sanitizedValue = sanitize(value)
    guard sanitizedValue != code else { return }

    code = sanitizedValue
    errorMessage = nil

    guard isSubmissionAllowed else { return }
    Task {
      await submit()
    }
  }

  func submit() async {
    guard isSubmissionAllowed else { return }

    isSubmitting = true
    errorMessage = nil
    defer { isSubmitting = false }

    do {
      try await verifyOTPUseCase(email: email, code: code)
      setOTPEnabledUseCase(false)
      destination = .external(.eidRequest)
    } catch let error as OTPError {
      handle(error)
    } catch {
      handle(.unknown)
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.verifyOTPUseCase) private var verifyOTPUseCase
  @ObservationIgnored @Injected(\.setOTPEnabledUseCase) private var setOTPEnabledUseCase
  @ObservationIgnored private let onToastMessage: (String) -> Void

  private func sanitize(_ value: String) -> String {
    let normalizedDigits = value.compactMap { character -> String? in
      guard let digit = character.wholeNumberValue, (0...9).contains(digit) else { return nil }
      return String(digit)
    }

    return String(normalizedDigits.joined().prefix(6))
  }

  private func handle(_ error: OTPError) {
    switch error {
    case .invalidFormat:
      errorMessage = L10n.tkEidRequestOtpCodeErrorInvalid
    case .otpExpired:
      onToastMessage(L10n.tkEidRequestOtpCodeToastExpired)
      backToEmail()
    case .tooManyRequests:
      destination = .error(.OTP.tooManyAttempts)
    case .serviceDeactivated:
      destination = .error(.OTP.unavailable)
    case .forbiddenEmail,
         .invalidClientAttestation,
         .unknown:
      destination = .error(.retry(error, retryAction))
    }
  }

  private func backToEmail() {
    destination = nil
    isSubmitting = false
    isBackTriggered = true
  }

  private func retryAction(_ navigator: Navigator) {
    destination = nil
    isSubmitting = false
    navigator.pop()
  }
}
