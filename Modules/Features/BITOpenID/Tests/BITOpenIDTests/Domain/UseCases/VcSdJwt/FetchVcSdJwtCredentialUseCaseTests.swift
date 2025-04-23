// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITJWT
@testable import BITOca
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore

// MARK: - FetchVcSdJwtCredentialUseCaseTests

final class FetchVcSdJwtCredentialUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    jwsSignatureValidatorMock = JWSSignatureValidatorMock()
    spyRepository = OpenIDRepositoryProtocolSpy()
    jwsEncoderMock = JWSEncoderMock()
    vcSchemaService = VcSchemaServiceProtocolSpy()
    typeMetadataService = TypeMetadataServiceProtocolSpy()
    ocaBundleService = OCABundleServiceProtocolSpy()

    Container.shared.openIDRepository.register { self.spyRepository }
    Container.shared.jwsSignatureValidator.register { self.jwsSignatureValidatorMock }
    Container.shared.jwsEncoder.register { self.jwsEncoderMock }
    Container.shared.vcSchemaService.register { self.vcSchemaService }
    Container.shared.typeMetadataService.register { self.typeMetadataService }
    Container.shared.ocaBundleService.register { self.ocaBundleService }
    Container.shared.isOCABundleFetchFeatureEnabled.register { true }

    useCase = FetchVcSdJwtCredentialUseCase()

    mockFetchCredentialContext = .Mock.sampleVcSdJwt
  }

  func testFetchHappyPath() async throws {
    let mockCredentialResponse = CredentialResponse.Mock.sample
    let mockVcSdJwt = VcSdJwtPayload.Mock.sample

    spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReturnValue = mockCredentialResponse
    jwsSignatureValidatorMock.validateJwsDidReturnValue = true
    jwsEncoderMock.encodeUsingReturnValue = Self.mockJwtData
    vcSchemaService.fetchForReturnValue = mockVcSchema
    vcSchemaService.validateWithReturnValue = true
    typeMetadataService.fetchReturnValue = mockTypeMetadata
    ocaBundleService.fetchVcSdJwtOcaBundleFromReturnValue = mockRawOcaBundle
    useCase = FetchVcSdJwtCredentialUseCase()

    let credential = try await useCase.execute(for: mockFetchCredentialContext)

    if let fetchArguments = spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReceivedArguments {
      XCTAssertEqual(fetchArguments.url, mockFetchCredentialContext.credentialEndpoint)
      XCTAssertEqual(fetchArguments.acccessToken, mockFetchCredentialContext.accessToken)
      XCTAssertEqual(fetchArguments.credentialRequestBody.format, mockFetchCredentialContext.format)
      XCTAssertEqual(fetchArguments.credentialRequestBody.proof?.proofType, "jwt")
      XCTAssertEqual(fetchArguments.credentialRequestBody.proof?.jwt, Self.mockJwtString)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertEqual(credential.ocaBundle, mockRawOcaBundle)
    XCTAssertNotNil(mockTypeMetadata.schemaUrl)
    XCTAssertNotNil(mockTypeMetadata.schemaIntegrity)
    XCTAssertEqual(typeMetadataService.fetchReceivedVc, mockVcSdJwt.payload)

    XCTAssertEqual((jwsSignatureValidatorMock.validateJwsDidReceivedJws as? VcSdJwt)?.raw, mockVcSdJwt.raw)
    XCTAssertEqual(ocaBundleService.fetchVcSdJwtOcaBundleFromReceivedOcaRendering, mockTypeMetadata.displays?.first?.rendering?.oca)

    XCTAssertEqual(vcSchemaService.fetchForReceivedTypeMetadata, mockTypeMetadata)
    XCTAssertEqual(vcSchemaService.validateWithReceivedArguments?.vcSchema, mockVcSchema)
    XCTAssertEqual(vcSchemaService.validateWithReceivedArguments?.vcSdJwt.raw, mockVcSdJwt.raw)
  }

  func testFetchHappyPathWithoutHolderBinding() async throws {
    let mockCredentialResponse = CredentialResponse.Mock.sample
    let context = FetchCredentialContext.Mock.sampleVcSdJwtWithoutHolderBinding
    let mockVcSdJwt = VcSdJwtPayload.Mock.sample

    spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReturnValue = mockCredentialResponse
    jwsSignatureValidatorMock.validateJwsDidReturnValue = true
    vcSchemaService.fetchForReturnValue = mockVcSchema
    vcSchemaService.validateWithReturnValue = true
    typeMetadataService.fetchReturnValue = mockTypeMetadata
    ocaBundleService.fetchVcSdJwtOcaBundleFromReturnValue = mockRawOcaBundle

    _ = try await useCase.execute(for: context)

    if let fetchArguments = spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReceivedArguments {
      XCTAssertEqual(fetchArguments.url, mockFetchCredentialContext.credentialEndpoint)
      XCTAssertEqual(fetchArguments.acccessToken, mockFetchCredentialContext.accessToken)
      XCTAssertEqual(fetchArguments.credentialRequestBody.format, mockFetchCredentialContext.format)
      XCTAssertNil(fetchArguments.credentialRequestBody.proof)
    } else {
      XCTFail("fetchCredential no arguments received")
    }

    XCTAssertEqual((jwsSignatureValidatorMock.validateJwsDidReceivedJws as? VcSdJwt)?.raw, mockVcSdJwt.raw)
    XCTAssertNil(spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReceivedArguments?.credentialRequestBody.proof)
    XCTAssertEqual(typeMetadataService.fetchReceivedVc, mockVcSdJwt.payload)
    XCTAssertEqual(vcSchemaService.fetchForReceivedTypeMetadata, mockTypeMetadata)
    XCTAssertEqual(ocaBundleService.fetchVcSdJwtOcaBundleFromReceivedOcaRendering, mockTypeMetadata.displays?.first?.rendering?.oca)
  }

  func testCredentialValidation_fails() async throws {
    let mockCredentialResponse = CredentialResponse.Mock.sample
    let mockVcSdJwt = VcSdJwtPayload.Mock.sample

    spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReturnValue = mockCredentialResponse
    jwsSignatureValidatorMock.validateJwsDidReturnValue = false
    jwsEncoderMock.encodeUsingReturnValue = Self.mockJwtData
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: mockFetchCredentialContext)
      XCTFail("An error was expected")
    } catch FetchAnyVerifiableCredentialError.validationFailed {
      if let fetchArguments = spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReceivedArguments {
        XCTAssertEqual(fetchArguments.url, mockFetchCredentialContext.credentialEndpoint)
        XCTAssertEqual(fetchArguments.acccessToken, mockFetchCredentialContext.accessToken)
        XCTAssertEqual(fetchArguments.credentialRequestBody.format, mockFetchCredentialContext.format)
        XCTAssertEqual(fetchArguments.credentialRequestBody.proof?.proofType, "jwt")
        XCTAssertEqual(fetchArguments.credentialRequestBody.proof?.jwt, Self.mockJwtString)
      } else {
        XCTFail("fetchCredential no arguments received")
      }

      XCTAssertEqual((jwsSignatureValidatorMock.validateJwsDidReceivedJws as? VcSdJwt)?.raw, mockVcSdJwt.raw)
      XCTAssertEqual(spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReceivedArguments?.credentialRequestBody.proof?.jwt, Self.mockJwtString)
      XCTAssertFalse(typeMetadataService.fetchCalled)
      XCTAssertFalse(vcSchemaService.fetchForCalled)
      XCTAssertFalse(vcSchemaService.validateWithCalled)
    } catch {
      XCTFail("Another error was expected")
    }
  }

  func testCredentialValidation_unknownIssuer() async throws {
    jwsEncoderMock.encodeUsingReturnValue = Self.mockJwtData
    spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReturnValue = CredentialResponse.Mock.sample
    jwsSignatureValidatorMock.validateJwsDidThrowableError = JWSSignatureValidatorError.cannotResolveDid(TestingError.error)
    useCase = FetchVcSdJwtCredentialUseCase()

    do {
      _ = try await useCase.execute(for: mockFetchCredentialContext)
      XCTFail("An error was expected")
    } catch FetchAnyVerifiableCredentialError.unknownIssuer {
      XCTAssertTrue(spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenCalled)
      XCTAssertTrue(jwsSignatureValidatorMock.validateJwsDidReceivedDid != nil)
      XCTAssertFalse(typeMetadataService.fetchCalled)
      XCTAssertFalse(vcSchemaService.fetchForCalled)
      XCTAssertFalse(vcSchemaService.validateWithCalled)
    } catch {
      XCTFail("Another error was expected")
    }
  }

  // MARK: - TypeMetadataService

  func testFetchTypeMetadata_ThrowsError_failure() async throws {
    initSuccessMocks()
    typeMetadataService.fetchThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockFetchCredentialContext)
      XCTFail("An error was expected")
    } catch TestingError.error {
      XCTAssertFalse(vcSchemaService.validateWithCalled)
      XCTAssertFalse(vcSchemaService.fetchForCalled)
    } catch {
      XCTFail("Another error was expected")
    }
  }

  func testFetchTypeMetadata_ReturnsNil_failure() async throws {
    initSuccessMocks()
    typeMetadataService.fetchReturnValue = nil

    _ = try await useCase.execute(for: mockFetchCredentialContext)

    XCTAssertFalse(vcSchemaService.validateWithCalled)
    XCTAssertFalse(vcSchemaService.fetchForCalled)
  }

  func testFetchTypeMetadata_WithoutOca_ReturnsNil() async throws {
    initSuccessMocks()
    typeMetadataService.fetchReturnValue = .Mock.sampleWithoutOca

    let credential = try await useCase.execute(for: mockFetchCredentialContext)

    XCTAssertEqual(credential.ocaBundle, nil)
  }

  // MARK: - VcSchemaService

  func testFetchVcSchema_ThrowsError_failure() async throws {
    initSuccessMocks()
    vcSchemaService.fetchForThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockFetchCredentialContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertFalse(vcSchemaService.validateWithCalled)
    }
  }

  func testFetchVcSchema_ReturnsNil_failure() async throws {
    initSuccessMocks()
    vcSchemaService.fetchForReturnValue = nil

    let credential = try await useCase.execute(for: mockFetchCredentialContext)

    XCTAssertEqual(credential.ocaBundle, nil)
    XCTAssertFalse(vcSchemaService.validateWithCalled)
  }

  func testValidateVcSchema_ReturnsFalse() async throws {
    initSuccessMocks()
    vcSchemaService.validateWithReturnValue = false

    do {
      _ = try await useCase.execute(for: mockFetchCredentialContext)
      XCTFail("An error was expected")
    } catch {
      XCTAssertEqual(error as? FetchAnyVerifiableCredentialError, .invalidVcSchema)
    }
  }

  // MARK: - OCA Bundle service

  func testFetchVcSdJwtOcaBundle_WithOCAFeatureDisable() async throws {
    initSuccessMocks()
    Container.shared.isOCABundleFetchFeatureEnabled.register { false }

    useCase = FetchVcSdJwtCredentialUseCase()

    let credential = try await useCase.execute(for: mockFetchCredentialContext)

    XCTAssertEqual(credential.ocaBundle, nil)
    XCTAssertFalse(ocaBundleService.fetchVcSdJwtOcaBundleFromCalled)
  }

  func testFetchVcSdJwtOcaBundle_ThrowsError() async throws {
    initSuccessMocks()
    ocaBundleService.fetchVcSdJwtOcaBundleFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: mockFetchCredentialContext)
      XCTFail("Expected a TestingError.error instead")
    } catch TestingError.error {
      XCTAssertTrue(vcSchemaService.validateWithCalled)
      XCTAssertTrue(vcSchemaService.fetchForCalled)
    } catch {
      XCTFail("Expected another error")
    }
  }

  func testFetchTypeMetadata_WithoutDisplay_ReturnsNil() async throws {
    initSuccessMocks()
    typeMetadataService.fetchReturnValue = .Mock.sampleWithoutDisplays

    let credential = try await useCase.execute(for: mockFetchCredentialContext)

    XCTAssertEqual(credential.ocaBundle, nil)
    XCTAssertFalse(ocaBundleService.fetchVcSdJwtOcaBundleFromCalled)
  }

  // MARK: Private

  private static let mockJwtString = "mockJwt"
  private static let mockJwtData = mockJwtString.data(using: .utf8)!

  private var useCase: FetchVcSdJwtCredentialUseCase!
  private var jwsSignatureValidatorMock: JWSSignatureValidatorMock!
  private var jwsEncoderMock: JWSEncoderMock<VcSdJwtPayload>!
  private var spyRepository: OpenIDRepositoryProtocolSpy!
  private var mockFetchCredentialContext: FetchCredentialContext!
  private var vcSchemaService: VcSchemaServiceProtocolSpy!
  private var typeMetadataService: TypeMetadataServiceProtocolSpy!
  private var ocaBundleService: OCABundleServiceProtocolSpy!

  private let mockRawOcaBundle = RawOcaBundle()
  private let mockVcSchema = VcSchema()
  private let mockTypeMetadata = TypeMetadata.Mock.sampleUrlOca

  private func initSuccessMocks() {
    let mockCredentialResponse = CredentialResponse.Mock.sample

    spyRepository.fetchCredentialFromCredentialRequestBodyAcccessTokenReturnValue = mockCredentialResponse
    jwsEncoderMock.encodeUsingReturnValue = Self.mockJwtData
    jwsSignatureValidatorMock.validateJwsDidReturnValue = true
    typeMetadataService.fetchReturnValue = mockTypeMetadata
    vcSchemaService.fetchForReturnValue = mockVcSchema
    vcSchemaService.validateWithReturnValue = true
    useCase = FetchVcSdJwtCredentialUseCase()
  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping
