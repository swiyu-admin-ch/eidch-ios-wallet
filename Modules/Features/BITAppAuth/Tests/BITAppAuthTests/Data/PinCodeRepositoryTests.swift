import BITCore
import Factory
import Foundation
import Testing
@testable import BITAppAuth
@testable import BITTestingCore
@testable import BITVault

// MARK: - PinCodeRepositoryTests

@Suite
@MainActor
struct PinCodeRepositoryTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let secretManagerSpy = SecretManagerProtocolSpy()
    let keyManagerSpy = KeyManagerProtocolSpy()
    let processInfoServiceSpy = ProcessInfoServiceProtocolSpy()

    keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryReturnValue = mockKeyPair
    keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryReturnValue = mockKeyPair

    Container.shared.secretManager.register { secretManagerSpy }
    Container.shared.keyManager.register { keyManagerSpy }
    Container.shared.processInfoService.register { processInfoServiceSpy }
    Container.shared.appPinSaltLength.register { Self.saltLength }
    Container.shared.pepperKeyInitialVectorLength.register { Self.initialVectorLength }

    self.secretManagerSpy = secretManagerSpy
    self.keyManagerSpy = keyManagerSpy
    store = PinCodeRepository()
  }

  // MARK: Internal

  @Test
  func createPinCodeSecretMaterial() throws {
    let material = try store.createPinCodeSecretMaterial()

    #expect(material.salt.count == Self.saltLength)
    #expect(material.initialVector.count == Self.initialVectorLength)
    #expect(material.pepperKey == mockKeyPair.privateKey)
    #expect(secretManagerSpy.setForKeyQueryCallsCount == 2)
    #expect(secretManagerSpy.setForKeyQueryReceivedInvocations.compactMap { ($0.value as? Data)?.count } == [Self.saltLength, Self.initialVectorLength])
    #expect(keyManagerSpy.generateKeyPairWithIdentifierAlgorithmOptionsQueryCallsCount == 1)
  }

  @Test
  func getPinCodeSecretMaterial() throws {
    let storedData = Data([1, 2, 3])
    secretManagerSpy.dataForKeyQueryReturnValue = storedData

    let material = try store.getPinCodeSecretMaterial()

    #expect(material.salt == storedData)
    #expect(material.initialVector == storedData)
    #expect(material.pepperKey == mockKeyPair.privateKey)
    #expect(secretManagerSpy.dataForKeyQueryCallsCount == 2)
    #expect(keyManagerSpy.getKeyPairWithIdentifierAlgorithmQueryCallsCount == 1)
  }

  // MARK: Private

  private static let saltLength = 16
  private static let initialVectorLength = 12

  private let mockKeyPair = VaultKeyPair.Mock.ES256

  private let secretManagerSpy: SecretManagerProtocolSpy
  private let keyManagerSpy: KeyManagerProtocolSpy
  private let store: PinCodeSecretStoreProtocol
}
