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
    viewModel = CompatibleCredentialViewModel(context: Self.contextMock, inputDescriptorId: Self.inputDescriptorMock.id, compatibleCredentials: compatibleCredentialMocks, router: router)
    createSuccessState()
  }

  @MainActor
  func testInit_setsValues() {
    viewModel = CompatibleCredentialViewModel(context: Self.contextMock, inputDescriptorId: Self.inputDescriptorMock.id, compatibleCredentials: compatibleCredentialMocks, router: router)

    XCTAssertNotNil(Self.contextMock.trustStatement)
    XCTAssertNotNil(viewModel.verifierDisplay)
    XCTAssertEqual(viewModel.verifierDisplay?.trustStatus, .verified)
    XCTAssertEqual(getVerifierDisplayUseCaseSpy.executeForTrustStatementReceivedArguments?.trustStatement, Self.contextMock.trustStatement)
    XCTAssertEqual(getVerifierDisplayUseCaseSpy.executeForTrustStatementReceivedArguments?.verifier, Self.contextMock.requestObject.clientMetadata)
  }

  @MainActor
  func testDidSelect_navigatesAndSelectsCredential() async throws {
    viewModel.didSelect(credential: compatibleCredentialMocks[1].credential)

    XCTAssertTrue(router.didCallPresentationReview)
    XCTAssertEqual(Self.contextMock.selectedCredentials[Self.inputDescriptorMock.id], compatibleCredentialMocks[1])
  }

  @MainActor
  func testClose() {
    viewModel.close()

    XCTAssertTrue(router.closeCalled)
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

  // swiftlint:disable all
  private static var contextMock = PresentationRequestContext.Mock.vcSdJwtJwtSample
  private static let inputDescriptorMock = contextMock.requestObject.presentationDefinition.inputDescriptors.first!

  private let themeMock = "light"

  private var viewModel: CompatibleCredentialViewModel!
  private var getVerifierDisplayUseCaseSpy = GetVerifierDisplayUseCaseProtocolSpy()
  private var getCredentialDisplayUseCaseSpy = GetCredentialDisplayUseCaseProtocolSpy()

  private let router = MockPresentationRouter()
  private let compatibleCredentialMocks = [CompatibleCredential.Mock.BIT, CompatibleCredential.Mock.diploma]

  // swiftlint:enable all

  private func createSuccessState() {
    getVerifierDisplayUseCaseSpy.executeForTrustStatementReturnValue = .Mock.sample
    getCredentialDisplayUseCaseSpy.executeForColorSchemeReturnValue = .Mock.lightEnglish
  }

  private func registerMocks() {
    Container.shared.getVerifierDisplayUseCase.register { self.getVerifierDisplayUseCaseSpy }
    Container.shared.getCredentialDisplayUseCase.register { self.getCredentialDisplayUseCaseSpy }
  }
}
