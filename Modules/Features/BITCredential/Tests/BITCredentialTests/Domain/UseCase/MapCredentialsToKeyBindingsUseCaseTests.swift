// swiftlint: disable force_try implicitly_unwrapped_optional
import Factory
import Foundation
import Spyable
import Testing
@testable import BITAnyCredentialFormat
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore
@testable import BITVault

struct MapCredentialsToKeyBindingsUseCaseTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    let keyManagerSpy = KeyManagerProtocolSpy()
    let keyBindingGeneratorSpy = KeyBindingGeneratorProtocolSpy()
    let jwkGeneratorSpy = JWKGeneratorProtocolSpy()
    self.keyManagerSpy = keyManagerSpy
    self.keyBindingGeneratorSpy = keyBindingGeneratorSpy
    self.jwkGeneratorSpy = jwkGeneratorSpy

    Container.shared.keyManager.register { keyManagerSpy }
    Container.shared.keyBindingGenerator.register { keyBindingGeneratorSpy }
    Container.shared.jwkGenerator.register { jwkGeneratorSpy }

    useCase = MapCredentialsToKeyBindingsUseCase()
    createSuccessState()
  }

  // MARK: Internal

  @Test
  func callAsFunction_withKeyPairs_returnsMappedResult() throws {
    let result = try useCase(credentials: [vcSdJwtMock1, vcSdJwtMock2], keyPairs: [keyPairMock1, keyPairMock2])

    #expect(result.count == 2)
    #expect(result[0].credential.raw == vcSdJwtMock1.raw)
    #expect(result[0].keyBinding == keyBindingMock1)

    #expect(result[1].credential.raw == vcSdJwtMock2.raw)
    #expect(result[1].keyBinding == keyBindingMock2)
  }

  @Test
  func callAsFunction_withKeyBindings_returnsMappedResult() throws {
    let result = try useCase(credentials: [vcSdJwtMock1, vcSdJwtMock2], keyBindings: [keyBindingMock2, keyBindingMock1])

    #expect(result.count == 2)
    #expect(result[0].credential.raw == vcSdJwtMock1.raw)
    #expect(result[0].keyBinding == keyBindingMock1)

    #expect(result[1].credential.raw == vcSdJwtMock2.raw)
    #expect(result[1].keyBinding == keyBindingMock2)
    #expect(result[1].keyBinding == keyBindingMock2)

    let passedRightOptions = keyBindingGeneratorSpy.generateFromReceivedInvocations.allSatisfy { keyPair in
      let expectedOptions: VaultOptions = (keyPair?.identifier == keyPairMock1.identifier ? .none : .secureEnclave)
      return keyPair?.options == expectedOptions
    }
    #expect(passedRightOptions == true)
  }

  @Test
  func callAsFunction_withEmptyInput_returnsEmpty() throws {
    let result = try useCase(credentials: [], keyPairs: [])

    #expect(result.isEmpty)
  }

  @Test
  func callAsFunction_noJwkOnCredential_returnsCredentialWithoutKeyBinding() throws {
    let credential = VcSdJWS.Mock.noKeyBinding

    let result = try useCase(credentials: [credential], keyBindings: [keyBindingMock1])

    #expect(result.count == 1)
    #expect(result.first?.credential.raw == credential.raw)
    #expect(result.first?.keyBinding == nil)
  }

  @Test
  func callAsFunction_withEmptyCredentials_returnsEmpty() throws {
    let result = try useCase(credentials: [], keyPairs: [keyPairMock1])

    #expect(result.isEmpty)
  }

  @Test
  func callAsFunction_keyBindingGeneratorThrows_throwsError() {
    keyBindingGeneratorSpy.generateFromThrowableError = TestingError.error

    #expect(throws: TestingError.error) {
      _ = try useCase(credentials: [vcSdJwtMock1], keyPairs: [keyPairMock1])
    }
  }

  @Test
  func callAsFunction_withInvalidCredentialFormat_throwsError() {
    #expect(throws: MapCredentialsToKeyBindingsUseCaseError.invalidCredentialFormat) {
      _ = try useCase(credentials: [MockAnyCredential()], keyPairs: [keyPairMock1])
    }
  }

  @Test
  func callAsFunction_withNoMatchingKeyBinding_throwsError() {
    #expect(throws: MapCredentialsToKeyBindingsUseCaseError.noMatchingKeyBinding) {
      _ = try useCase(credentials: [vcSdJwtMock1], keyPairs: [keyPairMock2])
    }
  }

  @Test
  func callAsFunction_invalidAlgorithm_throwsError() {
    let invalidBinding = KeyBinding(
      id: UUID(),
      algorithm: "invalid",
      bindingType: .software)

    #expect(throws: MapCredentialsToKeyBindingsUseCaseError.invalidKeyBindingAlgorithm) {
      _ = try useCase(credentials: [vcSdJwtMock1], keyBindings: [invalidBinding])
    }
  }

  // MARK: Private

  private var useCase: MapCredentialsToKeyBindingsUseCase!

  private var keyManagerSpy: KeyManagerProtocolSpy!
  private var keyBindingGeneratorSpy: KeyBindingGeneratorProtocolSpy!
  private var jwkGeneratorSpy: JWKGeneratorProtocolSpy!

  // Mocks

  private let publicKeyMock = "publicKeyData"
  private let jwkMock1 = JWK(kty: "key_type", kid: nil, crv: "curve", x: "test_x", y: "test_y", alg: nil)
  private let jwkMock2 = JWK(kty: "key_type", kid: nil, crv: "curve", x: "test_x_1", y: "test_y_1", alg: nil)

  private let keyBindingMock1 = KeyBinding(
    id: UUID(),
    algorithm: "ES256",
    bindingType: .software)

  private let keyBindingMock2 = KeyBinding(
    id: UUID(),
    algorithm: "ES512",
    bindingType: .hardware)

  private var keyPairMock1 = VaultKeyPair.Mock.ES256WithoutOptions
  private var keyPairMock2 = VaultKeyPair.Mock.ES512

  private var vcSdJwtMock1 = VcSdJWS.Mock.sample
  private var vcSdJwtMock2 = VcSdJWS.Mock.sampleBusinessExpired

  private func createSuccessState() {
    keyBindingGeneratorSpy.generateFromClosure = { keyPair in
      if keyPair == keyPairMock2 {
        return keyBindingMock2
      }
      return keyBindingMock1
    }
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryClosure = { id, algorithm, _ in
      if id == keyBindingMock2.id.uuidString, algorithm == VaultAlgorithm.eciesEncryptionStandardVariableIVX963SHA512AESGCM {
        return keyPairMock2
      }
      return keyPairMock1
    }
    jwkGeneratorSpy.callAsFunctionFromClosure = { keyPair in
      if keyPair == keyPairMock2 {
        return jwkMock2
      }
      return jwkMock1
    }
  }
}
