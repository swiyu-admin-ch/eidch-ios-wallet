import Factory
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class FetchIssuanceTrustInformationUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    useCase = FetchIssuanceTrustInformationUseCase()
    createSuccess()
  }

  func testUseCase_success_returnsTrustInformation() async throws {
    let result = try await useCase(for: mockCredential)

    XCTAssertEqual(result, mockTrustInformation)
  }

  func testUseCase_success_assertParametersAndCount() async throws {
    _ = try await useCase(for: mockCredential)
    let selectedBundleItem = try selectCredentialBundleItemUseCaseSpy(mockCredential)

    XCTAssertEqual(createAnyCredentialUseCase.executeFromFormatCallsCount, 1)
    XCTAssertEqual(createAnyCredentialUseCase.executeFromFormatReceivedArguments?.payload, selectedBundleItem.payload)
    XCTAssertEqual(createAnyCredentialUseCase.executeFromFormatReceivedArguments?.format, mockCredential.format)

    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdCallsCount, 1)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.subjectDid, mockAnyCredential.issuer)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.type, .issuance)
    XCTAssertEqual(trustInformationService.fetchForTypeVcSchemaIdReceivedArguments?.vcSchemaId, mockAnyCredential.vcSchemaId)
  }

  func testUseCase_createAnyCredentialFails_throwsError() async throws {
    createAnyCredentialUseCase.executeFromFormatThrowableError = TestingError.error

    do {
      _ = try await useCase(for: mockCredential)
      XCTFail("Expected exception")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockCredential = VerifiableCredential.Mock.sample
  private let mockAnyCredential = MockAnyCredential()
  private let mockTrustInformation = TrustInformation.Mock.fullyTrusted

  private var useCase: FetchIssuanceTrustInformationUseCase!
  private var trustInformationService: TrustInformationServiceProtocolSpy!
  private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocolSpy!
  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private func registerMocks() {
    trustInformationService = TrustInformationServiceProtocolSpy()
    createAnyCredentialUseCase = CreateAnyCredentialUseCaseProtocolSpy()

    Container.shared.trustInformationService.register { self.trustInformationService }
    Container.shared.createAnyCredentialUseCase.register { self.createAnyCredentialUseCase }

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      guard let first = $0.bundleItems.first else { throw CredentialError.noBundleItem }
      return first
    }
  }

  private func createSuccess() {
    createAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential
    trustInformationService.fetchForTypeVcSchemaIdReturnValue = mockTrustInformation
  }

}
