// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

import BITCrypto
import Factory
import Foundation
import Testing
@testable import BITOpenID
@testable import BITTestingCore
@testable import BITVault

// MARK: - CredentialEncryptionContextGeneratorTests

@Suite(.serialized)
struct CredentialEncryptionContextGeneratorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    registerMocks()
    success()

    generator = CredentialEncryptionContextGenerator()
  }

  // MARK: Internal

  @Test
  func generate_valid_returnsContext() throws {
    let context = try generator(for: metadataMock)

    #expect(keyRepositorySpy.createUsingCallsCount == 1)
    #expect(keyRepositorySpy.createUsingReceivedResponseEncryption == Self.responseEncryptionMock)

    #expect(context.issuerPublicKey == Self.issuerPublicKeyMock)
    #expect(context.credentialRequestEncryptionAlgorithm == Self.encryptionAlgorithmMock)
    #expect(context.credentialRequestEncryptionZipValue == Self.zipValueMock)

    #expect(context.responseKeyPair == keyPairMock)
    #expect(context.credentialResponseEncryptionAlgorithm == Self.encryptionAlgorithmMock)
    #expect(context.credentialResponseEncryptionZipValue == Self.zipValueMock)
  }

  @Test
  func generate_validAndUnsupportedJwk_returnsContext() throws {
    let requestEncryption = CredentialIssuerMetadata.CredentialRequestEncryption.Mock.build(jwks: [.Mock.build(alg: "unsupported"), Self.issuerPublicKeyMock])
    let metadata = metadataMock.changing(\.credentialRequestEncryption, to: requestEncryption)

    let context = try generator(for: metadata)

    #expect(context.issuerPublicKey == Self.issuerPublicKeyMock)
  }

  @Test
  func generate_withoutZipValues_returnsContext() throws {
    let requestEncryption = CredentialIssuerMetadata.CredentialRequestEncryption.Mock.build(supportedZipValues: [])
    let responseEncryption = CredentialIssuerMetadata.CredentialResponseEncryption.Mock.build(supportedZipValues: [])
    let metadata = metadataMock.changing(\.credentialRequestEncryption, to: requestEncryption)
      .changing(\.credentialResponseEncryption, to: responseEncryption)

    let context = try generator(for: metadata)

    #expect(context.issuerPublicKey == Self.issuerPublicKeyMock)
  }

  @Test
  func generate_noRequestEncryptionAlgorithm_throws() throws {
    let requestEncryption = CredentialIssuerMetadata.CredentialRequestEncryption.Mock.build(supportedEncryptionAlgorithms: [])
    let metadata = metadataMock.changing(\.credentialRequestEncryption, to: requestEncryption)

    #expect(throws: CredentialEncryptionContextGeneratorError.noSupportedEncryptionAlgorithm) {
      try generator(for: metadata)
    }
  }

  @Test
  func generate_noResponseEncryptionAlgorithm_throws() throws {
    let responseEncryption = CredentialIssuerMetadata.CredentialResponseEncryption.Mock.build(supportedEncryptionAlgorithms: [])
    let metadata = metadataMock.changing(\.credentialResponseEncryption, to: responseEncryption)

    #expect(throws: CredentialEncryptionContextGeneratorError.noSupportedEncryptionAlgorithm) {
      try generator(for: metadata)
    }
  }

  @Test
  func generate_noRequestEncryptionJwk_throws() throws {
    let requestEncryption = CredentialIssuerMetadata.CredentialRequestEncryption.Mock.build(jwks: [])
    let metadata = metadataMock.changing(\.credentialRequestEncryption, to: requestEncryption)

    #expect(throws: CredentialEncryptionContextGeneratorError.missingIssuerEncryptionKeys) {
      try generator(for: metadata)
    }
  }

  @Test
  func generate_unsupportedRequestEncryptionJwks_throws() throws {
    let requestEncryption = CredentialIssuerMetadata.CredentialRequestEncryption.Mock.build(jwks: [.Mock.build(alg: "unsupported"), .Mock.build(crv: "unsupported")])
    let metadata = metadataMock.changing(\.credentialRequestEncryption, to: requestEncryption)

    #expect(throws: CredentialEncryptionContextGeneratorError.noSuitableEncryptionKey) {
      try generator(for: metadata)
    }
  }

  @Test
  func execute_keyRepositoryThrows_throws() {
    keyRepositorySpy.createUsingThrowableError = TestingError.error

    #expect(throws: TestingError.error) {
      try generator(for: metadataMock)
    }
  }

  // MARK: Private

  private static let requestEncryptionMock =
    CredentialIssuerMetadata.CredentialRequestEncryption.Mock.build(
      jwks: [issuerPublicKeyMock],
      supportedEncryptionAlgorithms: [Self.encryptionAlgorithmMock],
      supportedZipValues: [Self.zipValueMock])
  private static let responseEncryptionMock =
    CredentialIssuerMetadata.CredentialResponseEncryption.Mock.build(
      supportedEncryptionAlgorithms: [Self.encryptionAlgorithmMock],
      supportedZipValues: [Self.zipValueMock])
  private static let encryptionAlgorithmMock = EncryptionAlgorithm.A256GCM
  private static let zipValueMock = CompressionAlgorithm.deflate
  private static let issuerPublicKeyMock = JWK.Mock.build()

  private let keyPairMock = VaultKeyPair.Mock.ES256
  private let metadataMock = CredentialIssuerMetadata.Mock.sample
    .changing(\.credentialRequestEncryption, to: requestEncryptionMock)
    .changing(\.credentialResponseEncryption, to: responseEncryptionMock)

  private var generator = CredentialEncryptionContextGenerator()
  private var keyRepositorySpy = CredentialResponseEncryptionKeyRepositoryProtocolSpy()

  private mutating func registerMocks() {
    let keyRepositorySpy = CredentialResponseEncryptionKeyRepositoryProtocolSpy()
    self.keyRepositorySpy = keyRepositorySpy

    Container.shared.credentialResponseEncryptionKeyRepository.register {
      keyRepositorySpy
    }

    Container.shared.encryptionSupportedCurves.register { ["P-256"] }
  }

  private mutating func success() {
    keyRepositorySpy.createUsingReturnValue = keyPairMock
  }

  private func makeMetadata(
    requestEncryption: CredentialIssuerMetadata.CredentialRequestEncryption,
    responseEncryption: CredentialIssuerMetadata.CredentialResponseEncryption)
    -> CredentialIssuerMetadata
  {
    CredentialIssuerMetadata(
      credentialIssuer: metadataMock.credentialIssuer,
      credentialEndpoint: metadataMock.credentialEndpoint,
      credentialConfigurationsSupported: metadataMock.credentialConfigurationsSupported,
      display: metadataMock.display,
      credentialRequestEncryption: requestEncryption,
      credentialResponseEncryption: responseEncryption,
      nonceEndpoint: metadataMock.nonceEndpoint,
      deferredCredentialEndpoint: metadataMock.deferredCredentialEndpoint)
  }
}
