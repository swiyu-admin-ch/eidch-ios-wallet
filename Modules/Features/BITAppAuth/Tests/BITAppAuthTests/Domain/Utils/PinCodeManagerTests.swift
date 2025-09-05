import Factory
import Foundation
import XCTest
@testable import BITAppAuth
@testable import BITCrypto
@testable import BITLocalAuthentication
@testable import BITTestingCore

// MARK: - ValidateBiometricUseCaseTests

// swiftlint:disable all
final class PinCodeManagerTests: XCTestCase {

  // MARK: Internal

  override func tearDown() {
    super.tearDown()
    Container.shared.reset()
  }

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    spyKeyDeriver = KeyDerivableSpy()
    spyEncrypter = EncryptableSpy()
    spyPepperRepository = PepperRepositoryProtocolSpy()
    spySaltRepository = SaltRepositoryProtocolSpy()
    validatePinCodeRuleUseCase = ValidatePinCodeRuleUseCaseProtocolSpy()

    Container.shared.keyDeriver.register { self.spyKeyDeriver }
    Container.shared.encrypter.register { self.spyEncrypter }
    Container.shared.pepperRepository.register { self.spyPepperRepository }
    Container.shared.saltRepository.register { self.spySaltRepository }
    Container.shared.validatePinCodeRuleUseCase.register { self.validatePinCodeRuleUseCase }

    pinCodeManager = PinCodeManager()
  }

  func testEncrypt() throws {
    let pinCode: PinCode = "123456"
    guard let pinCodeData = pinCode.data(using: .utf8) else { fatalError("Data conversion") }
    let mockPepperKey: SecKey = SecKeyTestsHelper.createPrivateKey()
    let mockSalt = Data()
    let mockHashedPinCode = Data()
    let mockInitialVector = Data()
    let mockPinCodeEncrypted = Data()
    spySaltRepository.getPinSaltReturnValue = mockSalt
    spyPepperRepository.getPepperKeyReturnValue = mockPepperKey
    spyPepperRepository.getPepperInitialVectorReturnValue = mockInitialVector
    spyKeyDeriver.deriveKeyFromWithReturnValue = mockHashedPinCode
    spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReturnValue = mockPinCodeEncrypted

    let pinCodeEncrypted = try pinCodeManager.encrypt(pinCode)
    XCTAssertEqual(mockPinCodeEncrypted, pinCodeEncrypted)
    XCTAssertTrue(spySaltRepository.getPinSaltCalled)
    XCTAssertTrue(spyPepperRepository.getPepperKeyCalled)
    XCTAssertTrue(spyPepperRepository.getPepperInitialVectorCalled)
    XCTAssertTrue(spyKeyDeriver.deriveKeyFromWithCalled)
    XCTAssertTrue(spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorCalled)
    XCTAssertFalse(spyEncrypter.encryptWithSymmetricKeyInitialVectorCalled)

    XCTAssertEqual(validatePinCodeRuleUseCase.executeReceivedPinCode, pinCode)

    XCTAssertEqual(pinCodeData, spyKeyDeriver.deriveKeyFromWithReceivedArguments?.data)
    XCTAssertEqual(mockSalt, spyKeyDeriver.deriveKeyFromWithReceivedArguments?.salt)
    XCTAssertEqual(mockHashedPinCode, spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.data)
    XCTAssertEqual(mockPepperKey, spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.privateKey)
    XCTAssertEqual(Self.encrypterLength, spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.length)
    XCTAssertEqual(Self.keyDerivationAlgorithm, spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.derivationAlgorithm)
    XCTAssertEqual(mockInitialVector, spyEncrypter.encryptWithAsymmetricKeyLengthDerivationAlgorithmInitialVectorReceivedArguments?.initialVector)
  }

  func testEncrypt_validationError() throws {
    validatePinCodeRuleUseCase.executeThrowableError = PinCodeError.tooShort
    let pinCode: PinCode = "123456"
    pinCodeManager = Container.shared.pinCodeManager()

    XCTAssertThrowsError(try pinCodeManager.encrypt(pinCode)) { error in
      XCTAssertEqual(error as? PinCodeError, .tooShort)
    }
  }

  // MARK: Private

  private static let pinCodeSize = 6
  private static let encrypterLength = 32
  private static let keyDerivationAlgorithm = SecKeyAlgorithm.ecdhKeyExchangeStandardX963SHA256

  private var spyKeyDeriver: KeyDerivableSpy!
  private var spyEncrypter: EncryptableSpy!
  private var spyPepperRepository: PepperRepositoryProtocolSpy!
  private var spySaltRepository: SaltRepositoryProtocolSpy!
  private var pinCodeManager: PinCodeManagerProtocol!
  private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocolSpy!
}

// swiftlint:enable all
