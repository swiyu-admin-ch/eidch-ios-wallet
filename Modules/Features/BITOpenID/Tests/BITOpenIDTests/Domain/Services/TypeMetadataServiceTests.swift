// swiftlint:disable all
import Factory
import XCTest
@testable import BITCrypto
@testable import BITNetworking
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

final class TypeMetadataServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = OpenIDRepositoryProtocolSpy()
    sriValidator = SRIValidatorProtocolSpy()

    Container.shared.openIDRepository.register { self.repository }
    Container.shared.sriValidator.register { self.sriValidator }

    service = TypeMetadataService()
  }

  func testFetchTypeMetadata_success() async throws {
    sriValidator.validateWithReturnValue = true
    repository.fetchTypeMetadataFromReturnValue = mockResponse

    let typeMetadata = try await service.fetch(mockVcSdJwt)

    XCTAssertEqual(typeMetadata, Self.mockTypeMetadata)
    XCTAssertEqual(repository.fetchTypeMetadataFromReceivedUrl, URL(string: mockVcSdJwt.vct))
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.data, Self.mockTypeMetadataData)
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.integrity, mockVcSdJwt.vctIntegrity)
  }

  func testTypeMetadata_vctIsNotAnURL() async throws {
    var vcSdJwt = mockVcSdJwt
    vcSdJwt.vct = "not-a-url"

    let typeMetadata = try await service.fetch(vcSdJwt)

    XCTAssertNil(typeMetadata)
    XCTAssertFalse(sriValidator.validateWithCalled)
    XCTAssertFalse(repository.fetchTypeMetadataFromCalled)
  }

  func testTypeMetadata_fetchFailed() async throws {
    repository.fetchTypeMetadataFromThrowableError = TestingError.error

    do {
      _ = try await service.fetch(mockVcSdJwt)
    } catch TestingError.error {
      XCTAssertFalse(sriValidator.validateWithCalled)
      XCTAssertTrue(repository.fetchTypeMetadataFromCalled)
    } catch {
      XCTFail("Expected a TestingError.error")
    }
  }

  func testTypeMetadata_vctMismatch() async throws {
    var vcSdJwt = mockVcSdJwt
    vcSdJwt.vct = "https://other.com"
    repository.fetchTypeMetadataFromReturnValue = mockResponse

    do {
      _ = try await service.fetch(vcSdJwt)
      XCTFail("Expected a FetchCredentialError.vctMismatch")
    } catch TypeMetadataServiceError.vctMismatch {
      XCTAssertTrue(repository.fetchTypeMetadataFromCalled)
      XCTAssertEqual(repository.fetchTypeMetadataFromCallsCount, 1)
      XCTAssertFalse(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Expected a FetchCredentialError.vctMismatch")
    }
  }

  func testTypeMetadata_missingIntegrity() async throws {
    var vcSdJwt = mockVcSdJwt
    vcSdJwt.vctIntegrity = nil
    repository.fetchTypeMetadataFromReturnValue = mockResponse

    do {
      _ = try await service.fetch(vcSdJwt)
      XCTFail("Expected a FetchCredentialError.missingVctIntegrity")
    } catch TypeMetadataServiceError.missingVctIntegrity {
      XCTAssertTrue(repository.fetchTypeMetadataFromCalled)
      XCTAssertEqual(repository.fetchTypeMetadataFromCallsCount, 1)
      XCTAssertFalse(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Expected a FetchCredentialError.missingVctIntegrity")
    }
  }

  func testTypeMetadata_sriValidationFailed() async throws {
    repository.fetchTypeMetadataFromReturnValue = mockResponse
    sriValidator.validateWithReturnValue = false

    do {
      _ = try await service.fetch(mockVcSdJwt)
      XCTFail("Expected a FetchCredentialError.typeMetadataInvalidIntegrity error")
    } catch TypeMetadataServiceError.typeMetadataInvalidIntegrity {
      XCTAssertTrue(sriValidator.validateWithCalled)
      XCTAssertEqual(sriValidator.validateWithCallsCount, 1)
    } catch {
      XCTFail("Expected a FetchCredentialError.typeMetadataInvalidIntegrity error")
    }
  }

  func testTypeMetadata_sriValidationError() async throws {
    repository.fetchTypeMetadataFromReturnValue = mockResponse
    sriValidator.validateWithThrowableError = TestingError.error

    do {
      _ = try await service.fetch(mockVcSdJwt)
      XCTFail("Expected a FetchCredentialError.typeMetadataInvalidIntegrity error")
    } catch TypeMetadataServiceError.typeMetadataInvalidIntegrity {
      XCTAssertTrue(sriValidator.validateWithCalled)
      XCTAssertEqual(sriValidator.validateWithCallsCount, 1)
    } catch {
      XCTFail("Expected a FetchCredentialError.typeMetadataInvalidIntegrity error")
    }
  }

  // MARK: Private

  private static let mockTypeMetadata = TypeMetadata.Mock.sampleStandard
  private static let mockTypeMetadataData = TypeMetadata.Mock.sampleStandardData

  private let mockResponse = NetworkResponse(object: mockTypeMetadata, data: mockTypeMetadataData)

  private let mockVcSdJwt = VcSdJwtPayload.Mock.samplePayload

  private var sriValidator: SRIValidatorProtocolSpy!
  private var repository: OpenIDRepositoryProtocolSpy!
  private var service: TypeMetadataService!

}

// swiftlint:enable all
