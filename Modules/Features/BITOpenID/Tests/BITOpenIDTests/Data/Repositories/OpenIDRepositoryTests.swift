import BITCore
import BITNetworking
import BITSdJWT
import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
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
    mockResponse(code: 200, data: TypeMetadata.Mock.sampleStandardData)

    let (typeMetadata, _) = try await repository.fetchTypeMetadata(from: mockUrl)

    XCTAssertEqual(expectedTypeMetadata.displays, typeMetadata.displays)
    XCTAssertEqual(expectedTypeMetadata.vct, typeMetadata.vct)
    XCTAssertEqual(expectedTypeMetadata.name, typeMetadata.name)
    XCTAssertEqual(expectedTypeMetadata.description, typeMetadata.description)
    XCTAssertEqual(expectedTypeMetadata.extends, typeMetadata.extends)
    XCTAssertEqual(expectedTypeMetadata.claims?.count, typeMetadata.claims?.count)
    XCTAssertEqual(expectedTypeMetadata.schemaUrl, typeMetadata.schemaUrl)
    XCTAssertEqual(expectedTypeMetadata.schemaIntegrity, typeMetadata.schemaIntegrity)
    XCTAssertEqual(expectedTypeMetadata.schema, typeMetadata.schema)
  }

  func testFetchMetadataSuccess() async throws {
    let expectedMetadata = CredentialMetadata.Mock.sample
    mockResponse(code: 200, data: CredentialMetadata.Mock.sampleData)

    let metadata = try await repository.fetchMetadata(from: mockUrl)

    XCTAssertEqual(expectedMetadata.credentialEndpoint, metadata.credentialEndpoint)
    XCTAssertEqual(expectedMetadata.credentialIssuer, metadata.credentialIssuer)
    XCTAssertEqual(expectedMetadata.credentialConfigurationsSupported.count, metadata.credentialConfigurationsSupported.count)
    XCTAssertEqual(expectedMetadata.display?.count, metadata.display?.count)
    XCTAssertEqual(expectedMetadata.preferredDisplay, metadata.preferredDisplay)
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

  func testFetchCredential_success() async throws {
    let accessToken = AccessToken.Mock.sample
    let credentialRequestBody = CredentialRequestBody.Mock.sample

    mockResponse(code: 200, data: CredentialResponse.Mock.sampleData)

    let credentialResponse = try await repository.fetchCredential(from: mockUrl, credentialRequestBody: credentialRequestBody, acccessToken: accessToken)
    XCTAssertEqual(credentialResponse.rawCredential, CredentialResponse.Mock.sample.rawCredential)
    XCTAssertNil(credentialResponse.transactionId)
    XCTAssertNil(credentialResponse.cNonce)
    XCTAssertNil(credentialResponse.cNonceExpiresIn)
  }

  func testFetchCredential_failure() async throws {
    let accessToken = AccessToken.Mock.sample
    let credentialRequestBody = CredentialRequestBody.Mock.sample
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchCredential(from: mockUrl, credentialRequestBody: credentialRequestBody, acccessToken: accessToken)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
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

    do {
      _ = try await repository.fetchCredentialStatus(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: - RequestObject

  func testFetchRequestObjectSuccess() async throws {
    let expectedRequestObject = RequestObject.Mock.VcSdJwt.jsonSampleData
    mockResponse(code: 200, data: expectedRequestObject)

    let requestObject = try await repository.fetchRequestObject(from: mockUrl)

    XCTAssertEqual(String(data: requestObject, encoding: .utf8), String(data: expectedRequestObject, encoding: .utf8))
  }

  func testFetchRequestObject_GoneError_ReturnsPresentationProcessClosedError() async throws {
    mockResponse(code: 410)

    do {
      _ = try await repository.fetchRequestObject(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? OpenIdRepositoryError else { return XCTFail("Expected a OpenIdRepositoryError") }
      XCTAssertEqual(error, .presentationProcessClosed)
    }
  }

  func testFetchRequestObject_NotFoundError_ReturnsAuthorizationRequestObjectNotFoundError() async throws {
    mockResponse(code: 404)

    do {
      _ = try await repository.fetchRequestObject(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? OpenIdRepositoryError else { return XCTFail("Expected a OpenIdRepositoryError") }
      XCTAssertEqual(error, .authorizationRequestObjectNotFound)
    }
  }

  func testFetchRequestObjectFailure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchRequestObject(from: mockUrl)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: - Trust Statements

  func testTrustStatementsSuccess() async throws {
    let expectedStatements = [ TrustStatementPayload.Mock.sdJwtSample, TrustStatementPayload.Mock.sdJwtSample]
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    let trustStatements = try await repository.fetchTrustStatements(from: mockUrl, issuerDid: "did")

    XCTAssertEqual(trustStatements.count, 2)
    XCTAssertEqual(trustStatements[0].payload, TrustStatementPayload.Mock.validSamplePayload)
    XCTAssertEqual(trustStatements[1].payload, TrustStatementPayload.Mock.validSamplePayload)
  }

  func testTrustStatementsNetworkError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchTrustStatements(from: mockUrl, issuerDid: "did")
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
  // swiftlint: enable all
  private var repository = OpenIDRepository()

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
