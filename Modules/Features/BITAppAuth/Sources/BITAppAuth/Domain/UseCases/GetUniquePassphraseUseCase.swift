import BITLocalAuthentication
import Factory
import Foundation
import Spyable

// MARK: - GetUniquePassphraseUseCaseProtocol

@Spyable
public protocol GetUniquePassphraseUseCaseProtocol {
  @discardableResult
  func callAsFunction(from pinCode: PinCode) throws -> Data
}

// MARK: - GetUniquePassphraseUseCase

struct GetUniquePassphraseUseCase: GetUniquePassphraseUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(from pinCode: PinCode) throws -> Data {
    let pinCodeDataEncrypted = try pinCodeService.encrypt(pinCode)
    guard internalContext.setCredential(pinCodeDataEncrypted, type: .applicationPassword) else {
      throw AuthError.LAContextError(reason: "cannot set the required credential to get unique passphrase")
    }
    return try uniquePassphraseManager.getUniquePassphrase(authMethod: .appPin, context: internalContext)
  }

  // MARK: Private

  @Injected(\.internalContext) private var internalContext: LAContextProtocol
  @Injected(\.pinCodeService) private var pinCodeService: PinCodeServiceProtocol
  @Injected(\.uniquePassphraseManager) private var uniquePassphraseManager: UniquePassphraseManagerProtocol
}
