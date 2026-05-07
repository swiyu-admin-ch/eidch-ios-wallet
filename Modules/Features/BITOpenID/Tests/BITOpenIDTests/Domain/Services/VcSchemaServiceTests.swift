// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITCrypto
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

final class VcSchemaServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = OpenIDRepositoryProtocolSpy()
    sriValidator = SRIValidatorProtocolSpy()

    Container.shared.openIDRepository.register { self.repository }
    Container.shared.sriValidator.register { self.sriValidator }

    service = VcSchemaService()
  }

  func testFetchVcSchema_success() async throws {
    sriValidator.validateWithReturnValue = true
    repository.fetchVcSchemaDataFromReturnValue = mockVcSchemaData

    let vcSchema = try await service.fetch(for: mockTypeMetadata)

    XCTAssertNotNil(vcSchema)
    XCTAssertEqual(repository.fetchVcSchemaDataFromReceivedUrl, mockTypeMetadata.schemaUrl)
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.data, mockVcSchemaData)
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.integrity, mockTypeMetadata.schemaIntegrity)
  }

  func testFetchVcSchema_withoutSchemaUrl_failure() async throws {
    let vcSchema = try await service.fetch(for: .Mock.sampleWithoutSchemaUrl)

    XCTAssertNil(vcSchema)
    XCTAssertFalse(repository.fetchVcSchemaDataFromCalled)
    XCTAssertFalse(sriValidator.validateWithCalled)
  }

  func testFetchVcSchema_repositoryError_failure() async throws {
    repository.fetchVcSchemaDataFromThrowableError = TestingError.error

    do {
      _ = try await service.fetch(for: mockTypeMetadata)
      XCTFail("Expected an error")
    } catch TestingError.error {
      XCTAssertFalse(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testFetchVcSchema_withoutUrlIntegrity_failure() async throws {
    let mockTypeMetadata: TypeMetadata = .Mock.sampleWithoutUrlIntegrity
    repository.fetchVcSchemaDataFromReturnValue = mockVcSchemaData

    _ = try await service.fetch(for: mockTypeMetadata)

    XCTAssertNotNil(mockTypeMetadata.schemaUrl)
    XCTAssertEqual(repository.fetchVcSchemaDataFromReceivedUrl, mockTypeMetadata.schemaUrl)
    XCTAssertFalse(sriValidator.validateWithCalled)
  }

  func testFetchVcSchema_sriValidationError_failure() async throws {
    sriValidator.validateWithThrowableError = TestingError.error
    repository.fetchVcSchemaDataFromReturnValue = mockVcSchemaData

    do {
      _ = try await service.fetch(for: mockTypeMetadata)
      XCTFail("Expected an error")
    } catch TestingError.error {
      XCTAssertEqual(repository.fetchVcSchemaDataFromReceivedUrl, mockTypeMetadata.schemaUrl)
      XCTAssertTrue(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  func testFetchVcSchema_sriValidationReturnsFalse_failure() async throws {
    sriValidator.validateWithReturnValue = false
    repository.fetchVcSchemaDataFromReturnValue = mockVcSchemaData

    do {
      _ = try await service.fetch(for: mockTypeMetadata)
      XCTFail("Expected an error")
    } catch VcSchemaServiceError.invalidVcSchema {
      XCTAssertEqual(repository.fetchVcSchemaDataFromReceivedUrl, mockTypeMetadata.schemaUrl)
      XCTAssertTrue(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Unexpected error")
    }
  }

  // MARK: Private

  private var sriValidator: SRIValidatorProtocolSpy!
  private var repository: OpenIDRepositoryProtocolSpy!
  private var service: VcSchemaService!
  private var mockPayload = "mockPayload".data(using: .utf8)!

  private let mockVcSchemaData = VcSchema()
  private let mockTypeMetadata = TypeMetadata.Mock.sampleStandard
  private let mockTypeMetadataData = TypeMetadata.Mock.sampleStandardData
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
