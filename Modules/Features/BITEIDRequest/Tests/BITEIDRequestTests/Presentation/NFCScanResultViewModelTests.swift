import BITL10n
import Factory
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore

// MARK: - NFCScanResultViewModelTests

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

@MainActor
final class NFCScanResultViewModelTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    viewModel = NFCScanResultViewModel(package: mockAVBeamPackageResult)
    createSuccesState()
  }

  func testPrimaryAction_documentRecordingRequired_routeToDocumentRecording() {
    mockContext = EIDRequestContext.Mock.documentRecordingSample

    Container.shared.eidRequestContext.register { @MainActor in self.mockContext }
    viewModel = NFCScanResultViewModel(package: mockAVBeamPackageResult)

    viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .recordDocumentInformation)
  }

  func testPrimaryAction_noAutoVerificationResponse_routeToSelfie() {
    mockContext = EIDRequestContext()

    viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .avIntroSelfieVideo)
  }

  func testPrimaryAction_documentRecordingIsNotRequired_routeToSelfie() {
    mockContext = EIDRequestContext.Mock.sample

    viewModel.primaryAction()

    XCTAssertEqual(viewModel.destination, .avIntroSelfieVideo)
  }

  func testScanResult_success() async {
    await viewModel.fetchScanResult()

    XCTAssertEqual(viewModel.state, .results(mockNFCScanResultEntries))

    XCTAssertEqual(fetchNFCScanResultUseCase.executeForPackageResultCallsCount, 1)
    XCTAssertEqual(fetchNFCScanResultUseCase.executeForPackageResultReceivedArguments?.caseId, mockCaseId)
    XCTAssertEqual(fetchNFCScanResultUseCase.executeForPackageResultReceivedArguments?.packageResult, mockAVBeamPackageResult)
  }

  func testScanResult_missingCaseId_throwsError() async {
    mockContext.caseId = nil

    await viewModel.fetchScanResult()

    XCTAssertEqual(viewModel.state, .error(EIDRequestError.missingCaseId))
  }

  func testScanResult_fetchResultFails_throwsError() async {
    fetchNFCScanResultUseCase.executeForPackageResultThrowableError = TestingError.error

    await viewModel.fetchScanResult()

    XCTAssertEqual(viewModel.state, .error(TestingError.error))
  }

  // MARK: Private

  private let mockCaseId = "caseId"
  private var viewModel: NFCScanResultViewModel!
  private let mockAVBeamPackageResult = AVBeamPackageResult.Mock.sample
  private let mockNFCScanResult = NFCScanResult.Mock.sample
  private var mockNFCScanResultEntries: [ScanResultEntryType]!
  private var fetchNFCScanResultUseCase: FetchNFCScanResultUseCaseProtocolSpy!
  private var mockContext: EIDRequestContext!

  private func registerMocks() {
    mockContext = EIDRequestContext(caseId: mockCaseId)
    fetchNFCScanResultUseCase = FetchNFCScanResultUseCaseProtocolSpy()
    mockNFCScanResultEntries = [
      .image(
        ScanResultEntryImage(
          key: L10n.tkEidRequestNfcScanResultPhotoKey,
          value: mockNFCScanResult.facePicture,
          side: .recto,
          uiOrientation: .portrait,
          accessibilityLabel: L10n.tkEidRequestNfcScanResultPhotoAlt)),
      .text(key: L10n.tkEidRequestNfcScanResultSurnameKey, value: mockNFCScanResult.surname),
      .text(key: L10n.tkEidRequestNfcScanResultGivenNamesKey, value: mockNFCScanResult.givenName),
      .text(key: L10n.tkEidRequestNfcScanResultExpirationDateKey, value: mockNFCScanResult.expirationDate),
      .text(key: L10n.tkEidRequestNfcScanResultPassportNumberKey, value: mockNFCScanResult.passportNumber),
    ]

    Container.shared.eidRequestContext.register { @MainActor in self.mockContext }
    Container.shared.fetchNFCScanResultUseCase.register { @MainActor in self.fetchNFCScanResultUseCase }
  }

  private func createSuccesState() {
    fetchNFCScanResultUseCase.executeForPackageResultReturnValue = mockNFCScanResult
  }

}

// MARK: - NFCScanResultViewModel.State + Equatable

extension NFCScanResultViewModel.State: Equatable {
  public static func == (lhs: NFCScanResultViewModel.State, rhs: NFCScanResultViewModel.State) -> Bool {
    switch (lhs, rhs) {
    case (.loading, .loading):
      true
    case (.results(let lhsResult), .results(let lhsRight)):
      lhsResult == lhsRight
    case (.error(let l), .error(let r)):
      l.localizedDescription == r.localizedDescription
    default:
      false
    }
  }
}
