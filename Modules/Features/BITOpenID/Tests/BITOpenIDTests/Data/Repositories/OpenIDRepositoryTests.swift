// swiftlint:disable force_cast force_try
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

// MARK: - OpenIDRepository

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
    XCTAssertEqual(expectedTypeMetadata.extends, typeMetadata.extends)
    XCTAssertEqual(expectedTypeMetadata.claims?.count, typeMetadata.claims?.count)
    XCTAssertEqual(expectedTypeMetadata.schemaUrl, typeMetadata.schemaUrl)
    XCTAssertEqual(expectedTypeMetadata.schemaIntegrity, typeMetadata.schemaIntegrity)
    XCTAssertEqual(expectedTypeMetadata.schema, typeMetadata.schema)
    XCTAssertEqual(dataMock, response.response.data)
  }

  func testFetchMetadataSuccess() async throws {
    let expectedMetadata = CredentialIssuerMetadata.Mock.sample
    let dataMock = CredentialIssuerMetadata.Mock.sampleData
    mockMetadataEndpoints(metadataResponse: .networkResponse(200, dataMock))

    let response = try await repository.fetchMetadata(from: mockUrl)
    let metadata = response.metadata

    XCTAssertEqual(expectedMetadata.credentialEndpoint, metadata.credentialEndpoint)
    XCTAssertEqual(expectedMetadata.credentialIssuer, metadata.credentialIssuer)
    XCTAssertEqual(expectedMetadata.credentialConfigurationsSupported.count, metadata.credentialConfigurationsSupported.count)
    XCTAssertEqual(expectedMetadata.display?.count, metadata.display?.count)
    XCTAssertEqual(expectedMetadata.preferredDisplay, metadata.preferredDisplay)
    XCTAssertEqual(dataMock, response.raw)
  }

  func testFetchMetadataJwtSuccess() async throws {
    guard let mocks = credentialIssuerMetadataJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtResponse)

    let response = try await repository.fetchMetadata(from: mockUrl)

    XCTAssertEqual(mocks.metadata, response.metadata)
    XCTAssertEqual(response.raw, Data(mocks.rawString.utf8))
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchMetadataJwtSuccess_oidConnectMetadata() async throws {
    guard let mocks = credentialIssuerMetadataJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: .networkResponse(500, Data()), oidConnectMetadataResponse: jwtResponse)

    let response = try await repository.fetchMetadata(from: mockUrl)

    XCTAssertEqual(mocks.metadata, response.metadata)
    XCTAssertEqual(response.raw, Data(mocks.rawString.utf8))
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchMetadataJwtValidationFails() async throws {
    credentialIssuerMetadataJwtMocks(validatorError: JWSValidatorError.expired)

    repository = OpenIDRepository()

    let jwtSample = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtSample)

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: mockUrl)) { error in
      XCTAssertEqual(error as? JWSValidatorError, .expired)
    }
  }

  func testFetchMetadataJwtSignatureValidationFails() async throws {
    credentialIssuerMetadataJwtMocks(validatorError: JWSSignatureValidatorError.invalidSignature)

    repository = OpenIDRepository()

    let jwtSample = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockMetadataEndpoints(metadataResponse: jwtSample)

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: mockUrl)) { error in
      XCTAssertEqual(error as? JWSSignatureValidatorError, .invalidSignature)
    }
  }

  func testFetchMetadataDecodingFails() async throws {
    mockMetadataEndpoints(metadataResponse: .networkResponse(200, Data()))

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: mockUrl)) { error in
      XCTAssertTrue(error is DecodingError)
    }
  }

  func testFetchMetadata_metadataReturns500_fetchesMetadataFromOidConnectUrl() async throws {
    let dataMock = CredentialIssuerMetadata.Mock.sampleData
    mockMetadataEndpoints(metadataResponse: .networkResponse(500, Data()), oidConnectMetadataResponse: createResponse(code: 200, data: dataMock))

    let response = try await repository.fetchMetadata(from: mockUrl)

    XCTAssertEqual(response.raw, dataMock)
  }

  func testFetchMetadata_metadataReturns404AndOidConnectReturns500_throwsError() async throws {
    mockMetadataEndpoints(metadataResponse: .networkResponse(404, Data()), oidConnectMetadataResponse: .networkResponse(500, Data()))

    await XCTAssertThrowsErrorAsync(try await repository.fetchMetadata(from: mockUrl)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - OpenIdConfiguration

  func testFetchOpenIdConfigurationSuccess() async throws {
    let expectedConfiguration = OpenIdConfiguration.Mock.sample
    let dataMock = OpenIdConfiguration.Mock.sampleData
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: .networkResponse(200, dataMock))

    let configuration = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(expectedConfiguration, configuration)
  }

  func testFetchOpenIdConfigurationJwtSuccess() async throws {
    guard let mocks = credentialOpenIdConfigurationJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: jwtResponse)

    let response = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(mocks.configuration, response)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchOpenIdConfigurationJwtSuccess_oidConnectOpenIdConfiguration() async throws {
    guard let mocks = credentialOpenIdConfigurationJwtMocks() else { return }

    repository = OpenIDRepository()

    let jwtResponse = createResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: .networkResponse(500, Data()), oidConnectResponse: jwtResponse)

    let response = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(mocks.configuration, response)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedActivationBuffer, 0)
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
    let dataMock = OpenIdConfiguration.Mock.sampleData
    mockOpenIdConfigurationEndpoints(openIdConfigResponse: .networkResponse(500, Data()), oidConnectResponse: createResponse(code: 200, data: dataMock))

    let response = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(response, OpenIdConfiguration.Mock.sample)
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

    let accessToken = try await repository.fetchAccessToken(from: mockUrl, preAuthorizedCode: preAuthorizedCode)

    XCTAssertEqual(expectedAccessToken, accessToken)
  }

  func testFetchAccessToken_error_errorPassedToParser() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchAccessToken(from: mockUrl, preAuthorizedCode: "code")) { _ in
      XCTAssertEqual(oAuthErrorParserProtocolSpy.parseCallsCount, 1)
      guard let error = oAuthErrorParserProtocolSpy.parseReceivedError as? NetworkError else {
        return XCTFail("Expected parser to receive a NetworkError")
      }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: - Nonce

  func testFetchNonce_success() async throws {
    let expectedNonce = Nonce.Mock.default

    mockResponse(code: 200, data: Nonce.Mock.defaultData)

    let nonce = try await repository.fetchNonce(from: mockUrl)

    XCTAssertEqual(expectedNonce, nonce)
  }

  func testFetchNonce_failure() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchNonce(from: mockUrl)) { error in
      XCTAssertEqual((error as! NetworkError).status, .internalServerError)
    }
  }

  // MARK: - Credential

  func testFetchCredentialWithContext_success_returnsCredential() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: .json(credentialRequest))

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.credentials.first?.credential)
    }
  }

  func testFetchCredentialWithContext_success_returnsBatchCredential() async throws {
    Container.shared.isBatchIssuanceEnabled.register { true }
    repository = OpenIDRepository()
    mockResponse(code: 200, data: mockBatchCredentialResponseData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: .json(credentialRequest))

    if case .batch(let credentials) = result {
      XCTAssertEqual(credentials.count, 2)
      XCTAssertEqual(credentials.first?.raw, mockCredentialResponse.credentials.first?.credential)
    } else {
      XCTFail("Expected batch credential result")
    }
  }

  func testFetchCredentialWithContext_batchDisabled_returnsFirstCredential() async throws {
    Container.shared.isBatchIssuanceEnabled.register { false }
    repository = OpenIDRepository()
    mockResponse(code: 200, data: mockBatchCredentialResponseData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: .json(credentialRequest))

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.credentials.first?.credential)
    } else {
      XCTFail("Expected single credential result")
    }
  }

  func testFetchCredentialWithContext_success_returnsDeferredCredential() async throws {
    mockResponse(code: 202, data: mockCredentialResponseDeferredData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: .json(credentialRequest))

    if case .deferred(let deferredCredentialContext) = result {
      XCTAssertEqual(deferredCredentialContext.transactionId, mockCredentialResponseDeferred.transactionId)
      XCTAssertEqual(deferredCredentialContext.accessToken, mockFetchCredentialContext.accessToken.accessToken)
      XCTAssertEqual(deferredCredentialContext.format, mockFetchCredentialContext.format)
    }
  }

  func testFetchCredentialWithContext_encryptionContext_success() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: ["Content-Type": "application/jwt"])

    let result = try await repository.fetchCredential(with: FetchCredentialContext.Mock.sampleCredentialEncryption, credentialRequest: .jwe(jweMock))

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.credentials.first?.credential)
    }
  }

  func testFetchCredentialWithContext_encryptionContextMissingPrivatekey_throwsMissingCredentialResponsePrivateKey() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: ["Content-Type": "application/jwt"])

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: FetchCredentialContext.Mock.sampleCredentialEncryptionNoResponseEncryption, credentialRequest: .jwe(jweMock))) { _ in
      guard let error = openID4VCIErrorParserSpy.parseReceivedError as? OpenIdRepositoryError else {
        return XCTFail("Expected OpenIdRepositoryError")
      }
      XCTAssertEqual(error, .missingCredentialResponsePrivateKey)
    }
  }

  func testFetchCredentialWithContext_jweDecrypterThrows_throws() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData, headers: ["Content-Type": "application/jwt"])

    jweDecrypterMock.decryptPayloadPrivateKeyThrowableError = TestingError.error
    repository = OpenIDRepository()

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: FetchCredentialContext.Mock.sampleCredentialEncryption, credentialRequest: .jwe(jweMock))) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchCredentialWithContext_invalidCredentialResponseSuccessCode_throws() async throws {
    mockResponse(code: 201, data: mockCredentialResponseDeferredData)

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: .json(credentialRequest))) { _ in
      guard let error = openID4VCIErrorParserSpy.parseReceivedError as? OpenIdRepositoryError else {
        return XCTFail("Expected OpenIdRepositoryError")
      }
      XCTAssertEqual(error, .unsupportedCredentialStatusCode)
    }
  }

  // MARK: - Deferred credential

  func testFetchCredentialFromDeferredEndpoint_nonEncrypted_success() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData)

    let result = try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, requestBody: deferredCredentialRequestBody)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.credentials.first?.credential)
    } else {
      XCTFail("Expected credential result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_encryptedResponse_success() async throws {
    mockResponse(code: 200, data: Data(jweMock.utf8), headers: mockJWTHeaders)

    let result = try await repository.fetchCredential(with: .Mock.sampleWithEncryption, requestBody: deferredCredentialRequestBody)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.credentials.first?.credential)
    } else {
      XCTFail("Expected credential result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_returnsDeferredCredential() async throws {
    mockResponse(code: 202, data: mockCredentialResponseDeferredData)

    let result = try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, requestBody: deferredCredentialRequestBody)

    if case .deferred(let deferred) = result {
      XCTAssertEqual(deferred.transactionId, mockCredentialResponseDeferred.transactionId)
      XCTAssertEqual(deferred.interval, mockCredentialResponseDeferred.interval)
      XCTAssertEqual(deferred.accessToken, "accessToken")
      XCTAssertEqual(deferred.endpoint, mockFetchDeferredCredentialContext.deferredCredentialEndpoint.absoluteString)
      XCTAssertEqual(deferred.refreshToken, mockFetchDeferredCredentialContext.refreshToken)
    } else {
      XCTFail("Expected deferred result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_invalidCredentialResponseSuccessCode_throws() async throws {
    mockResponse(code: 201, data: mockCredentialResponseDeferredData)

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, requestBody: deferredCredentialRequestBody)) { _ in
      guard let error = openID4VCIErrorParserSpy.parseReceivedError as? OpenIdRepositoryError else {
        return XCTFail("Expected OpenIdRepositoryError")
      }
      XCTAssertEqual(error, .unsupportedCredentialStatusCode)
    }
  }

  func testFetchCredential_error_openID4VCIErrorParserReturnsParsedError() async throws {
    mockResponse(code: 500)

    await XCTAssertThrowsErrorAsync(try await repository.fetchCredential(with: mockFetchDeferredCredentialContext, requestBody: deferredCredentialRequestBody)) { _ in
      XCTAssertEqual(openID4VCIErrorParserSpy.parseCallsCount, 1)
      guard let error = openID4VCIErrorParserSpy.parseReceivedError as? NetworkError else {
        return XCTFail("Expected parser to receive a NetworkError")
      }
      XCTAssertEqual(error.status, .internalServerError)
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

    let accessToken = try await repository.refreshAccessToken(from: mockUrl, refreshToken: mockResfrehToken)

    XCTAssertEqual(expectedAccessToken, accessToken)
  }

  func testRefreshAccessToken_badRequest_passesErrorToParser() async throws {
    mockResponse(code: 400)

    await XCTAssertThrowsErrorAsync(try await repository.refreshAccessToken(from: mockUrl, refreshToken: mockResfrehToken)) { _ in
      XCTAssertEqual(oAuthErrorParserProtocolSpy.parseCallsCount, 1)
      guard let error = oAuthErrorParserProtocolSpy.parseReceivedError as? NetworkError else {
        return XCTFail("Expected parser to receive a NetworkError")
      }
      XCTAssertEqual(error.status, .badRequest)
    }
  }

  // MARK: Private

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
  private let credentialRequest = CredentialRequest.Mock.sample
  private let deferredCredentialRequestBody = DeferredCredentialRequestBody.json(
    DeferredCredentialRequest(
      transactionId: "transactionId",
      credentialResponseEncryption: nil))
  private let mockJWTHeaders = ["Content-Type": "application/jwt"]
  private let jwtResponseMock = "jwt"
  private let jweMock = "jwe"
  private let mockResfrehToken = "refreshToken"

  private var repository = OpenIDRepository()
  private var jweDecrypterMock = JWEDecrypterProtocolSpy()
  private var openID4VCIErrorParserSpy = OpenID4VCIErrorParserProtocolSpy()
  private var oAuthErrorParserProtocolSpy = OAuthErrorParserProtocolSpy()

  private func registerMocks() {
    jweDecrypterMock = JWEDecrypterProtocolSpy()

    Container.shared.jweDecrypter.register { self.jweDecrypterMock }
    Container.shared.openID4VCIErrorParser.register { self.openID4VCIErrorParserSpy }
    Container.shared.oAuthErrorParser.register { self.oAuthErrorParserProtocolSpy }
  }

  private func success() {
    jweDecrypterMock.decryptPayloadPrivateKeyReturnValue = mockCredentialResponseData
    openID4VCIErrorParserSpy.parseReturnValue = TestingError.error
    oAuthErrorParserProtocolSpy.parseReturnValue = TestingError.error
  }

  private func credentialIssuerMetadataJwtMocks(
    validatorError: Error? = nil)
    -> (metadata: CredentialIssuerMetadata, rawString: String, jwt: CredentialIssuerMetadataJWT, validator: JWSValidatorMock<CredentialIssuerMetadataJWT>)?
  {
    let metadata = CredentialIssuerMetadata.Mock.sample
    let jwtRawString = String(decoding: CredentialIssuerMetadata.Mock.sampleData, as: UTF8.self)
    let jwt = CredentialIssuerMetadataJWT(
      issuer: nil,
      subject: mockUrl.absoluteString,
      issuedAt: Date(timeIntervalSince1970: 0),
      expiredAt: nil,
      credentialIssuerMetadata: metadata)
    var jwsDecoderMock = JWSDecoderMock(jwt: jwt, rawPayload: jwtRawString)
    jwsDecoderMock.expectedInput = jwtResponseMock
    let jwsValidatorMock = registerJwsMocks(jwsDecoderMock: jwsDecoderMock)
    jwsValidatorMock.validateIssuerDidActivationBufferThrowableError = validatorError
    return (metadata, jwtRawString, jwt, jwsValidatorMock)
  }

  @discardableResult
  private func credentialOpenIdConfigurationJwtMocks(
    validatorError: Error? = nil)
    -> (configuration: OpenIdConfiguration, rawString: String, jwt: OpenIdConfigurationJWT, validator: JWSValidatorMock<OpenIdConfigurationJWT>)?
  {
    let configuration = OpenIdConfiguration.Mock.sample
    let jwtRawString = String(decoding: OpenIdConfiguration.Mock.sampleData, as: UTF8.self)
    let jwt = OpenIdConfigurationJWT(
      issuer: "issuer",
      subject: mockUrl.absoluteString,
      issuedAt: Date(timeIntervalSince1970: 0),
      expiredAt: nil,
      openIdConfiguration: configuration)
    var jwsDecoderMock = JWSDecoderMock(jwt: jwt)
    jwsDecoderMock.expectedInput = jwtResponseMock
    let jwsValidatorMock = registerJwsMocks(jwsDecoderMock: jwsDecoderMock)
    jwsValidatorMock.validateIssuerDidActivationBufferThrowableError = validatorError
    return (configuration, jwtRawString, jwt, jwsValidatorMock)
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
}
