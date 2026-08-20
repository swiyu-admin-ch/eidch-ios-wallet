import Factory
import Foundation
import Testing
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITLocalAuthentication
@testable import BITTestingCore

// MARK: - PinCodeServiceTests

@Suite(.serialized)
@MainActor
struct PinCodeServiceTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let spyKeyDeriver = KeyDerivableSpy()
    let spyEncrypter = EncryptableSpy()
    let spyPinCodeSecretStore = PinCodeSecretStoreProtocolSpy()
    let validatePinCodeRuleUseCase = ValidatePinCodeRuleUseCaseProtocolSpy()

    Container.shared.keyDeriver.register { spyKeyDeriver }
    Container.shared.encrypter.register { spyEncrypter }
    Container.shared.pinCodeSecretStore.register { spyPinCodeSecretStore }
    Container.shared.validatePinCodeRuleUseCase.register { validatePinCodeRuleUseCase }

    self.spyKeyDeriver = spyKeyDeriver
    self.spyEncrypter = spyEncrypter
    self.spyPinCodeSecretStore = spyPinCodeSecretStore
    self.validatePinCodeRuleUseCase = validatePinCodeRuleUseCase
    service = PinCodeService()
  }

  // MARK: Internal

  @Test
  func register_createsSecretMaterialAndEncryptsPinCode() throws {
    let pinCode: PinCode = "123456"
    let pinCodeData = try #require(pinCode.data(using: .utf8))
    let mockSecretMaterial = makeSecretMaterial()
    let mockHashedPinCode = Data()
    let mockPinCodeEncrypted = Data()
    spyPinCodeSecretStore.createPinCodeSecretMaterialReturnValue = mockSecretMaterial
    spyKeyDeriver.deriveKeyFromWithReturnValue = mockHashedPinCode
    spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReturnValue = mockPinCodeEncrypted

    let pinCodeEncrypted = try service.register(pinCode)

    #expect(pinCodeEncrypted == mockPinCodeEncrypted)
    #expect(spyPinCodeSecretStore.createPinCodeSecretMaterialCalled)
    #expect(!spyPinCodeSecretStore.getPinCodeSecretMaterialCalled)
    #expect(spyKeyDeriver.deriveKeyFromWithCalled)
    #expect(spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorCalled)
    #expect(!spyEncrypter.encryptWithSymmetricKeyInitialVectorCalled)

    #expect(validatePinCodeRuleUseCase.callAsFunctionReceivedPinCode == pinCode)

    #expect(spyKeyDeriver.deriveKeyFromWithReceivedArguments?.data == pinCodeData)
    #expect(spyKeyDeriver.deriveKeyFromWithReceivedArguments?.salt == mockSecretMaterial.salt)
    #expect(spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.data == mockHashedPinCode)
    #expect(spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.privateKey == mockSecretMaterial.pepperKey)
    #expect(spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.length == Self.encrypterLength)
    #expect(spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.derivationAlgorithm == Self.keyDerivationAlgorithm)
    #expect(spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.initialVector == mockSecretMaterial.initialVector)
  }

  @Test
  func encrypt_loadsSecretMaterialAndEncryptsPinCode() throws {
    let pinCode: PinCode = "123456"
    let mockSecretMaterial = makeSecretMaterial()
    let mockHashedPinCode = Data([1])
    let mockPinCodeEncrypted = Data([2])
    spyPinCodeSecretStore.getPinCodeSecretMaterialReturnValue = mockSecretMaterial
    spyKeyDeriver.deriveKeyFromWithReturnValue = mockHashedPinCode
    spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReturnValue = mockPinCodeEncrypted

    let pinCodeEncrypted = try service.encrypt(pinCode)

    #expect(pinCodeEncrypted == mockPinCodeEncrypted)
    #expect(spyPinCodeSecretStore.getPinCodeSecretMaterialCalled)
    #expect(!spyPinCodeSecretStore.createPinCodeSecretMaterialCalled)
  }

  @Test
  func register_validationError_doesNotCreateSecretMaterial() {
    validatePinCodeRuleUseCase.callAsFunctionThrowableError = PinCodeError.tooShort
    let pinCode: PinCode = "123456"

    #expect(throws: PinCodeError.tooShort) {
      try service.register(pinCode)
    }

    #expect(!spyPinCodeSecretStore.createPinCodeSecretMaterialCalled)
    #expect(!spyKeyDeriver.deriveKeyFromWithCalled)
    #expect(!spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorCalled)
  }

  // MARK: Private

  private static let encrypterLength = 32
  private static let keyDerivationAlgorithm = SecKeyAlgorithm.ecdhKeyExchangeStandardX963SHA256

  private let spyKeyDeriver: KeyDerivableSpy
  private let spyEncrypter: EncryptableSpy
  private let spyPinCodeSecretStore: PinCodeSecretStoreProtocolSpy
  private let service: PinCodeServiceProtocol
  private let validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocolSpy

  private func makeSecretMaterial() -> PinCodeSecretMaterial {
    PinCodeSecretMaterial(
      salt: Data(),
      pepperKey: SecKeyTestsHelper.createPrivateKey(),
      initialVector: Data())
  }
}
