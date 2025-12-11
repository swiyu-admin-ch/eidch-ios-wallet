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

    XCTAssertEqual(credentials.first?.requestedFields, mockMatchingFields)

    XCTAssertTrue(credentialRepository.getAllVerifiableCredentialsCalled)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[0].format, mockCredentials[0].format)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[0].payload, mockCredentials[0].payload)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[1].format, mockCredentials[2].format)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[1].payload, mockCredentials[2].payload)
    XCTAssertEqual(fieldValidatorSpy.validateWithReceivedArguments?.anyCredential.raw, mockAnyCredential.raw)
    let inputDescriptor = requestObject.presentationDefinition.inputDescriptors.first
    XCTAssertEqual(fieldValidatorSpy.validateWithReceivedArguments?.requestedFields, inputDescriptor?.constraints.fields)
  }

  func testExecute_NoMatchingFormat_ThrowsNoCompatibleCredentials() async throws {
    credentialRepository.getAllVerifiableCredentialsReturnValue = [.Mock.diploma]

    do {
      _ = try await useCase.execute(using: .Mock.VcSdJwt.sample)
      XCTFail("Should have thrown an exception")
    } catch CompatibleCredentialsError.compatibleCredentialNotFound {
      XCTAssertTrue(credentialRepository.getAllVerifiableCredentialsCalled)
      XCTAssertFalse(createAnyCredentialUseCaseSpy.executeFromFormatCalled)
      XCTAssertFalse(fieldValidatorSpy.validateWithCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testExecute_NoMatchingFields_ThrowsNoCompatibleCredentials() async throws {
    fieldValidatorSpy.validateWithReturnValue = []

    do {
      _ = try await useCase.execute(using: .Mock.VcSdJwt.sample)
      XCTFail("Should have thrown an exception")
    } catch CompatibleCredentialsError.compatibleCredentialNotFound {
      XCTAssertTrue(fieldValidatorSpy.validateWithCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testExecute_CreateAnyCredentialThrows_ThrowsNoCompatibleCredentials() async throws {
    createAnyCredentialUseCaseSpy.executeFromFormatThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(using: .Mock.VcSdJwt.sample)
      XCTFail("Should have thrown an exception")
    } catch CompatibleCredentialsError.compatibleCredentialNotFound {
      XCTAssertTrue(createAnyCredentialUseCaseSpy.executeFromFormatCalled)
      XCTAssertFalse(fieldValidatorSpy.validateWithCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testExecute_AnyPresentationFieldsValidatorThrows_ThrowsNoCompatibleCredentials() async throws {
    fieldValidatorSpy.validateWithThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(using: .Mock.VcSdJwt.sample)
      XCTFail("Should have thrown an exception")
    } catch CompatibleCredentialsError.compatibleCredentialNotFound {
      XCTAssertTrue(fieldValidatorSpy.validateWithCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testExecute_emptyWallet() async throws {
    credentialRepository.getAllVerifiableCredentialsReturnValue = []
    do {
      _ = try await useCase.execute(using: .Mock.VcSdJwt.sample)
      XCTFail("Should have thrown an exception")
    } catch CompatibleCredentialsError.emptyWallet {
      XCTAssertTrue(credentialRepository.getAllVerifiableCredentialsCalled)
      XCTAssertFalse(createAnyCredentialUseCaseSpy.executeFromFormatCalled)
      XCTAssertFalse(fieldValidatorSpy.validateWithCalled)
    } catch {
      XCTFail("Not the error expected")
    }
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

  private var useCase = GetCompatibleCredentialsUseCase()

  private func setUpMocks() {
    mockMatchingFields = [firstNameField, lastNameField]

    credentialRepository = CredentialRepositoryProcotolSpy()
    createAnyCredentialUseCaseSpy = CreateAnyCredentialUseCaseProtocolSpy()
    fieldValidatorSpy = PresentationFieldsValidatorProtocolSpy()

    Container.shared.credentialRepository.register { self.credentialRepository }
    Container.shared.createAnyCredentialUseCase.register { self.createAnyCredentialUseCaseSpy }
    Container.shared.presentationFieldsValidator.register { self.fieldValidatorSpy }
  }

  private func success() {
    credentialRepository.getAllVerifiableCredentialsReturnValue = mockCredentials
    createAnyCredentialUseCaseSpy.executeFromFormatReturnValue = mockAnyCredential
    fieldValidatorSpy.validateWithReturnValue = mockMatchingFields
  }

}
