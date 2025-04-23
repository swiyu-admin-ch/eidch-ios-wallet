// swiftlint:disable all
import Factory
import XCTest
@testable import BITCrypto
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
    repository.fetchTypeMetadataFromReturnValue = (mockTypeMetadata, mockTypeMetadataData)

    let typeMetadata = try await service.fetch(mockVcSdJwt)

    XCTAssertNotNil(typeMetadata)
    XCTAssertEqual(repository.fetchTypeMetadataFromReceivedUrl, URL(string: mockVcSdJwt.vct))
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.data, mockTypeMetadataData)
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
    repository.fetchTypeMetadataFromReturnValue = (mockTypeMetadata, mockTypeMetadataData)

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
    repository.fetchTypeMetadataFromReturnValue = (mockTypeMetadata, mockTypeMetadataData)

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
    repository.fetchTypeMetadataFromReturnValue = (mockTypeMetadata, mockTypeMetadataData)
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
    repository.fetchTypeMetadataFromReturnValue = (mockTypeMetadata, mockTypeMetadataData)
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

  private let mockVcSdJwt = VcSdJwtPayload.Mock.samplePayload

  private var sriValidator: SRIValidatorProtocolSpy!
  private var repository: OpenIDRepositoryProtocolSpy!
  private var service: TypeMetadataService!

  private let mockTypeMetadata = TypeMetadata.Mock.sampleStandard
  private let mockTypeMetadataData = TypeMetadata.Mock.sampleStandardData
}

// swiftlint:enable all
