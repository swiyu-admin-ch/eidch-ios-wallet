// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITCrypto
@testable import BITOca
@testable import BITTestingCore

final class OCABundleServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    sriValidator = SRIValidatorProtocolSpy()
    ocaRepository = OCARepositoryProtocolSpy()

    Container.shared.sriValidator.register { self.sriValidator }
    Container.shared.ocaRepository.register { self.ocaRepository }

    service = OCABundleService()
  }

  func testFetchUrlOCABundle_success() async throws {
    ocaRepository.fetchOCABundleFromReturnValue = mockRawOcaBundle
    sriValidator.validateWithReturnValue = true

    let rawOcaBundle = try await service.fetchVcSdJwtOcaBundle(from: mockUriOca)

    XCTAssertEqual(rawOcaBundle, mockRawOcaBundle)
    XCTAssertEqual(ocaRepository.fetchOCABundleFromReceivedUrl, URL(string: mockUriOca.uri))
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.data, mockRawOcaBundle)
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.integrity, mockUriOca.uriIntegrity)
  }

  func testFetchDataOCABundle_success() async throws {
    sriValidator.validateWithReturnValue = true

    let rawOcaBundle = try await service.fetchVcSdJwtOcaBundle(from: mockDataOca)

    XCTAssertEqual(rawOcaBundle, try Data(base64Encoded: String(XCTUnwrap(mockDataOca.uri.split(separator: ",").last))))
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.data, mockDataOca.uri.data(using: .utf8))
    XCTAssertEqual(sriValidator.validateWithReceivedArguments?.integrity, mockDataOca.uriIntegrity)
  }

  func testFetchOCABundle_WithInvalidOcaUrlScheme_ThrowsError() async throws {
    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: .Mock.sampleWithInvalidScheme)
      XCTFail("Expected an error")
    } catch OCABundleServiceError.invalidOCAUrl {
      XCTAssertFalse(sriValidator.validateWithCalled)
      XCTAssertFalse(ocaRepository.fetchOCABundleFromCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  // MARK: - OCA URL

  func testFetchOCABundle_UrlSchemeWithoutUrlIntegrity_ThrowsError() async throws {
    let mockOca = VcSdJwtOcaRendering.Mock.sampleUriWithoutIntegrity
    ocaRepository.fetchOCABundleFromReturnValue = mockRawOcaBundle
    sriValidator.validateWithReturnValue = true

    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: mockOca)
      XCTFail("Expected an error")
    } catch OCABundleServiceError.invalidOCABundle {
      XCTAssertFalse(sriValidator.validateWithCalled)
      XCTAssertFalse(ocaRepository.fetchOCABundleFromCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  func testFetchOCABundle_UrlSchemeRepositoryError_ThrowsError() async throws {
    ocaRepository.fetchOCABundleFromThrowableError = TestingError.error

    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: mockUriOca)
      XCTFail("Expected an error")
    } catch TestingError.error {
      XCTAssertFalse(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  func testFetchOCABundle_UrlSchemeValidationFails_ThrowsError() async throws {
    ocaRepository.fetchOCABundleFromReturnValue = mockRawOcaBundle
    sriValidator.validateWithReturnValue = false

    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: mockUriOca)
      XCTFail("Expected an error")
    } catch OCABundleServiceError.invalidOCABundle {
      XCTAssertTrue(sriValidator.validateWithCalled)
      XCTAssertTrue(ocaRepository.fetchOCABundleFromCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  func testFetchOCABundle_UrlSchemeValidationError_ThrowsError() async throws {
    ocaRepository.fetchOCABundleFromReturnValue = mockRawOcaBundle
    sriValidator.validateWithThrowableError = TestingError.error

    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: mockUriOca)
      XCTFail("Expected an error")
    } catch TestingError.error {
      XCTAssertTrue(sriValidator.validateWithCalled)
      XCTAssertTrue(ocaRepository.fetchOCABundleFromCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  // MARK: - OCA Data

  func testFetchOCABundle_DataSchemeInvalidFormat_ThrowsError() async throws {
    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: .Mock.sampleDataWithInvalidFormat)
      XCTFail("Expected an error")
    } catch OCABundleServiceError.invalidOCABundle {
      XCTAssertFalse(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  func testFetchOCABundle_DataSchemeValidationFails_ThrowsError() async throws {
    sriValidator.validateWithReturnValue = false

    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: mockDataOca)
      XCTFail("Expected an error")
    } catch OCABundleServiceError.invalidOCABundle {
      XCTAssertTrue(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  func testFetchOCABundle_DataSchemeValidationError_ThrowsError() async throws {
    sriValidator.validateWithThrowableError = TestingError.error

    do {
      _ = try await service.fetchVcSdJwtOcaBundle(from: mockDataOca)
      XCTFail("Expected an error")
    } catch TestingError.error {
      XCTAssertTrue(sriValidator.validateWithCalled)
    } catch {
      XCTFail("Unexpected an error")
    }
  }

  // MARK: Private

  private var service: OCABundleService!
  private var sriValidator: SRIValidatorProtocolSpy!
  private var ocaRepository: OCARepositoryProtocolSpy!

  private let mockRawOcaBundle = RawOcaBundle()
  private let mockDataOca = VcSdJwtOcaRendering.Mock.sampleData
  private let mockUriOca = VcSdJwtOcaRendering.Mock.sampleUri

}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
