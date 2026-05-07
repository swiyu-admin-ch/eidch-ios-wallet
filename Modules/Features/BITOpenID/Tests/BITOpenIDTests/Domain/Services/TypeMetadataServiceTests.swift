import Factory
import Moya
import XCTest
@testable import BITCrypto
@testable import BITNetworking
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

// swiftlint:disable force_unwrapping implicitly_unwrapped_optional

final class TypeMetadataServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    service = TypeMetadataService()
    createSuccessState()
  }

  func testFetchTypeMetadata_success_assertParameters() async throws {
    let typeMetadata = try await service.fetch(from: typeMetadataUriMock, vct: Self.vctMock)

    XCTAssertEqual(typeMetadata, Self.mockTypeMetadata)
    XCTAssertEqual(repository.fetchTypeMetadataFromReceivedUrl, Self.vctUrlMock)
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.data, Self.mockTypeMetadataData)
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.integrity, Self.vctIntegrityMock)
  }

  func testFetchTypeMetadata_success_assertCount() async throws {
    _ = try await service.fetch(from: typeMetadataUriMock, vct: Self.vctMock)

    XCTAssertEqual(repository.fetchTypeMetadataFromCallsCount, 1)
    XCTAssertEqual(sriValidator.validateWithCallsCount, 1)
  }

  func testTypeMetadata_fetchFailed_throws() async throws {
    repository.fetchTypeMetadataFromThrowableError = TestingError.error

    do {
      _ = try await service.fetch(from: typeMetadataUriMock, vct: Self.vctMock)
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testTypeMetadata_vctMismatch() async throws {
    do {
      _ = try await service.fetch(from: typeMetadataUriMock, vct: "other")
      XCTFail("Expected a FetchCredentialError.vctMismatch")
    } catch {
      XCTAssertEqual(error as? TypeMetadataServiceError, .vctMismatch)
    }
  }

  func testTypeMetadata_missingIntegrity() async throws {
    let typeMetadataUriMock = TypeMetadataUri(url: Self.vctUrlMock, integrity: nil)

    let typeMetadata = try await service.fetch(from: typeMetadataUriMock, vct: Self.vctMock)

    XCTAssertNotNil(typeMetadata)
    XCTAssertFalse(sriValidator.validateWithCalled)
  }

  func testTypeMetadata_sriValidationFailed() async throws {
    sriValidator.validateWithReturnValue = false

    do {
      _ = try await service.fetch(from: typeMetadataUriMock, vct: Self.vctMock)
      XCTFail("Expected a FetchCredentialError.typeMetadataInvalidIntegrity error")
    } catch {
      XCTAssertEqual(error as? TypeMetadataServiceError, .typeMetadataInvalidIntegrity)
    }
  }

  func testTypeMetadata_sriValidationError() async throws {
    sriValidator.validateWithThrowableError = TestingError.error

    do {
      _ = try await service.fetch(from: typeMetadataUriMock, vct: Self.vctMock)
      XCTFail("Expected a FetchCredentialError.typeMetadataInvalidIntegrity error")
    } catch {
      XCTAssertEqual(error as? TypeMetadataServiceError, .typeMetadataInvalidIntegrity)
    }
  }

  // MARK: Private

  private static let mockTypeMetadata = TypeMetadata.Mock.sampleStandard
  private static let mockTypeMetadataData = TypeMetadata.Mock.sampleStandardData
  private static let vctMock = "https://credentials.example.com/identity_credential"
  private static let vctUrlMock = URL(string: vctMock)!
  private static let vctIntegrityMock = "vctIntegrity"

  private var service: TypeMetadataService!

  private let typeMetadataUriMock = TypeMetadataUri(url: vctUrlMock, integrity: vctIntegrityMock)

  private var sriValidator: SRIValidatorProtocolSpy!
  private var repository: OpenIDRepositoryProtocolSpy!

  private func registerMocks() {
    repository = OpenIDRepositoryProtocolSpy()
    sriValidator = SRIValidatorProtocolSpy()

    Container.shared.openIDRepository.register { self.repository }
    Container.shared.sriValidator.register { self.sriValidator }
  }

  private func createSuccessState() {
    sriValidator.validateWithReturnValue = true
    repository.fetchTypeMetadataFromReturnValue = (object: Self.mockTypeMetadata, response: Moya.Response(statusCode: 200, data: Self.mockTypeMetadataData))
  }
}
