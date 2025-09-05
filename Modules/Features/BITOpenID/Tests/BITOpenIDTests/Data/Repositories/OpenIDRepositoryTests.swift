import BITCore
import BITNetworking
import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks

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

    XCTAssertEqual(expectedAccessToken.accessToken, accessToken.accessToken)
    XCTAssertEqual(expectedAccessToken.cNonce, accessToken.cNonce)
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

  // MARK: - Credential

  func testFetchCredential_success_returnsCredential() async throws {
    mockResponse(code: 200, data: mockCredentialResponseData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequestBody: credentialRequestBody)

    if case .credential(let credential) = result {
      XCTAssertEqual(credential.raw, mockCredentialResponse.rawCredential)
    }
  }

  func testFetchCredential_success_returnsDeferredCredential() async throws {
    mockResponse(code: 202, data: mockCredentialResponseDeferredData)

    let result = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequestBody: credentialRequestBody)

    if case .deferred(let transactionId, let accessToken, _) = result {
      XCTAssertEqual(transactionId, mockCredentialResponseDeferred.transactionId)
      XCTAssertEqual(accessToken, mockFetchCredentialContext.accessToken.accessToken)
    }
  }

  func testFetchCredential_invalidCredentialResponseSuccessCode_throws() async throws {
    mockResponse(code: 201, data: mockCredentialResponseDeferredData)

    do {
      _ = try await repository.fetchCredential(with: mockFetchCredentialContext, credentialRequestBody: credentialRequestBody)
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

  // MARK: - Trust Statements

  func testTrustStatementsSuccess() async throws {
    let expectedStatements = [TrustStatementPayload.Mock.allFieldsRawSdJwt, TrustStatementPayload.Mock.allFieldsRawSdJwt]
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    let trustStatements = try await repository.fetchTrustStatements(from: mockUrl, for: "did")

    XCTAssertEqual(trustStatements.count, 2)
    XCTAssertEqual(trustStatements[0].payload, TrustStatementPayload.Mock.allFields.payload)
    XCTAssertEqual(trustStatements[1].payload, TrustStatementPayload.Mock.allFields.payload)
  }

  func testTrustStatementsDecodingError() async throws {
    let expectedStatements = ["invalidTrustStatement"]
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    do {
      _ = try await repository.fetchTrustStatements(from: mockUrl, for: "did")
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? SdJWSDecoderError, .invalidRawSdJwt)
    }
  }

  func testTrustStatementsNetworkError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchTrustStatements(from: mockUrl, for: "did")
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
  private let mockCredentialResponse = CredentialResponse.Mock.sample
  private let mockCredentialResponseData = CredentialResponse.Mock.sampleData
  private let mockCredentialResponseDeferred = CredentialResponse.Mock.sampleDeferred
  private let mockCredentialResponseDeferredData = CredentialResponse.Mock.sampleDeferredData
  private let mockFetchCredentialContext = FetchCredentialContext.Mock.sample
  private let credentialRequestBody = VcSdJwtCredentialRequestBody.Mock.sample

  // swiftlint: enable all
  private var repository = OpenIDRepository()

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
