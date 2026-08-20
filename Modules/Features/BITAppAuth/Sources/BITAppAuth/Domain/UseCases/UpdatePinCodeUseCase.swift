import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - UpdatePinCodeUseCaseProtocol

@Spyable
public protocol UpdatePinCodeUseCaseProtocol {
  func callAsFunction(with newPinCode: PinCode, and uniquePassphrase: Data) throws
}

// MARK: - UpdatePinCodeUseCase

struct UpdatePinCodeUseCase: UpdatePinCodeUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(with newPinCode: PinCode, and uniquePassphrase: Data) throws {
    let newPinCodeDataEncrypted = try pinCodeService.encrypt(newPinCode)
    let context = try userSession.startSession(passphrase: newPinCodeDataEncrypted)

    try uniquePassphraseManager.save(uniquePassphrase: uniquePassphrase, for: .appPin, context: context)

    try userSession.startSession(passphrase: uniquePassphrase)
  }

  // MARK: Private

  @Injected(\.userSession) private var userSession: Session
  @Injected(\.pinCodeService) private var pinCodeService: PinCodeServiceProtocol
  @Injected(\.uniquePassphraseManager) private var uniquePassphraseManager: UniquePassphraseManagerProtocol

}
