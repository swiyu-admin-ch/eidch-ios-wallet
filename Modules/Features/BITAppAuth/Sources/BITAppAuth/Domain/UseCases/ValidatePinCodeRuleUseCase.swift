import BITL10n
import Factory
import Foundation
import Spyable

// MARK: - ValidatePinCodeRuleUseCaseProtocol

@Spyable
public protocol ValidatePinCodeRuleUseCaseProtocol {
  func callAsFunction(_ pinCode: String) throws
}

// MARK: - ValidatePinCodeRuleUseCase

struct ValidatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocol {

  @Injected(\.pinCodeMinimumSize) private var pinCodeMinimumSize: Int

  func callAsFunction(_ pinCode: String) throws {
    let pinCode = pinCode.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !pinCode.isEmpty else { throw PinCodeError.empty }
    guard pinCode.count >= pinCodeMinimumSize else { throw PinCodeError.tooShort }
  }

}

// MARK: - PinCodeError

public enum PinCodeError {
  case tooShort
  case empty
  case mismatch
  case wrongPinCode
}
