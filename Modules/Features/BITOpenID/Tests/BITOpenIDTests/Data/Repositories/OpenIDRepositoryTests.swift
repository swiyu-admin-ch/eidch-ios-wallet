import BITCore
import BITNetworking
import Factory
import Foundation
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// MARK: - OpenIDRepository

final class OpenIDRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    repository = OpenIDRepository()

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
    XCTAssertEqual(dataMock, response.data)
  }

  func testFetchMetadataSuccess() async throws {
    let expectedMetadata = CredentialMetadata.Mock.sample
    let dataMock = CredentialMetadata.Mock.sampleData
    mockResponse(code: 200, data: dataMock)

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
    guard let mocks = credentialMetadataJwtMocks() else { return }

    repository = OpenIDRepository()

    mockResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)

    let response = try await repository.fetchMetadata(from: mockUrl)

    XCTAssertEqual(mocks.metadata, response.metadata)
    XCTAssertEqual(response.raw, Data(mocks.rawString.utf8))
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedJws?.payload, mocks.jwt)
    XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchMetadataJwtValidationFails() async throws {
    guard let mocks = credentialMetadataJwtMocks(validatorError: TestingError.error) else { return }

    repository = OpenIDRepository()

    mockResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)

    do {
      _ = try await repository.fetchMetadata(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(mocks.validator.validateIssuerDidActivationBufferCallsCount, 1)
    }
  }

  func testFetchMetadataNetworkError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchMetadata(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: - OpenIdConfiguration

  func testFetchOpenIdConfigurationSuccess() async throws {
    let expectedConfiguration = OpenIdConfiguration.Mock.sample
    mockResponse(code: 200, data: OpenIdConfiguration.Mock.sampleData)

    let configuration = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(expectedConfiguration, configuration)
  }

  func testFetchOpenIdConfigurationJwtSuccess() async throws {
    let configuration = OpenIdConfiguration.Mock.sample
    let jwt = OpenIdConfigurationJWT(
      issuer: "issuer",
      subject: mockUrl.absoluteString,
      issuedAt: Date(timeIntervalSince1970: 0),
      expiredAt: nil,
      openIdConfiguration: configuration)

    var jwsDecoderMock = JWSDecoderMock(jwt: jwt)
    jwsDecoderMock.expectedInput = jwtResponseMock
    let jwsValidatorMock = registerJwsMocks(jwsDecoderMock: jwsDecoderMock)

    repository = OpenIDRepository()

    mockResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)

    let response = try await repository.fetchOpenIdConfiguration(from: mockUrl)

    XCTAssertEqual(configuration, response)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferCallsCount, 1)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferReceivedJws?.payload, jwt)
    XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferReceivedActivationBuffer, 0)
  }

  func testFetchOpenIdConfigurationJwtValidationFails() async throws {
    let jwt = OpenIdConfigurationJWT(
      issuer: "issuer",
      subject: mockUrl.absoluteString,
      issuedAt: Date(timeIntervalSince1970: 0),
      expiredAt: nil,
      openIdConfiguration: OpenIdConfiguration.Mock.sample)

    var jwsDecoderMock = JWSDecoderMock(jwt: jwt)
    jwsDecoderMock.expectedInput = jwtResponseMock
    let jwsValidatorMock = registerJwsMocks(jwsDecoderMock: jwsDecoderMock)
    jwsValidatorMock.validateIssuerDidActivationBufferThrowableError = TestingError.error

    repository = OpenIDRepository()

    mockResponse(code: 200, data: Data(jwtResponseMock.utf8), headers: mockJWTHeaders)

    do {
      _ = try await repository.fetchOpenIdConfiguration(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertEqual(jwsValidatorMock.validateIssuerDidActivationBufferCallsCount, 1)
    }
  }

  func testFetchOpenIdConfigurationNetworkError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchOpenIdConfiguration(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
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

  func testFetchAccessToken_invalidGrant() async throws {
    let preAuthorizedCode = "code"

    let mockInvalidGandError = ["error": "invalid_grant"]
    let mockInvalidGandErrorData = try JSONEncoder().encode(mockInvalidGandError)
    mockResponse(code: 400, data: mockInvalidGandErrorData)

    do {
      _ = try await repository.fetchAccessToken(from: mockUrl, preAuthorizedCode: preAuthorizedCode)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .invalidGrant)
    }
  }

  func testFetchAccessToken_unknownBadRequest() async throws {
    let preAuthorizedCode = "code"

    let mockInvalidGandError = ["error": "something_unknown"]
    let mockInvalidGandErrorData = try JSONEncoder().encode(mockInvalidGandError)
    mockResponse(code: 400, data: mockInvalidGandErrorData)

    do {
      _ = try await repository.fetchAccessToken(from: mockUrl, preAuthorizedCode: preAuthorizedCode)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertNotEqual(error.status, .invalidGrant)
    }
  }

  func testFetchAccessToken_failure() async throws {
    let preAuthorizedCode = "code"
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchAccessToken(from: mockUrl, preAuthorizedCode: preAuthorizedCode)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
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

    do {
      _ = try await repository.fetchNonce(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: - Credential

  func testFetchCredentialWithContext_success_returnsCredential() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.credentials.first?.credential)
    }
  }

  func testFetchCredentialWithContext_success_returnsDeferredCredential() async throws {
    mockResponse(code: 202, data: mockCredentialResponseDeferredData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)

    if case .deferred(let deferredCredentialRequest) = result {
      XCTAssertEqual(deferredCredentialRequest.transactionId, mockCredentialResponseDeferred.transactionId)
      XCTAssertEqual(deferredCredentialRequest.accessToken, mockFetchCredentialContext.accessToken.accessToken)
      XCTAssertEqual(deferredCredentialRequest.format, mockFetchCredentialContext.format)
    }
  }

  func testFetchCredentialWithContext_invalidCredentialResponseSuccessCode_throws() async throws {
    mockResponse(code: 201, data: mockCredentialResponseDeferredData)

    do {
      _ = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequest: credentialRequest)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? OpenIdRepositoryError, .unsupportedCredentialStatusCode)
    }
  }

  func testFetchCredentialFromDeferredEndpoint_success() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData)

    let result = try await repository.fetchCredential(from: mockUrl, transactionId: "transactionId", accessToken: "accessToken", format: "format")

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.credentials.first?.credential)
    } else {
      XCTFail("Expected credential result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_returnsDeferredCredential() async throws {
    mockResponse(code: 202, data: mockCredentialResponseDeferredData)

    let result = try await repository.fetchCredential(from: mockUrl, transactionId: "transactionId", accessToken: "accessToken", format: "format")

    if case .deferred(let deferred) = result {
      XCTAssertEqual(deferred.transactionId, mockCredentialResponseDeferred.transactionId)
      XCTAssertEqual(deferred.interval, mockCredentialResponseDeferred.interval)
      XCTAssertEqual(deferred.accessToken, "accessToken")
      XCTAssertEqual(deferred.endpoint, mockUrl.absoluteString)
    } else {
      XCTFail("Expected deferred result")
    }
  }

  func testFetchCredentialFromDeferredEndpoint_invalidCredentialResponseSuccessCode_throws() async throws {
    mockResponse(code: 201, data: mockCredentialResponseDeferredData)

    do {
      _ = try await repository.fetchCredential(from: mockUrl, transactionId: "transactionId", accessToken: "accessToken", format: "format")
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? OpenIdRepositoryError, .unsupportedCredentialStatusCode)
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

    do {
      _ = try await repository.fetchCredentialStatus(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
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

    do {
      _ = try await repository.fetchVcSchemaData(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: Private

  // swiftlint: disable all
  private let mockUrl = URL(string: "some://url")!
  private let mockCredentialResponse = CredentialResponseImmediate.Mock.sample
  private let mockCredentialResponseData = CredentialResponseImmediate.Mock.sampleData
  private let mockCredentialResponseDeferred = CredentialResponseDeferred.Mock.sample
  private let mockCredentialResponseDeferredData = CredentialResponseDeferred.Mock.sampleData
  private let mockFetchCredentialContext = FetchCredentialContext.Mock.sample
  private let credentialRequest = CredentialRequest.Mock.sample
  private let mockJWTHeaders = ["Content-Type": "application/jwt"]
  private let jwtResponseMock = "jwt"

  // swiftlint: enable all
  private var repository = OpenIDRepository()

  private func credentialMetadataJwtMocks(
    validatorError: Error? = nil)
    -> (metadata: CredentialMetadata, rawString: String, jwt: CredentialMetadataJWT, validator: JWSValidatorMock<CredentialMetadataJWT>)?
  {
    let metadata = CredentialMetadata.Mock.sample
    guard let jwtRawString = String(data: CredentialMetadata.Mock.sampleData, encoding: .utf8) else {
      XCTFail("Unable to build raw payload")
      return nil
    }
    let jwt = CredentialMetadataJWT(
      issuer: nil,
      subject: mockUrl.absoluteString,
      issuedAt: Date(timeIntervalSince1970: 0),
      expiredAt: nil,
      credentialMetadata: metadata)
    var jwsDecoderMock = JWSDecoderMock(jwt: jwt, rawPayload: jwtRawString)
    jwsDecoderMock.expectedInput = jwtResponseMock
    let jwsValidatorMock = registerJwsMocks(jwsDecoderMock: jwsDecoderMock)
    jwsValidatorMock.validateIssuerDidActivationBufferThrowableError = validatorError
    return (metadata, jwtRawString, jwt, jwsValidatorMock)
  }

  private func registerJwsMocks<U: JWT>(jwsDecoderMock: JWSDecoderMock<U>) -> JWSValidatorMock<U> {
    let jwsValidatorMock = JWSValidatorMock<U>()
    Container.shared.jwsDecoder.register { jwsDecoderMock }
    Container.shared.jwsValidator.register { jwsValidatorMock }
    return jwsValidatorMock
  }

  private func mockResponse(code: Int, data: Data = Data(), headers: [String: String]? = nil) {
    NetworkContainer.shared.endpointClosure.register {
      guard
        let response = HTTPURLResponse(
          url: self.mockUrl,
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
}
