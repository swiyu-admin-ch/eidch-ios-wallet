import Factory
import Foundation
import Testing
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITVault

// swiftlint:disable force_try force_unwrapping

@Suite
struct KeyBindingGeneratorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let keyManager = KeyManagerProtocolSpy()
    self.keyManager = keyManager

    Container.shared.keyManager.register { keyManager }

    generator = KeyBindingGenerator()
  }

  // MARK: Internal

  @Test
  func generate_withSoftwareKeyPair_returnsKeyBindingWithRawKeys() throws {
    let keyPair = VaultKeyPair.Mock.ES256SavePermanently(id: mockId)

    guard let rawPublicKey = try keyPair.publicKey?.toData() else {
      Issue.record("Cannot get data from public key")
      return
    }

    let rawPrivateKey = try keyPair.privateKey.toData()
    keyManager.getExternalRepresentationOfReturnValue = (rawPublicKey: rawPublicKey, rawPrivateKey: rawPrivateKey)

    let keyBinding = try generator.generate(from: keyPair)

    #expect(keyBinding?.id.uuidString == keyPair.identifier)
    #expect(keyBinding?.algorithm == keyPair.algorithm.rawValue)
    #expect(keyBinding?.bindingType == .software)
    #expect(keyBinding?.publicKey == rawPublicKey)
    #expect(keyBinding?.privateKey == rawPrivateKey)

    #expect(keyManager.getExternalRepresentationOfCallsCount == 1)
  }

  @Test
  func generate_withHardwareKeyPair_returnsKeyBindingWithoutRawKeys() throws {
    let keyPair = VaultKeyPair.Mock.ES256SecureEnclavePermanently(id: mockId)

    let keyBinding = try generator.generate(from: keyPair)

    #expect(keyBinding?.id.uuidString == keyPair.identifier)
    #expect(keyBinding?.algorithm == keyPair.algorithm.rawValue)
    #expect(keyBinding?.bindingType == .hardware)
    #expect(keyBinding?.publicKey == nil)
    #expect(keyBinding?.privateKey == nil)

    #expect(!keyManager.getExternalRepresentationOfCalled)
  }

  // MARK: Private

  private let generator: KeyBindingGenerator
  private let keyManager: KeyManagerProtocolSpy
  private let mockId = UUID()
}
