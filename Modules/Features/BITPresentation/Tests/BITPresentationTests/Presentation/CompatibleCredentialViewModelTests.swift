// swiftlint:disable implicitly_unwrapped_optional force_unwrapping
import Factory
import XCTest
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation

// MARK: - CompatibleCredentialViewModelTests

final class CompatibleCredentialViewModelTests: XCTestCase {

  // MARK: Internal

  @MainActor
  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()

    router.delegate = presentationFinishDelegateMock

    viewModel = CompatibleCredentialViewModel(context: Self.contextMock, inputDescriptorId: Self.inputDescriptorMock.id, compatibleCredentials: compatibleCredentialMocks, router: router)
    createSuccessState()
  }

  @MainActor
  func testVerifierDisplay_oneLanguage_returnsDisplayInLanguage() {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    viewModel = CompatibleCredentialViewModel(context: Self.contextMock, inputDescriptorId: Self.inputDescriptorMock.id, compatibleCredentials: compatibleCredentialMocks, router: router)

    XCTAssertEqual(viewModel.verifierDisplay.name, "EN entityName")
    XCTAssertEqual(String(data: viewModel.verifierDisplay.logo!, encoding: .utf8)!, "EN_logoUri")
    XCTAssertEqual(viewModel.verifierDisplay.trustInformation, Self.contextMock.trustInformation)
  }

  @MainActor
  func testDidSelect_navigatesAndSelectsCredential() async throws {
    viewModel.didSelect(credential: compatibleCredentialMocks[1].credential)

    XCTAssertTrue(router.didCallPresentationReview)
    XCTAssertEqual(Self.contextMock.selectedCredentials[Self.inputDescriptorMock.id], compatibleCredentialMocks[1])
  }

  @MainActor
  func testCancel_delegateCancelCalled() {
    viewModel.cancel()

    XCTAssertEqual(presentationFinishDelegateMock.cancelCalled, true)
  }

  func testUpdateCredentialViewModels_light_setsViewModel() async {
    var calls = 0
    getCredentialDisplayUseCaseSpy.executeForColorSchemeClosure = { _, _ in
      if calls == 0 {
        calls += 1
        return .Mock.lightEnglish
      }
      return .Mock.sample
    }

    viewModel.updateCredentialViewModels(with: themeMock)

    XCTAssertEqual(viewModel.credentialViewModels[0].credentialDisplay, .Mock.lightEnglish)
    XCTAssertEqual(viewModel.credentialViewModels[0].credential, compatibleCredentialMocks[0].credential)
    XCTAssertEqual(viewModel.credentialViewModels[1].credentialDisplay, .Mock.sample)
    XCTAssertEqual(viewModel.credentialViewModels[1].credential, compatibleCredentialMocks[1].credential)
  }

  func testUpdateCredentialViewModels_argumentsPassed() async {
    viewModel.updateCredentialViewModels(with: themeMock)

    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedInvocations[0].colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedInvocations[0].displays, compatibleCredentialMocks[0].credential.displays)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedInvocations[1].colorScheme, themeMock)
    XCTAssertEqual(getCredentialDisplayUseCaseSpy.executeForColorSchemeReceivedInvocations[1].displays, compatibleCredentialMocks[1].credential.displays)
  }

  // MARK: Private

  private static var contextMock = PresentationRequestContext.Mock.vcSdJwtWithIdentityTrust
  private static let inputDescriptorMock = contextMock.requestObject.presentationDefinition.inputDescriptors.first!

  private let themeMock = "light"

  private var viewModel: CompatibleCredentialViewModel!
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()

  private let router = MockPresentationRouter()
  private let presentationFinishDelegateMock = MockPresentationFinishDelegate()
  private let compatibleCredentialMocks = [CompatibleCredential.Mock.BIT, CompatibleCredential.Mock.diploma]

  private func createSuccessState() {
    getCredentialDisplayUseCaseSpy.executeForColorSchemeReturnValue = .Mock.lightEnglish
  }

  private func registerMocks() {
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCaseSpy }
  }
}
