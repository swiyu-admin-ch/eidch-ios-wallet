// swiftlint:disable force_unwrapping
import Factory
import Spyable
import XCTest
@testable import BITAnyCredentialFormat
@testable import BITAnyCredentialFormatMocks
@testable import BITCore
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - GetCompatibleCredentialsUseCaseTests

final class GetCompatibleCredentialsUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setUpMocks()

    useCase = GetCompatibleCredentialsUseCase()

    success()
  }

  func testExecute_TwoMatchingCredentials_ReturnsCompatibleCredentials() async throws {
    let requestObject = RequestObject.Mock.VcSdJwt.sample

    let credentials = try await useCase.execute(using: requestObject)

    XCTAssertEqual(credentials.count, 2)
    XCTAssertEqual(credentials[0].credential, mockCredentials[0])
    XCTAssertEqual(credentials[1].credential, mockCredentials[2])
    XCTAssertTrue(credentials.allSatisfy({ $0.credential.progressionState == .accepted }))

    XCTAssertEqual(credentials.first?.requestedFields, mockMatchingFields)

    XCTAssertTrue(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[0].format, mockCredentials[0].format)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[0].payload, (try? selectCredentialBundleItemUseCaseSpy(mockCredentials[0]))?.payload)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[1].format, mockCredentials[2].format)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[1].payload, (try? selectCredentialBundleItemUseCaseSpy(mockCredentials[2]))?.payload)
    XCTAssertEqual(fieldValidatorSpy.validateWithReceivedArguments?.anyCredential.raw, mockAnyCredential.raw)
    guard let inputDescriptor = requestObject.presentationDefinition?.inputDescriptors.first else {
      XCTFail("Missing input descriptor fixture")
      return
    }
    XCTAssertEqual(fieldValidatorSpy.validateWithReceivedArguments?.requestedFields, inputDescriptor.constraints.fields)
  }

  func testExecute_DcqlPreferredOverDif_UsesDcqlMatcher() async throws {
    let requestObject = RequestObject.Mock.VcSdJwt.sampleWithDcqlQuery
    dcqlCredentialMatcherSpy.matchCredentialsWithReturnValue = [CompatibleCredential(credential: mockCredentials[0], requestedFields: mockMatchingFields)]

    let credentials = try await useCase.execute(using: requestObject)

    XCTAssertFalse(credentials.isEmpty)
    XCTAssertFalse(fieldValidatorSpy.validateWithCalled)
    XCTAssertTrue(dcqlCredentialMatcherSpy.matchCredentialsWithCalled)
  }

  func testExecute_NoMatchingFormat_returnsEmptyCredentialsList() async throws {
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = [.Mock.diploma]

    let credentials = try await useCase.execute(using: .Mock.VcSdJwt.sample)

    XCTAssertTrue(credentials.isEmpty)
    XCTAssertTrue(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    XCTAssertFalse(createAnyCredentialUseCaseSpy.executeFromFormatCalled)
    XCTAssertFalse(fieldValidatorSpy.validateWithCalled)
  }

  func testExecute_NoMatchingFields_returnsEmptyCredentialsList() async throws {
    fieldValidatorSpy.validateWithReturnValue = []

    let credentials = try await useCase.execute(using: .Mock.VcSdJwt.sample)

    XCTAssertTrue(credentials.isEmpty)
    XCTAssertTrue(fieldValidatorSpy.validateWithCalled)
  }

  func testExecute_CreateAnyCredentialThrows_returnsEmptyCredentialsList() async throws {
    createAnyCredentialUseCaseSpy.executeFromFormatThrowableError = TestingError.error

    let credentials = try await useCase.execute(using: .Mock.VcSdJwt.sample)

    XCTAssertTrue(credentials.isEmpty)
    XCTAssertTrue(createAnyCredentialUseCaseSpy.executeFromFormatCalled)
    XCTAssertFalse(fieldValidatorSpy.validateWithCalled)
  }

  func testExecute_AnyPresentationFieldsValidatorThrows_returnsEmptyCredentialsList() async throws {
    fieldValidatorSpy.validateWithThrowableError = TestingError.error

    let credentials = try await useCase.execute(using: .Mock.VcSdJwt.sample)

    XCTAssertTrue(credentials.isEmpty)
    XCTAssertTrue(fieldValidatorSpy.validateWithCalled)
  }

  func testExecute_emptyWallet() async throws {
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = []

    let credentials = try await useCase.execute(using: .Mock.VcSdJwt.sample)

    XCTAssertTrue(credentials.isEmpty)
    XCTAssertTrue(credentialRepository.getAllAcceptedVerifiableCredentialsCalled)
    XCTAssertFalse(createAnyCredentialUseCaseSpy.executeFromFormatCalled)
    XCTAssertFalse(fieldValidatorSpy.validateWithCalled)
  }

  // MARK: Private

  private let mockInputDescriptorId = "3fa85f64-5717-4562-b3fc-2c963f66afa6"
  private let mockCredentials: [VerifiableCredential] = [.Mock.sample, .Mock.diploma, .Mock.sample]
  private let mockAnyCredential = MockAnyCredential()
  private let firstNameField = PresentationField(jsonPath: "$.firstName", value: .string("Fritz"))
  private let lastNameField = PresentationField(jsonPath: "$.lastName", value: .string("Test"))
  private var mockMatchingFields = [PresentationField]()

  private var credentialRepository = CredentialRepositoryProcotolSpy()
  private var createAnyCredentialUseCaseSpy = CreateAnyCredentialUseCaseProtocolSpy()
  private var fieldValidatorSpy = PresentationFieldsValidatorProtocolSpy()
  private var dcqlCredentialMatcherSpy = DcqlCredentialMatcherProtocolSpy()
  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var useCase = GetCompatibleCredentialsUseCase()

  private func setUpMocks() {
    mockMatchingFields = [firstNameField, lastNameField]

    credentialRepository = CredentialRepositoryProcotolSpy()
    createAnyCredentialUseCaseSpy = CreateAnyCredentialUseCaseProtocolSpy()
    fieldValidatorSpy = PresentationFieldsValidatorProtocolSpy()
    dcqlCredentialMatcherSpy = DcqlCredentialMatcherProtocolSpy()

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }

    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.createAnyCredentialUseCase.register { self.createAnyCredentialUseCaseSpy }
    Container.shared.presentationFieldsValidator.register { self.fieldValidatorSpy }
    Container.shared.dcqlCredentialMatcher.register { self.dcqlCredentialMatcherSpy }
  }

  private func success() {
    credentialRepository.getAllAcceptedVerifiableCredentialsReturnValue = mockCredentials
    createAnyCredentialUseCaseSpy.executeFromFormatReturnValue = mockAnyCredential
    fieldValidatorSpy.validateWithReturnValue = mockMatchingFields
  }

}
