import BITCrypto
import Factory
import Foundation
import Spyable

// MARK: - PinCodeServiceProtocol

@Spyable
protocol PinCodeServiceProtocol {
  /// Creates new PIN code secret material, encrypts the given PIN code with it and returns the resulting ciphertext.
  ///
  /// Use this when registering a new PIN code. It generates and persists fresh secret material
  /// (salt, initial vector and pepper key), replacing any previously stored material.
  ///
  /// - Parameter pinCode: The PIN code to validate and encrypt.
  /// - Returns: The encrypted PIN code data.
  /// - Throws: A `PinCodeError` if the PIN code fails validation, or an error if the secret material cannot be created or the encryption fails.
  func register(_ pinCode: PinCode) throws -> Data

  /// Encrypts the given PIN code with the existing PIN code secret material and returns the resulting ciphertext.
  ///
  /// Use this to reproduce the ciphertext for an already-registered PIN code, reusing the
  /// previously stored secret material (salt, initial vector and pepper key).
  ///
  /// - Parameter pinCode: The PIN code to validate and encrypt.
  /// - Returns: The encrypted PIN code data.
  /// - Throws: A `PinCodeError` if the PIN code fails validation, or an error if the secret material cannot be loaded or the encryption fails.
  func encrypt(_ pinCode: PinCode) throws -> Data
}

// MARK: - PinCodeService

struct PinCodeService: PinCodeServiceProtocol {

  // MARK: Internal

  func register(_ pinCode: PinCode) throws -> Data {
    try validatePinCodeRuleUseCase(pinCode)
    let secretMaterial = try pinCodeSecretStore.createPinCodeSecretMaterial()

    return try encrypt(pinCode, with: secretMaterial)
  }

  func encrypt(_ pinCode: PinCode) throws -> Data {
    try validatePinCodeRuleUseCase(pinCode)
    let secretMaterial = try pinCodeSecretStore.getPinCodeSecretMaterial()

    return try encrypt(pinCode, with: secretMaterial)
  }

  // MARK: Private

  @Injected(\.keyDeriver) private var keyDeriver: KeyDerivable
  @Injected(\.encrypter) private var encrypter: Encryptable
  @Injected(\.encrypterLength) private var encrypterLength: Int
  @Injected(\.pepperKeyDerivationAlgorithm) private var pepperKeyDerivationAlgorithm: SecKeyAlgorithm
  @Injected(\.pinCodeSecretStore) private var pinCodeSecretStore: PinCodeSecretStoreProtocol

  @Injected(\.validatePinCodeRuleUseCase) private var validatePinCodeRuleUseCase: ValidatePinCodeRuleUseCaseProtocol

  private func encrypt(_ pinCode: PinCode, with secretMaterial: PinCodeSecretMaterial) throws -> Data {
    let pinData = try pinCode.asData()
    let saltedPinCodeData = try keyDeriver.deriveKey(from: pinData, with: secretMaterial.salt)
    return try encrypter.encrypt(
      saltedPinCodeData,
      withAsymmetricKey: secretMaterial.pepperKey,
      length: encrypterLength,
      derivationAlgorithm: pepperKeyDerivationAlgorithm,
      initialVector: secretMaterial.initialVector)
  }
}
