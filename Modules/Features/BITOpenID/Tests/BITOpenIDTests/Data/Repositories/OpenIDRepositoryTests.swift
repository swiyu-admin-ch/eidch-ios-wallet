// swiftlint:disable force_cast force_try force_unwrapping
import BITCore
import BITNetworking
import Factory
import Foundation
import Moya
import XCTest
@testable import BITCrypto
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore
@testable import BITVault

// MARK: - OpenIDRepositoryTests

final class OpenIDRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    registerMocks()
    repository = OpenIDRepository()
    success()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
  }

  // MARK: - Metadata

  func testFetchTypeMetadataSuccess() async throws {
    let expectedTypeMetadata = TypeMetadata.Mock.sampleStandard
    let dataMock = TypeMetadata.Mock.sampleStandardData
    mockResponse(code: 200, data: dataMock)

    let response = try await repository.fetchTypeMetadata(from: mockUrl)
    let typeMetadata = response.object

    XCTAssertEqual(expectedTypeMetadata.displays, typeMetadata.displays)
    XCTAssertEqual(expectedTypeMetadata.vct, typeMetadata.vct)
    XCTAssertEqual(expectedTypeMetadata.name, typeMetadata.name)
    XCTAssertEqual(expectedTypeMetadata.description, typeMetadata.description)
    XCTAssertEqual(expectedTypeMetadata.schemaUrl, typeMetadata.schemaUrl)
    XCTAssertEqual(expectedTypeMetadata.schemaIntegrity, typeMetadata.schemaIntegrity)
    XCTAssertEqual(dataMock, response.response.data)
  }

  func testFetchMetadataJwtSuccess() async throws {
    guard let mocks = credentialIssuerMetadataJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtResponse)

    let result = try await repository.fetchMetadata(from: Self.mockIssuerUrl)

    XCTAssertEqual(mocks.jwt, result.payload)
    XCTAssertEqual(result.rawPayload, mocks.rawString)
    XCTAssertEqual(mocks.validator.validateActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchMetadataJwtSuccess_oidConnectMetadata() async throws {
    guard let mocks = credentialIssuerMetadataJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: .networkResponse(500, Data()), oidConnectMetadataResponse: jwtResponse)

    let result = try await repository.fetchMetadata(from: Self.mockIssuerUrl)

    XCTAssertEqual(mocks.jwt, result.payload)
    XCTAssertEqual(result.rawPayload, mocks.rawString)
    XCTAssertEqual(mocks.validator.validateActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchMetadataJwt_invalidJwtSubject_throws() async throws {
    _ = credentialIssuerMetadataJwtMocks(subject: "https://invalid.com")
    repository = OpenIDRepository()
    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtResponse)

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: Self.mockIssuerUrl)) { error in
      XCTAssertEqual(error as? OpenIdRepositoryError, .invalidCredentialIssuerMetadataJWT)
    }
  }

  func testFetchMetadataJwt_invalidCredentialIssuer_throws() async throws {
    let url = try XCTUnwrap(URL(string: "https://invalid.com"))
    _ = credentialIssuerMetadataJwtMocks(credentialIssuer: url)
    repository = OpenIDRepository()
    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtResponse)

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: Self.mockIssuerUrl)) { error in
      XCTAssertEqual(error as? OpenIdRepositoryError, .invalidCredentialIssuerMetadataJWT)
    }
  }

  func testFetchMetadataJwtValidationFails() async throws {
    _ = credentialIssuerMetadataJwtMocks(validatorError: JWSValidatorError.expired)

    repository = OpenIDRepository()

    let jwtSample = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtSample)

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: Self.mockIssuerUrl)) { error in
      XCTAssertEqual(error as? JWSValidatorError, .expired)
    }
  }

  func testFetchMetadataJwtSignatureValidationFails() async throws {
    _ = credentialIssuerMetadataJwtMocks(validatorError: JWSSignatureValidatorError.invalidSignature)

    repository = OpenIDRepository()

    let jwtSample = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtSample)

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: Self.mockIssuerUrl)) { error in
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  func testFetchMetadataDecodingFails() async throws {
    mockMetadataEndpoints(metadataResponse: .networkResponse(200, Data()))

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: Self.mockIssuerUrl)) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testFetchMetadata_metadataReturns500_fetchesMetadataFromOidConnectUrl() async throws {
    guard let mocks = credentialIssuerMetadataJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: .networkResponse(500, Data()), oidConnectMetadataResponse: jwtResponse)

    let result = try await repository.fetchMetadata(from: Self.mockIssuerUrl)

    XCTAssertEqual(result.payload, mocks.jwt)
  }

  func testFetchMetadata_metadataReturns404AndOidConnectReturns500_throwsError() async throws {
    mockMetadataEndpoints(metadataResponse: .networkResponse(404, Data()), oidConnectMetadataResponse: .networkResponse(500, Data()))

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: Self.mockIssuerUrl)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - OpenIdConfiguration

  func testFetchOpenIdConfigurationJwtSuccess() async throws {
    guard let mocks = credentialOpenIdConfigurationJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: jwtResponse)

    let result = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(mocks.jwt.openIdConfiguration, result)
    XCTAssertEqual(mocks.validator.validateActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchOpenIdConfigurationJwtSuccess_oidConnectOpenIdConfiguration() async throws {
    guard let mocks = credentialOpenIdConfigurationJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: .networkResponse(500, Data()), oidConnectResponse: jwtResponse)

    let result = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(mocks.jwt.openIdConfiguration, result)
    XCTAssertEqual(mocks.validator.validateActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchOpenIdConfigurationJwtValidationFails() async throws {
    credentialOpenIdConfigurationJwtMocks(validatorError: JWSValidatorError.expired)

    repository = OpenIDRepository()

    let jwtSample = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: jwtSample)

    await XCTAssertThrowsErrorAsync(try await repository.fetchOpenIdConfiguration(from: mockUrl)) { error in
      XCTAssertEqual(error as? JWSValidatorError, .expired)
    }
  }

  func testFetchOpenIdConfigurationJwtSignatureValidationFails() async throws {
    credentialOpenIdConfigurationJwtMocks(validatorError: JWSSignatureValidatorError.invalidSignature)

    repository = OpenIDRepository()

    let jwtSample = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: jwtSample)

    await XCTAssertThrowsErrorAsync(try await repository.fetchOpenIdConfiguration(from: mockUrl)) { error in
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  func testFetchOpenIdConfigurationDecodingFails() async throws {
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: .networkResponse(200, Data()))

    await XCTAssertThrowsErrorAsync(try await repository.fetchOpenIdConfiguration(from: mockUrl)) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testFetchOpenIdConfiguration_openIdConfigurationReturns500_fetchesConfigFromOidConnectUrl() async throws {
    guard let mocks = credentialOpenIdConfigurationJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtSample = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: .networkResponse(500, Data()), oidConnectResponse: jwtSample)

    let result = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(result, mocks.jwt.openIdConfiguration)
  }

  func testFetchOpenIdConfiguration_openIdConfigurationReturns404AndOidConnectReturns500_throwsError() async throws {
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: .networkResponse(404, Data()), oidConnectResponse: .networkResponse(500, Data()))

    await XCTAssertThrowsErrorAsync(try await repository.fetchOpenIdConfiguration(from: mockUrl)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - AccessToken

  func testFetchAccessToken_success() async throws {
    let preAuthorizedCode = "code"
    let expectedAccessToken = AccessToken.Mock.sample

    mockResponse(code: 200, data: AccessToken.Mock.sampleData)

    let authorization = try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: preAuthorizedCode,
      dpopKeyPair: nil,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil)

    XCTAssertEqual(expectedAccessToken, authorization.accessToken)
  }

  func testFetchAccessToken_withDPoP_generatesProof() async throws {
    let preAuthorizedCode = "code"
    let dpopKeyPair = VaultKeyPair.Mock.ES256

    mockResponse(code: 200, data: AccessToken.Mock.sampleData)

    _ = try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: preAuthorizedCode,
      dpopKeyPair: dpopKeyPair,
      dpopNonce: "dpop-nonce",
      dpopKeyAttestationJWS: nil)

    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount, 1)
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.method, "POST")
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.url, mockUrl)
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.keyPair.identifier, dpopKeyPair.identifier)
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.nonce, "dpop-nonce")
    XCTAssertNil(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.accessToken)
    XCTAssertNil(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.additionalHeaderParameters[ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue])
  }

  func testFetchAccessToken_withDPoPAndKeyAttestation_generatesProofWithAttestationHeader() async throws {
    mockResponse(code: 200, data: AccessToken.Mock.sampleData)

    _ = try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: "code",
      dpopKeyPair: VaultKeyPair.Mock.ES256,
      dpopNonce: nil,
      dpopKeyAttestationJWS: "attestation-jws")

    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.additionalHeaderParameters[ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue] as? String, "attestation-jws")
  }

  func testFetchAccessToken_useDPoPNonceChallenge_retriesWithHeaderNonce() async throws {
    let dpopKeyPair = VaultKeyPair.Mock.ES256
    try mockResponses([
      (400, JSONEncoder().encode(["error": "use_dpop_nonce"]), ["DPoP-Nonce": "auth-server-nonce"]),
      (200, AccessToken.Mock.sampleData, nil),
    ])

    let authorization = try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: "code",
      dpopKeyPair: dpopKeyPair,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil)

    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount, 2)
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.nonce, "auth-server-nonce")
    XCTAssertEqual(authorization.accessToken, AccessToken.Mock.sample)
  }

  func testFetchAccessToken_invalidRequest_returnsOpenIdRepositoryErrorInvalidRequest() async throws {
    let preAuthorizedCode = "code"
    let responseData = try JSONEncoder().encode(["error": "invalid_request"])

    mockResponse(code: 400, data: responseData)

    await XCTAssertThrowsErrorAsync(try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: preAuthorizedCode,
      dpopKeyPair: nil,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil))
    { error in
      XCTAssertEqual((error as! OpenIdRepositoryError), .invalidRequest("invalid_request"))
    }
  }

  func testFetchAccessToken_invalidDPoPProof_returnsOpenIdRepositoryErrorInvalidDPoPProof() async throws {
    let preAuthorizedCode = "code"
    let responseData = try JSONEncoder().encode(["error": "invalid_dpop_proof"])

    mockResponse(code: 400, data: responseData)

    await XCTAssertThrowsErrorAsync(try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: preAuthorizedCode,
      dpopKeyPair: nil,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil))
    { error in
      XCTAssertEqual((error as! OpenIdRepositoryError), .invalidDPoPProof("invalid_dpop_proof"))
    }
  }

  func testFetchAccessToken_useDPoPNonceWithoutHeader_returnsOpenIdRepositoryErrorUseDPoPNonce() async throws {
    let preAuthorizedCode = "code"
    let responseData = try JSONEncoder().encode(["error": "use_dpop_nonce"])

    mockResponse(code: 400, data: responseData)

    await XCTAssertThrowsErrorAsync(try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: preAuthorizedCode,
      dpopKeyPair: nil,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil))
    { error in
      XCTAssertEqual((error as! OpenIdRepositoryError), .useDPoPNonce("use_dpop_nonce", nil))
    }
  }

  func testFetchAccessToken_useDPoPNonceAfterRetry_returnsOpenIdRepositoryErrorUseDPoPNonceWithHeaderNonce() async throws {
    let dpopKeyPair = VaultKeyPair.Mock.ES256
    try mockResponses([
      (400, JSONEncoder().encode(["error": "use_dpop_nonce"]), ["DPoP-Nonce": "auth-server-nonce-1"]),
      (400, JSONEncoder().encode(["error": "use_dpop_nonce"]), ["DPoP-Nonce": "auth-server-nonce-2"]),
    ])

    await XCTAssertThrowsErrorAsync(try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: "code",
      dpopKeyPair: dpopKeyPair,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil))
    { error in
      XCTAssertEqual((error as! OpenIdRepositoryError), .useDPoPNonce("use_dpop_nonce", "auth-server-nonce-2"))
    }
  }

  func testFetchAccessToken_unknownBadRequest() async throws {
    let preAuthorizedCode = "code"

    let mockInvalidGandError = ["error": "something_unknown"]
    let mockInvalidGandErrorData = try JSONEncoder().encode(mockInvalidGandError)
    mockResponse(code: 400, data: mockInvalidGandErrorData)

    await XCTAssertThrowsErrorAsync(try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: preAuthorizedCode,
      dpopKeyPair: nil,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil))
    { error in
      XCTAssertNotEqual((error as! NetworkError).status, .invalidGrant)
    }
  }

  func testFetchAccessToken_failure() async throws {
    let preAuthorizedCode = "code"
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchAccessToken(
      from: mockUrl,
      preAuthorizedCode: preAuthorizedCode,
      dpopKeyPair: nil,
      dpopNonce: nil,
      dpopKeyAttestationJWS: nil))
    { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - Nonce

  func testFetchNonce_success() async throws {
    let expectedNonce = Nonce.Mock.default

    mockResponse(code: 200, data: Nonce.Mock.defaultData)

    let nonce = try await repository.fetchNonce(from: mockUrl)

    XCTAssertEqual(expectedNonce, nonce.nonce)
  }

  func testFetchNonce_success_returnsDPoPNonceHeader() async throws {
    mockResponse(code: 200, data: Nonce.Mock.defaultData, headers: ["DPoP-Nonce": "dpop-nonce"])

    let nonce = try await repository.fetchNonce(from: mockUrl)

    XCTAssertEqual(nonce.dpopNonce, "dpop-nonce")
  }

  func testFetchNonce_failure() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchNonce(from: mockUrl)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - Credential

  func testFetchCredentialWithContext_success_returnsCredential() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: mockJWTHeaders)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)

    if case .credential(let credentials) = result {
      XCTAssertEqual(credentials.count, 1)
      XCTAssertEqual(credentials.first?.raw, mockCredentialResponse.credentials.first?.credential)

      guard let encrypterArguments = jweEncrypterMock.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments else {
        XCTFail("No arguments received")
        return
      }
      let request = try JSONDecoder().decode(CredentialRequest.self, from: encrypterArguments.data)
      XCTAssertEqual(request, credentialRequest)
      XCTAssertEqual(encrypterArguments.publicKey, mockFetchCredentialContext.credentialEncryptionContext.issuerPublicKey)
      XCTAssertEqual(encrypterArguments.encryptionAlgorithm, mockFetchCredentialContext.credentialEncryptionContext.credentialRequestEncryptionAlgorithm)
      XCTAssertEqual(encrypterArguments.compressionAlgorithm, mockFetchCredentialContext.credentialEncryptionContext.credentialRequestEncryptionZipValue)
    }
  }

  func testFetchCredentialWithContext_success_returnsBatchCredential() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    repository = OpenIDRepository()
    mockResponse(code: 200, data: mockBatchCredentialResponseData, headers: mockJWTHeaders)
    jweDecrypterMock.decryptPayloadPrivateKeyReturnValue = mockBatchCredentialResponseData

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)

    if case .credential(let credentials) = result {
      XCTAssertEqual(credentials.count, 2)
      XCTAssertEqual(credentials.first?.raw, mockCredentialResponse.credentials.first?.credential)
    } else {
      XCTFail("Expected batch credential result")
    }
  }

  func testFetchCredentialWithContext_success_returnsDeferredCredential() async throws {
    mockResponse(code: 202, data: mockCredentialResponseDeferredData, headers: mockJWTHeaders)
    jweDecrypterMock.decryptPayloadPrivateKeyReturnValue = mockCredentialResponseDeferredData

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)

    if case .deferred(let deferredCredentialContext) = result {
      XCTAssertEqual(deferredCredentialContext.transactionId, mockCredentialResponseDeferred.transactionId)
      XCTAssertEqual(deferredCredentialContext.accessToken, mockFetchCredentialContext.accessToken)
      XCTAssertEqual(deferredCredentialContext.format, mockFetchCredentialContext.format)
    }
  }

  func testFetchCredentialWithContext_withDPoP_generatesProofWithAccessTokenHashInput() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: mockJWTHeaders)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContextWithDPoP, credentialRequest: credentialRequest)

    if case .credential = result {
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount, 1)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.url, mockFetchCredentialContextWithDPoP.credentialEndpoint)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.keyPair.identifier, mockFetchCredentialContextWithDPoP.dpopKeyPair?.identifier)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.nonce, mockFetchCredentialContextWithDPoP.dpopNonce)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.accessToken, mockFetchCredentialContextWithDPoP.accessToken.accessToken)
      XCTAssertNil(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.additionalHeaderParameters[ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue])
    } else {
      XCTFail("Expected credential result")
    }
  }

  func testFetchCredentialWithContext_useDPoPNonceChallenge_retriesWithHeaderNonce() async throws {
    let challengedContext = mockFetchCredentialContext.changing(\.authorization, to: IssuanceAuthorization(
      accessToken: AccessToken.Mock.sample,
      dpopKeyPair: VaultKeyPair.Mock.ES256))
    mockResponses([
      (401, CredentialResponseError.Mock.sampleInvalidAccessTokenData, [
        "WWW-Authenticate": "DPoP error=\"use_dpop_nonce\"",
        "DPoP-Nonce": "resource-server-nonce",
      ]),
      (200, mockCredentialResponseData, mockJWTHeaders),
    ])

    let result = try await repository.fetchCredential(with: challengedContext, credentialRequest: credentialRequest)

    if case .credential = result {
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount, 2)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.nonce, "resource-server-nonce")
    } else {
      XCTFail("Expected credential result")
    }
  }

  func testFetchCredentialWithContext_useDPoPNonceAfterRetry_returnsOpenIdRepositoryErrorUseDPoPNonceWithHeaderNonce() async throws {
    let authorization = IssuanceAuthorization(accessToken: AccessToken.Mock.sample, dpopKeyPair: VaultKeyPair.Mock.ES256)
    let challengedContext = mockFetchCredentialContext.changing(\.authorization, to: authorization)
    mockResponses([
      (401, CredentialResponseError.Mock.sampleInvalidAccessTokenData, [
        "WWW-Authenticate": "DPoP error=\"use_dpop_nonce\"",
        "DPoP-Nonce": "resource-server-nonce-1",
      ]),
      (401, CredentialResponseError.Mock.sampleInvalidAccessTokenData, [
        "WWW-Authenticate": "DPoP error=\"use_dpop_nonce\"",
        "DPoP-Nonce": "resource-server-nonce-2",
      ]),
    ])

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: challengedContext, credentialRequest: credentialRequest)) { error in
      XCTAssertEqual(error as? OpenIdRepositoryError, .useDPoPNonce("use_dpop_nonce", "resource-server-nonce-2"))
    }
  }

  func testFetchCredentialWithContext_jweEncrypterThrows_throws() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: mockJWTHeaders)

    jweEncrypterMock.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmThrowableError = TestingError.error
    repository = OpenIDRepository()

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchCredentialWithContext_jweDecrypterThrows_throws() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: mockJWTHeaders)

    jweDecrypterMock.decryptPayloadPrivateKeyThrowableError = TestingError.error
    repository = OpenIDRepository()

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchCredentialWithContext_invalidCredentialResponseSuccessCode_throws() async throws {
    mockResponse(code: 201, data: mockCredentialResponseDeferredData, headers: mockJWTHeaders)

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)) { error in
      XCTAssertEqual(error as? OpenIdRepositoryError, .unsupportedCredentialStatusCode)
    }
  }

  // MARK: - Deferred credential

  func testFetchCredentialFromDeferredEndpoint_success_returnsCredential() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: mockJWTHeaders)

    let result = try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, deferredCredentialRequest: deferredCredentialRequest)

    if case .credential(let credentials) = result {
      XCTAssertEqual(credentials.count, 1)
      XCTAssertEqual(credentials.first?.raw, mockCredentialResponse.credentials.first?.credential)

      guard let encrypterArguments = jweEncrypterMock.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments else {
        XCTFail("No arguments received")
        return
      }
      let request = try JSONDecoder().decode(DeferredCredentialRequest.self, from: encrypterArguments.data)
      XCTAssertEqual(request, deferredCredentialRequest)
      XCTAssertEqual(encrypterArguments.publicKey, mockFetchDeferredCredentialContext.credentialEncryptionContext.issuerPublicKey)
      XCTAssertEqual(encrypterArguments.encryptionAlgorithm, mockFetchDeferredCredentialContext.credentialEncryptionContext.credentialRequestEncryptionAlgorithm)
      XCTAssertEqual(encrypterArguments.compressionAlgorithm, mockFetchDeferredCredentialContext.credentialEncryptionContext.credentialRequestEncryptionZipValue)
    } else {
      XCTFail("Expected credential result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_returnsDeferredCredential() async throws {
    mockResponse(code: 202, data: mockCredentialResponseDeferredData, headers: mockJWTHeaders)
    jweDecrypterMock.decryptPayloadPrivateKeyReturnValue = mockCredentialResponseDeferredData

    let result = try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, deferredCredentialRequest: deferredCredentialRequest)

    if case .deferred(let deferred) = result {
      XCTAssertEqual(deferred.transactionId, mockCredentialResponseDeferred.transactionId)
      XCTAssertEqual(deferred.interval, mockCredentialResponseDeferred.interval)
      XCTAssertEqual(deferred.accessToken.accessToken, mockFetchDeferredCredentialContext.authorization.accessToken.accessToken)
      XCTAssertEqual(deferred.accessToken.tokenType, .bearer)
      XCTAssertEqual(deferred.endpoint, mockFetchDeferredCredentialContext.deferredCredentialEndpoint.absoluteString)
      XCTAssertEqual(deferred.accessToken.refreshToken, mockFetchDeferredCredentialContext.authorization.refreshToken)
    } else {
      XCTFail("Expected deferred result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_withDPoP_generatesProofWithAccessTokenHashInput() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: mockJWTHeaders)
    let context = mockFetchDeferredCredentialContext.changing(\.authorization, to: mockProtectedResourceAuthorization)

    let result = try await repository.fetchCredential(with: context, deferredCredentialRequest: deferredCredentialRequest)

    if case .credential = result {
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount, 1)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.url, mockFetchDeferredCredentialContext.deferredCredentialEndpoint)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.keyPair.identifier, mockProtectedResourceAuthorization.dpopKeyPair?.identifier)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.nonce, mockProtectedResourceAuthorization.resourceServerDPoPNonce)
      XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.accessToken, mockProtectedResourceAuthorization.accessToken.accessToken)
      XCTAssertNil(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.additionalHeaderParameters[ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue])
    } else {
      XCTFail("Expected credential result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_invalidCredentialResponseSuccessCode_throws() async throws {
    mockResponse(code: 201, data: mockCredentialResponseDeferredData, headers: mockJWTHeaders)

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, deferredCredentialRequest: deferredCredentialRequest)) { error in
      XCTAssertEqual(error as? OpenIdRepositoryError, .unsupportedCredentialStatusCode)
    }
  }

  func testFetchCredential_error_throwsNetworkError() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, deferredCredentialRequest: deferredCredentialRequest)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - Status

  func testFetchCredentialStatus_success() async throws {
    mockResponse(code: 200, data: TokenStatusList.Mock.sampleData)
    let expectedJWT = TokenStatusList.Mock.sample
    let jwt = try await repository.fetchCredentialStatus(from: mockUrl)
    XCTAssertEqual(jwt, expectedJWT)
  }

  func testFetchCredentialStatus_failure() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredentialStatus(from: mockUrl)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - Vc Schema

  func testFetchVcSchemaSuccess() async throws {
    let expectedVcSchema = VcSchema()
    mockResponse(code: 200, data: expectedVcSchema)

    let vcSchema = try await repository.fetchVcSchemaData(from: mockUrl)

    XCTAssertEqual(String(data: vcSchema, encoding: .utf8), String(data: expectedVcSchema, encoding: .utf8))
  }

  func testFetchVcSchemaFailure() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchVcSchemaData(from: mockUrl)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - AccessToken

  func testRefreshAccessToken_success() async throws {
    let expectedAccessToken = AccessToken.Mock.sample

    mockResponse(code: 200, data: AccessToken.Mock.sampleData)

    let authorization = try await repository.refreshAccessToken(
      from: mockUrl,
      refreshToken: mockResfrehToken,
      dpopKeyPair: nil,
      dpopNonce: nil)

    XCTAssertEqual(expectedAccessToken, authorization.accessToken)
  }

  func testRefreshAccessToken_withDPoP_generatesProof() async throws {
    let dpopKeyPair = VaultKeyPair.Mock.ES256

    mockResponse(code: 200, data: AccessToken.Mock.sampleData)

    _ = try await repository.refreshAccessToken(
      from: mockUrl,
      refreshToken: mockResfrehToken,
      dpopKeyPair: dpopKeyPair,
      dpopNonce: "dpop-nonce")

    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersCallsCount, 1)
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.method, "POST")
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.url, mockUrl)
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.keyPair.identifier, dpopKeyPair.identifier)
    XCTAssertEqual(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.nonce, "dpop-nonce")
    XCTAssertNil(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.accessToken)
    XCTAssertNil(dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReceivedArguments?.additionalHeaderParameters[ProofJWT.AdditionalHeaderParameter.keyAttestation.rawValue])
  }

  func testRefreshAccessToken_invalidRequest_returnsOpenIdRepositoryErrorInvalidRequest() async throws {
    let responseData = try JSONEncoder().encode(["error": "invalid_request"])
    mockResponse(code: 400, data: responseData)

    do {
      _ = try await repository.refreshAccessToken(
        from: mockUrl,
        refreshToken: mockResfrehToken,
        dpopKeyPair: nil,
        dpopNonce: nil)
      XCTFail("Should have thrown an error")
    } catch {
      guard case .invalidRequest = error as? OpenIdRepositoryError else {
        return XCTFail("Expected invalidRequest")
      }
    }
  }

  func testRefreshAccessToken_failure() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.refreshAccessToken(
      from: mockUrl,
      refreshToken: mockResfrehToken,
      dpopKeyPair: nil,
      dpopNonce: nil))
    { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: Private

  private static let mockIssuerUrl = URL(string: "https://issuer.domain.ch")!
  private static let mockSelectedCredential = CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported(format: .vcSdJwt, vct: "vct")

  // swiftlint: disable all
  private let mockUrl = URL(string: "some://url")!
  private let mockCredentialResponse = CredentialResponseImmediate.Mock.sample
  private let mockCredentialResponseData = CredentialResponseImmediate.Mock.sampleData
  private let mockBatchCredentialResponseData = Data(
    """
    {
      "credentials": [
        { "credential": "\(CredentialResponseImmediate.Mock.sample.credentials[0].credential)" },
        { "credential": "\(CredentialResponseImmediate.Mock.sample.credentials[0].credential)" }
      ]
    }
    """.utf8)
  private let mockCredentialResponseDeferred = CredentialResponseDeferred.Mock.sample
  private let mockCredentialResponseDeferredData = CredentialResponseDeferred.Mock.sampleData
  private let mockFetchCredentialContext = FetchCredentialContext.Mock.sample
  private let mockFetchDeferredCredentialContext = FetchDeferredCredentialContext.Mock.sample
  private let mockProtectedResourceAuthorization = ProtectedResourceAuthorization(
    accessToken: "accessToken",
    accessTokenType: .dpop,
    refreshToken: "refreshToken",
    dpopKeyPair: VaultKeyPair.Mock.ES256,
    dpopNonce: "dpop-nonce")
  private let credentialRequest = CredentialRequest(credentialConfigurationId: FetchCredentialContext.Mock.sample.credentialConfigurationId, proofs: nil, credentialResponseEncryption: .Mock.sample)
  private let deferredCredentialRequest = DeferredCredentialRequest(transactionId: "transactionId", credentialResponseEncryption: .Mock.sample)
  private let mockJWTHeaders = ["Content-Type": "application/jwt"]
  private let jwtResponseMock = "jwt"
  private let jweMock = "jwe"
  private let mockResfrehToken = "refreshToken"
  private let keyIdentifierDidMock = "did:tdw:example"

  private var repository = OpenIDRepository()
  private var jweEncrypterMock = JWEEncrypterProtocolSpy()
  private var jweDecrypterMock = JWEDecrypterProtocolSpy()
  private var dpopGeneratorSpy = DPoPGeneratorProtocolSpy()
  private var didResolverHelperSpy = DidResolverHelperProtocolSpy()

  private var mockFetchCredentialContextWithDPoP: FetchCredentialContext {
    let authorization = IssuanceAuthorization(accessToken: mockFetchCredentialContext.accessToken, dpopKeyPair: VaultKeyPair.Mock.ES256, resourceServerDPoPNonce: "dpop-nonce")
    return mockFetchCredentialContext.changing(\.authorization, to: authorization)
  }

  private func registerMocks() {
    jweEncrypterMock = JWEEncrypterProtocolSpy()
    jweDecrypterMock = JWEDecrypterProtocolSpy()
    dpopGeneratorSpy = DPoPGeneratorProtocolSpy()
    didResolverHelperSpy = DidResolverHelperProtocolSpy()

    Container.shared.didResolverHelper.register { self.didResolverHelperSpy }
    Container.shared.jweEncrypter.register { self.jweEncrypterMock }
    Container.shared.jweDecrypter.register { self.jweDecrypterMock }
    Container.shared.dpopGenerator.register { self.dpopGeneratorSpy }
  }

  private func success() {
    jweEncrypterMock.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReturnValue = jweMock
    jweDecrypterMock.decryptPayloadPrivateKeyReturnValue = mockCredentialResponseData
    dpopGeneratorSpy.generateMethodUrlKeyPairNonceAccessTokenRequestBodyAdditionalHeaderParametersReturnValue = DPoPJWT.Mock.sample
    didResolverHelperSpy.getDidFromReturnValue = keyIdentifierDidMock
  }

  private func credentialIssuerMetadataJwtMocks(
    validatorError: Error? = nil, subject: String = mockIssuerUrl.absoluteString, credentialIssuer: URL = mockIssuerUrl)
    -> (rawString: String, jwt: CredentialIssuerMetadataJWT, validator: JWSValidatorMock<CredentialIssuerMetadataJWT>)?
  {
    let metadata = CredentialIssuerMetadata.Mock.sample.changing(\.credentialIssuer, to: credentialIssuer)
    let jwtRawString = String(decoding: CredentialIssuerMetadataJWT.Mock.sampleData, as: UTF8.self)
    let jwt = CredentialIssuerMetadataJWT(
      subject: subject,
      issuedAt: Date(timeIntervalSince1970: 0),
      expiredAt: nil,
      credentialIssuerMetadata: metadata)
    var jwsDecoderMock = JWSDecoderMock(jwt: jwt, rawPayload: jwtRawString)
    jwsDecoderMock.expectedInput = jwtResponseMock
    let jwsValidatorMock = registerJwsMocks(jwsDecoderMock: jwsDecoderMock)
    jwsValidatorMock.validateThrowableError = validatorError
    return (jwtRawString, jwt, jwsValidatorMock)
  }

  @discardableResult
  private func credentialOpenIdConfigurationJwtMocks(
    validatorError: Error? = nil)
    -> (rawString: String, jwt: OpenIdConfigurationJWT, validator: JWSValidatorMock<OpenIdConfigurationJWT>)?
  {
    let configuration = OpenIdConfiguration.Mock.sample
    let jwtRawString = String(decoding: OpenIdConfiguration.Mock.sampleData, as: UTF8.self)
    let jwt = OpenIdConfigurationJWT(
      subject: mockUrl.absoluteString,
      issuedAt: Date(timeIntervalSince1970: 0),
      expiredAt: nil,
      openIdConfiguration: configuration)
    var jwsDecoderMock = JWSDecoderMock(jwt: jwt)
    jwsDecoderMock.expectedInput = jwtResponseMock
    let jwsValidatorMock = registerJwsMocks(jwsDecoderMock: jwsDecoderMock)
    jwsValidatorMock.validateThrowableError = validatorError
    return (jwtRawString, jwt, jwsValidatorMock)
  }

  private func registerJwsMocks<U: JWT>(jwsDecoderMock: JWSDecoderMock<U>) -> JWSValidatorMock<U> {
    let jwsValidatorMock = JWSValidatorMock<U>()
    Container.shared.jwsDecoder.register { jwsDecoderMock }
    Container.shared.jwsValidator.register { jwsValidatorMock }
    return jwsValidatorMock
  }

  private func mockResponse(code: Int, data: Data = Data(), headers: [String: String]? = nil) {
    NetworkContainer.shared.endpointClosure.register {
      self.createResponse(code: code, data: data, headers: headers)
    }
  }

  private func mockMetadataEndpoints(metadataResponse: EndpointSampleResponse = .networkResponse(404, Data()), oidConnectMetadataResponse: EndpointSampleResponse = .networkResponse(404, Data())) {
    NetworkContainer.shared.endpointByTargetClosure.register {
      { target in
        switch target {
        case OpenIDEndpoint.metadata: metadataResponse
        case OpenIDEndpoint.oidConnectMetadata: oidConnectMetadataResponse
        default:
          fatalError("Unexpected target: \(target)")
        }
      }
    }
  }

  private func mockOpenIdConfigurationEndpoints(openIdConfigResponse: EndpointSampleResponse = .networkResponse(404, Data()), oidConnectResponse: EndpointSampleResponse = .networkResponse(404, Data())) {
    NetworkContainer.shared.endpointByTargetClosure.register {
      { target in
        switch target {
        case OpenIDEndpoint.openIdConfiguration: openIdConfigResponse
        case OpenIDEndpoint.oidConnectOpenIdConfiguration: oidConnectResponse
        default:
          fatalError("Unexpected target: \(target)")
        }
      }
    }
  }

  private func createResponse(for target: TargetType? = nil, code: Int, data: Data = Data(), headers: [String: String]? = nil) -> EndpointSampleResponse {
    guard
      let response = HTTPURLResponse(
        url: target.flatMap { URL(target: $0) } ?? mockUrl,
        statusCode: code,
        httpVersion: nil,
        headerFields: headers) else
    {
      XCTFail("Response error")
      return .networkResponse(code, data)
    }
    return .response(response, data)
  }

  private func mockResponses(_ responses: [(code: Int, data: Data, headers: [String: String]?)]) {
    let queue = ResponseQueue(responses)
    NetworkContainer.shared.endpointClosure.register {
      let nextResponse = queue.next()
      guard
        let response = HTTPURLResponse(
          url: self.mockUrl,
          statusCode: nextResponse.code,
          httpVersion: nil,
          headerFields: nextResponse.headers)
      else {
        XCTFail("Response error")
        return .networkResponse(nextResponse.code, nextResponse.data)
      }
      return .response(response, nextResponse.data)
    }
  }
}

// MARK: - ResponseQueue

private final class ResponseQueue: @unchecked Sendable {

  // MARK: Lifecycle

  init(_ responses: [(code: Int, data: Data, headers: [String: String]?)]) {
    self.responses = responses
  }

  // MARK: Internal

  func next() -> (code: Int, data: Data, headers: [String: String]?) {
    lock.lock()
    defer { lock.unlock() }

    let response = responses.first!
    if needsReplay {
      needsReplay = false
    } else {
      needsReplay = true
      responses.removeFirst()
    }
    return response
  }

  // MARK: Private

  private let lock = NSLock()
  private var responses: [(code: Int, data: Data, headers: [String: String]?)]
  private var needsReplay = true

}
