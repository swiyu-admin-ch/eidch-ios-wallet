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

    let credentialsMap = try await useCase.execute(using: requestObject)

    XCTAssertEqual(credentialsMap.count, 1)
    XCTAssertEqual(credentialsMap.first?.key, mockInputDescriptorId)

    let compatibleCredentials = credentialsMap.first?.value
    XCTAssertEqual(compatibleCredentials?.count, 2)
    XCTAssertEqual(compatibleCredentials?[0].credential, mockCredentials[0])
    XCTAssertEqual(compatibleCredentials?[1].credential, mockCredentials[2])

    XCTAssertEqual(compatibleCredentials?.first?.requestedFields, mockMatchingFields)

    XCTAssertTrue(verifiableCredentialRepository.getAllCalled)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[0].format, mockCredentials[0].format)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[0].payload, mockCredentials[0].payload)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[1].format, mockCredentials[2].format)
    XCTAssertEqual(createAnyCredentialUseCaseSpy.executeFromFormatReceivedInvocations[1].payload, mockCredentials[2].payload)
    XCTAssertEqual(fieldValidatorSpy.validateWithReceivedArguments?.anyCredential.raw, mockAnyCredential.raw)
    let inputDescriptor = requestObject.presentationDefinition.inputDescriptors.first
    XCTAssertEqual(fieldValidatorSpy.validateWithReceivedArguments?.requestedFields, inputDescriptor?.constraints.fields)
  }

  func testExecute_NoMatchingFormat_ThrowsNoCompatibleCredentials() async throws {
    verifiableCredentialRepository.getAllReturnValue = [.Mock.diploma]

    do {
      _ = try await useCase.execute(using: .Mock.VcSdJwt.sample)
      XCTFail("Should have thrown an exception")
    } catch CompatibleCredentialsError.compatibleCredentialNotFound {
      XCTAssertTrue(verifiableCredentialRepository.getAllCalled)
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
    verifiableCredentialRepository.getAllReturnValue = []
    do {
      _ = try await useCase.execute(using: .Mock.VcSdJwt.sample)
      XCTFail("Should have thrown an exception")
    } catch CompatibleCredentialsError.emptyWallet {
      XCTAssertTrue(verifiableCredentialRepository.getAllCalled)
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

  private var verifiableCredentialRepository = VerifiableCredentialRepositoryProcotolSpy()
  private var createAnyCredentialUseCaseSpy = CreateAnyCredentialUseCaseProtocolSpy()
  private var fieldValidatorSpy = PresentationFieldsValidatorProtocolSpy()

  private var useCase = GetCompatibleCredentialsUseCase()

  private func setUpMocks() {
    mockMatchingFields = [firstNameField, lastNameField]

    verifiableCredentialRepository = VerifiableCredentialRepositoryProcotolSpy()
    createAnyCredentialUseCaseSpy = CreateAnyCredentialUseCaseProtocolSpy()
    fieldValidatorSpy = PresentationFieldsValidatorProtocolSpy()

    Container.shared.verifiableCredentialRepository.register { self.verifiableCredentialRepository }
    Container.shared.createAnyCredentialUseCase.register { self.createAnyCredentialUseCaseSpy }
    Container.shared.presentationFieldsValidator.register { self.fieldValidatorSpy }
  }

  private func success() {
    verifiableCredentialRepository.getAllReturnValue = mockCredentials
    createAnyCredentialUseCaseSpy.executeFromFormatReturnValue = mockAnyCredential
    fieldValidatorSpy.validateWithReturnValue = mockMatchingFields
  }

}
