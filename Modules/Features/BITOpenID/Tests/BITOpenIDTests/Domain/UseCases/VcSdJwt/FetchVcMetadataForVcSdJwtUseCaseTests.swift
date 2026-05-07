// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITJWT
@testable import BITOca
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - FetchVcMetadataForVcSdJwtUseCaseTests

final class FetchVcMetadataForVcSdJwtUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    useCase = FetchVcMetadataForVcSdJwtUseCase()
    success()
  }

  func testExecute_vcSdJwt_returnsVcSchemaAndOcaBundle() async throws {
    let (vcSchema, ocaBundle) = try await useCase.execute(anyCredential: vcSdJWSMock)

    XCTAssertEqual(vcSchema, vcSchemaMock)
    XCTAssertEqual(ocaBundle, ocaBundleMock)
  }

  func testExecute_vcSdJwt_argumentsPassed() async throws {
    _ = try await useCase.execute(anyCredential: vcSdJWSMock)

    XCTAssertEqual(typeMetadataServiceSpy.fetchFromVctReceivedArguments?.vct, vcSdJWSMock.payload.vct)
    XCTAssertEqual(typeMetadataServiceSpy.fetchFromVctReceivedArguments?.uri.url.absoluteString, vcSdJWSMock.payload.vct)
    XCTAssertEqual(typeMetadataServiceSpy.fetchFromVctReceivedArguments?.uri.integrity, vcSdJWSMock.payload.vctIntegrity)
    XCTAssertEqual(vcSchemaServiceSpy.fetchForReceivedTypeMetadata, typeMetadataMock)
    XCTAssertEqual(ocaBundleServiceSpy.fetchVcSdJwtOcaBundleFromReceivedOcaRendering, ocaRenderingMock)
  }

  func testExecute_vcSdJwtMetadata_returnsVcSchemaAndOcaBundle() async throws {
    let (vcSchema, ocaBundle) = try await useCase.execute(metadata: vcSdJwtMetadataMock)

    XCTAssertEqual(vcSchema, vcSchemaMock)
    XCTAssertEqual(ocaBundle, ocaBundleMock)
  }

  func testExecute_vcSdJwtMetadata_argumentsPassed() async throws {
    _ = try await useCase.execute(metadata: vcSdJwtMetadataMock)

    XCTAssertEqual(typeMetadataServiceSpy.fetchFromVctReceivedArguments?.vct, Self.vctMock)
    XCTAssertEqual(typeMetadataServiceSpy.fetchFromVctReceivedArguments?.uri.url.absoluteString, Self.vctMock)
    XCTAssertEqual(typeMetadataServiceSpy.fetchFromVctReceivedArguments?.uri.integrity, Self.vctIntegrityMock)
    XCTAssertEqual(vcSchemaServiceSpy.fetchForReceivedTypeMetadata, typeMetadataMock)
    XCTAssertEqual(ocaBundleServiceSpy.fetchVcSdJwtOcaBundleFromReceivedOcaRendering, ocaRenderingMock)
  }

  func testExecute_notVcSdJwt_throwsError() async throws {
    do {
      _ = try await useCase.execute(anyCredential: MockAnyCredential())
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? CredentialFormatError, .formatNotSupported)
    }
  }

  func testExecute_notVcSdJwtMetadata_throwsError() async throws {
    do {
      _ = try await useCase.execute(metadata: MockAnyCredentialConfigurationSupported())
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? CredentialFormatError, .formatNotSupported)
    }
  }

  func testExecute_vcSchemaFetchReturnsNil_returnsNilVcSchemaAndOcaBundle() async throws {
    vcSchemaServiceSpy.fetchForReturnValue = nil

    let (vcSchema, ocaBundle) = try await useCase.execute(anyCredential: vcSdJWSMock)

    XCTAssertNil(vcSchema)
    XCTAssertEqual(ocaBundle, ocaBundleMock)
  }

  func testExecute_typeMetadataFailure_throwsError() async throws {
    typeMetadataServiceSpy.fetchFromVctThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(anyCredential: vcSdJWSMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_typeMetadataIsNil_returnsNilVcSchemaAndNilOcaBundle() async throws {
    typeMetadataServiceSpy.fetchFromVctReturnValue = nil

    let (vcSchema, ocaBundle) = try await useCase.execute(anyCredential: vcSdJWSMock)

    XCTAssertNil(vcSchema)
    XCTAssertNil(ocaBundle)
  }

  func testExecute_vcSchemaFetchFailure_throwsError() async throws {
    vcSchemaServiceSpy.fetchForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(anyCredential: vcSdJWSMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_fetchOcaBundleFailure_throwsError() async throws {
    ocaBundleServiceSpy.fetchVcSdJwtOcaBundleFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(anyCredential: vcSdJWSMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_vcSchemaValidationThrows_throwsError() async throws {
    vcSdJwtSchemaValidatorSpy.validateSchemaThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(anyCredential: vcSdJWSMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testExecute_vcSchemaValidationFails_throwsError() async throws {
    vcSdJwtSchemaValidatorSpy.validateSchemaReturnValue = false

    do {
      _ = try await useCase.execute(anyCredential: vcSdJWSMock)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchAnyVerifiableCredentialError, .invalidVcSchema)
    }
  }

  // MARK: Private

  private static let vctMock = "https://vct.example.com"
  private static let vctIntegrityMock = "vctIntegrity"

  private let vcSdJWSMock = VcSdJWS.Mock.sample
  private let vcSdJwtMetadataMock = CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported(format: "format", vct: vctMock, vctIntegrity: vctIntegrityMock)
  private let ocaBundleMock = "rawOcaBundle".data(using: .utf8)!
  private let vcSchemaMock = "vcSchema".data(using: .utf8)!
  private let typeMetadataMock = TypeMetadata.Mock.sampleMultipleDisplays
  private let ocaRenderingMock = VcSdJwtOcaRendering(uri: "ocaUri", uriIntegrity: "ocaUriIntegrity")

  private var vcSchemaServiceSpy = VcSchemaServiceProtocolSpy()
  private var vcSdJwtSchemaValidatorSpy = VcSdJwtSchemaValidatorProtocolSpy()
  private var typeMetadataServiceSpy = TypeMetadataServiceProtocolSpy()
  private var ocaBundleServiceSpy = OCABundleServiceProtocolSpy()

  private var useCase = FetchVcMetadataForVcSdJwtUseCase()

  private func registerMocks() {
    vcSchemaServiceSpy = VcSchemaServiceProtocolSpy()
    vcSdJwtSchemaValidatorSpy = VcSdJwtSchemaValidatorProtocolSpy()
    typeMetadataServiceSpy = TypeMetadataServiceProtocolSpy()
    ocaBundleServiceSpy = OCABundleServiceProtocolSpy()

    Container.shared.vcSchemaService.register { self.vcSchemaServiceSpy }
    Container.shared.vcSdJwtSchemaValidator.register { self.vcSdJwtSchemaValidatorSpy }
    Container.shared.typeMetadataService.register { self.typeMetadataServiceSpy }
    Container.shared.ocaBundleService.register { self.ocaBundleServiceSpy }
  }

  private func success() {
    vcSchemaServiceSpy.fetchForReturnValue = vcSchemaMock
    vcSdJwtSchemaValidatorSpy.validateSchemaReturnValue = true
    typeMetadataServiceSpy.fetchFromVctReturnValue = typeMetadataMock
    ocaBundleServiceSpy.fetchVcSdJwtOcaBundleFromReturnValue = ocaBundleMock
  }
}
