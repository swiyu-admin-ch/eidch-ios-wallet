import Factory
import Foundation
import Testing
@testable import BITCore
@testable import BITCrypto
@testable import BITOpenID

@Suite(.serialized)
struct AuthorizationResponseEncryptionGeneratorTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()
    Container.shared.encryptionSupportedCurves.register {
      ["P-256"]
    }

    generator = AuthorizationResponseEncryptionGenerator()
  }

  // MARK: Internal

  @Test(arguments: ["A128GCM", "A256GCM"])
  func generate_valid_returnsEncryption(algorithm: String) throws {
    let clientMetadata = clientMetadataMock.changing(\.encryptedResponseEncValuesSupported, to: [algorithm])

    let encryption = try generator(for: clientMetadata)

    #expect(encryption.jwk == Self.jwkMock)
    #expect(encryption.algorithm.rawValue == algorithm)
  }

  @Test(arguments: ["A128GCM", "A256GCM"])
  func generate_unknownEncryptionAlgorithm_returnsEncryption(algorithm: String) throws {
    let clientMetadata = clientMetadataMock.changing(\.encryptedResponseEncValuesSupported, to: ["unknown", algorithm])

    let encryption = try generator(for: clientMetadata)

    #expect(encryption.jwk == Self.jwkMock)
    #expect(encryption.algorithm.rawValue == algorithm)
  }

  @Test
  func generate_oneValidAndOneInvalidJWK_returnsEncryption() throws {
    let jwks = ClientMetadata.JWKs(keys: [Self.invalidJwkMock, Self.jwkMock])
    let clientMetadata = clientMetadataMock.changing(\.jwks, to: jwks)

    let encryption = try generator(for: clientMetadata)

    #expect(encryption.jwk == Self.jwkMock)
  }

  @Test
  func generate_missingClientMetadata_throwsError() {
    #expect(throws: AuthorizationResponseEncryptionGeneratorError.missingClientData) {
      try generator(for: nil)
    }
  }

  @Test
  func generate_missingEncryptionValues_throwsError() {
    let clientMetadata = clientMetadataMock.changing(\.encryptedResponseEncValuesSupported, to: nil)

    #expect(throws: AuthorizationResponseEncryptionGeneratorError.unsupportedEncryptionValue) {
      try generator(for: clientMetadata)
    }
  }

  @Test
  func generate_unsupportedEncryptionValue_throwsError() {
    let clientMetadata = clientMetadataMock.changing(\.encryptedResponseEncValuesSupported, to: ["unsupported"])

    #expect(throws: AuthorizationResponseEncryptionGeneratorError.unsupportedEncryptionValue) {
      try generator(for: clientMetadata)
    }
  }

  @Test
  func generate_noEncryptionValue_throwsError() {
    let clientMetadata = clientMetadataMock.changing(\.encryptedResponseEncValuesSupported, to: [])

    #expect(throws: AuthorizationResponseEncryptionGeneratorError.unsupportedEncryptionValue) {
      try generator(for: clientMetadata)
    }
  }

  @Test
  func generate_noJWK_throwsError() {
    let clientMetadata = clientMetadataMock.changing(\.jwks, to: nil)

    #expect(throws: AuthorizationResponseEncryptionGeneratorError.noSuitableEncryptionKey) {
      try generator(for: clientMetadata)
    }
  }

  @Test
  func generate_emptyJWKs_throwsError() {
    let clientMetadata = clientMetadataMock.changing(\.jwks, to: ClientMetadata.JWKs(keys: []))

    #expect(throws: AuthorizationResponseEncryptionGeneratorError.noSuitableEncryptionKey) {
      try generator(for: clientMetadata)
    }
  }

  @Test
  func generate_onlyUnsupportedAlgorithmJWK_throwsError() {
    let clientMetadata = clientMetadataMock.changing(\.jwks, to: ClientMetadata.JWKs(keys: [Self.invalidJwkMock]))

    #expect(throws: AuthorizationResponseEncryptionGeneratorError.noSuitableEncryptionKey) {
      try generator(for: clientMetadata)
    }
  }

  @Test
  func generate_onlyUnsupportedAlgorithmJwkCurve_throwsUnsupportedJwkCurve() {
    let invalidJwk = JWK.Mock.build(crv: "unsupported")
    let jwks = ClientMetadata.JWKs(keys: [invalidJwk])
    let clientMetadata = clientMetadataMock.changing(\.jwks, to: jwks)

    #expect(
      throws: AuthorizationResponseEncryptionGeneratorError.noSuitableEncryptionKey)
    {
      try generator(for: clientMetadata)
    }
  }

  // MARK: Private

  private static let jwkMock = JWK.Mock.build()
  private static let invalidJwkMock = JWK.Mock.build(alg: "unsupported")

  private let clientMetadataMock = ClientMetadata(
    clientName: nil,
    logoUri: nil,
    jwks: ClientMetadata.JWKs(keys: [jwkMock]),
    encryptedResponseEncValuesSupported: ["A256GCM"])

  private var generator: AuthorizationResponseEncryptionGenerator
}
