// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITOca
@testable import BITOpenID
@testable import BITTestingCore

final class FetchVcMetadataUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    useCase = FetchVcMetadataUseCase()
  }

  func testExecute_vcSdJwt_returnsOcaBundle() async throws {
    success(format: .vcSdJwt)

    let ocaBundle = try await useCase.execute(for: anyCredentialSpy)

    XCTAssertNotNil(ocaBundle)
  }

  func testExecute_vcSdJwt_argumentsPassed() async throws {
    success(format: .vcSdJwt)

    _ = try await useCase.execute(for: anyCredentialSpy)

    XCTAssertEqual(fetchVcMetadataForVcSdJwtUseCaseSpy.executeForReceivedAnyCredential?.raw, anyCredentialSpy.raw)
    XCTAssertEqual(jsonSchemaValidatorSpy.validateDictionaryWithReceivedArguments?.dictionary.keys.count, 1)
    XCTAssertEqual(jsonSchemaValidatorSpy.validateDictionaryWithReceivedArguments?.dictionary.keys.first, keyMock)
    XCTAssertEqual(jsonSchemaValidatorSpy.validateDictionaryWithReceivedArguments?.jsonSchema, vcSdJwtJsonSchemaMock)
  }

  func testExecute_vcSdJwtNilVcSchemaAndNilOca_returnsNil() async throws {
    success(format: .vcSdJwt)
    fetchVcMetadataForVcSdJwtUseCaseSpy.executeForReturnValue = (nil, nil)

    let ocaBundle = try await useCase.execute(for: anyCredentialSpy)

    XCTAssertNil(ocaBundle)
  }

  func testExecute_vcSdJwtNilVcSchema_returnsOcaBundle() async throws {
    success(format: .vcSdJwt)
    fetchVcMetadataForVcSdJwtUseCaseSpy.executeForReturnValue = (nil, vcSdJwtOcaBundleMock)

    let ocaBundle = try await useCase.execute(for: anyCredentialSpy)

    XCTAssertNotNil(ocaBundle)
    XCTAssertFalse(jsonSchemaValidatorSpy.validateDictionaryWithCalled)
  }

  func testExecute_vcSdJwtFailure_throwsError() async throws {
    success(format: .vcSdJwt)
    fetchVcMetadataForVcSdJwtUseCaseSpy.executeForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: anyCredentialSpy)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_jsonSchemaInvalid_throwsError() async throws {
    success(format: .vcSdJwt)
    jsonSchemaValidatorSpy.validateDictionaryWithReturnValue = false

    do {
      _ = try await useCase.execute(for: anyCredentialSpy)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchAnyVerifiableCredentialError, .invalidVcSchema)
    }
  }

  func testExecute_jsonSchemaValidatorFailure_throwsError() async throws {
    success(format: .vcSdJwt)
    jsonSchemaValidatorSpy.validateDictionaryWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: anyCredentialSpy)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_unsupportedFormat_throwsError() async throws {
    anyCredentialSpy.format = "invalid"

    do {
      _ = try await useCase.execute(for: anyCredentialSpy)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? CredentialFormatError, .formatNotSupported)
    }
  }

  // MARK: Private

  private var useCase = FetchVcMetadataUseCase()
  private var anyCredentialSpy = AnyCredentialSpy()
  private var fetchVcMetadataForVcSdJwtUseCaseSpy = FetchVcMetadataForAnyCredentialUseCaseProtocolSpy()
  private var jsonSchemaValidatorSpy = JsonSchemaValidatorProtocolSpy()
  private var dispatcherMock: [CredentialFormat: FetchVcMetadataForAnyCredentialUseCaseProtocolSpy]!
  private let vcSdJwtOcaBundleMock = "vcSdJwtOcaBundle".data(using: .utf8)!
  private let vcSdJwtJsonSchemaMock = "vcSdJwtJsonSchema".data(using: .utf8)!
  private let keyMock = "testKey"

  private func registerMocks() {
    anyCredentialSpy = AnyCredentialSpy()
    fetchVcMetadataForVcSdJwtUseCaseSpy = FetchVcMetadataForAnyCredentialUseCaseProtocolSpy()
    jsonSchemaValidatorSpy = JsonSchemaValidatorProtocolSpy()
    dispatcherMock = [.vcSdJwt: fetchVcMetadataForVcSdJwtUseCaseSpy]

    Container.shared.fetchVcMetadataForAnyCredentialDispatcher.register { self.dispatcherMock }
    Container.shared.jsonSchemaValidator.register { self.jsonSchemaValidatorSpy }
  }

  private func success(format: CredentialFormat) {
    switch format {
    case .vcSdJwt:
      anyCredentialSpy.format = CredentialFormat.vcSdJwt.rawValue
      anyCredentialSpy.raw = "vcSdJwtPayload"
      anyCredentialSpy.getClaimsDictionaryReturnValue = [keyMock: "testValue"]
      fetchVcMetadataForVcSdJwtUseCaseSpy.executeForReturnValue = (vcSdJwtJsonSchemaMock, vcSdJwtOcaBundleMock)
      jsonSchemaValidatorSpy.validateDictionaryWithReturnValue = true
    }
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
