import Factory
import Foundation
import Spyable
import Testing
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITPushNotification
@testable import BITTestingCore
@testable import BITTheming

// swiftlint:disable implicitly_unwrapped_optional

// MARK: - ScanDocumentSubmitViewModelTests

@MainActor
final class ScanDocumentSubmitViewModelTests {

  // MARK: Lifecycle

  init() {
    Container.shared.reset()

    let context = EIDRequestContext()
    context.hasLegalRepresentant = true
    context.identityType = .passport

    let applyEIDRequestUseCase = ApplyEIDRequestUseCaseProtocolSpy()
    let compareScanDocumentOutputUseCase = CompareScanDocumentOutputUseCaseProtocolSpy()
    let updateEIDRequestCaseFilesUseCase = UpdateEIDRequestCaseFilesUseCaseProtocolSpy()
    let enablePushNotificationsUseCase = EnablePushNotificationsUseCaseProtocolSpy()
    let coordinator = EIDRequestFlowCoordinatorProtocolSpy()

    Container.shared.eidRequestContext.register { @MainActor in context }
    Container.shared.applyEIDRequestUseCase.register { @MainActor in applyEIDRequestUseCase }
    Container.shared.compareScanDocumentOutputUseCase.register { @MainActor in compareScanDocumentOutputUseCase }
    Container.shared.updateEIDRequestCaseFilesUseCase.register { @MainActor in updateEIDRequestCaseFilesUseCase }
    Container.shared.enablePushNotificationsUseCase.register { @MainActor in enablePushNotificationsUseCase }
    Container.shared.eidRequestFlowCoordinator.register { @MainActor in coordinator }

    self.context = context
    self.applyEIDRequestUseCase = applyEIDRequestUseCase
    self.compareScanDocumentOutputUseCase = compareScanDocumentOutputUseCase
    self.updateEIDRequestCaseFilesUseCase = updateEIDRequestCaseFilesUseCase
    self.enablePushNotificationsUseCase = enablePushNotificationsUseCase
    self.coordinator = coordinator
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    success()
  }

  // MARK: Internal

  @Test
  func initialState() {
    #expect(viewModel.destination == nil)
    #expect(!viewModel.isNavigationCloseTriggered)
    #expect(viewModel.scanImages.count == 2)
  }

  @Test
  func submit_arguments() async {
    await viewModel.submit()

    #expect(applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReceivedArguments?.scanDocumentOutput == scanDocumentOutput)
    #expect(applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReceivedArguments?.hasLegalRepresentant == true)
  }

  @Test
  func submit_inQueueStateVerified_routeToQueueInformation() async throws {
    let viewState = try RequestCaseViewState(mockEidRequestCase)

    await viewModel.submit()

    if case .inQueue(let inQueueStateViewModel) = viewState {
      #expect(viewModel.destination == .queueInformation(inQueueStateViewModel.onlineSessionStartOpenAt))
      #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)
      #expect(enablePushNotificationsUseCase.callAsFunctionForReceivedCaseId == mockEidRequestCase.id)
    }
  }

  @Test
  func submit_withNotDeterminedPushPermission_routesToPushPermission() async throws {
    coordinator.getNextDestinationForReturnValue = .pushPermission(mockEidRequestCase)

    await viewModel.submit()

    guard case .pushPermission(let requestCase) = try #require(viewModel.destination) else {
      Issue.record("Expected push permission destination")
      return
    }

    #expect(requestCase.id == mockEidRequestCase.id)
    #expect(context.caseId == nil)
    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
  }

  @Test
  func submit_withDeniedPushPermission_routesToPushPermission() async throws {
    coordinator.getNextDestinationForReturnValue = .pushPermission(mockEidRequestCase)

    await viewModel.submit()

    guard case .pushPermission(let requestCase) = try #require(viewModel.destination) else {
      Issue.record("Expected push permission destination")
      return
    }

    #expect(requestCase.id == mockEidRequestCase.id)
    #expect(context.caseId == nil)
    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
  }

  @Test
  func submit_withLegalRepresentantConsent_registersPushTokenAndRoutesToLegalRepresentantConsent() async {
    let requestCase = EIDRequestCase.Mock.sampleInQueueNotVerified
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = requestCase
    coordinator.getNextDestinationForReturnValue = .legalRepresentantConsent(caseId: requestCase.id)

    await viewModel.submit()

    #expect(viewModel.destination == .legalRepresentantConsent(caseId: requestCase.id))
    #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)
    #expect(enablePushNotificationsUseCase.callAsFunctionForReceivedCaseId == requestCase.id)
  }

  @Test
  func submit_withWalletPairing_registersPushTokenAndRoutesToWalletPairing() async {
    let requestCase = EIDRequestCase.Mock.sampleAVReady
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = requestCase
    coordinator.getNextDestinationForReturnValue = .walletPairing

    await viewModel.submit()

    #expect(viewModel.destination == .walletPairing)
    #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)
    #expect(enablePushNotificationsUseCase.callAsFunctionForReceivedCaseId == requestCase.id)
  }

  @Test
  func submit_withRegisterPushTokenError_routesToError() async {
    enablePushNotificationsUseCase.callAsFunctionForThrowableError = TestingError.error

    await viewModel.submit()

    #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)

    if case .error = viewModel.destination {
      #expect(true)
    } else {
      Issue.record("Expected error destination")
    }
  }

  @Test
  func submit_emptyFiles_flowContinues() async throws {
    let scanDocumentOutput = try ScanDocumentOutput(mrz: MRZ(values: MRZ.Mock.sampleValues), identityType: .identityCard)
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)
    await viewModel.submit()

    #expect(viewModel.destination != nil)
    #expect(enablePushNotificationsUseCase.callAsFunctionForCallsCount == 1)
  }

  @Test
  func submit_errorHandling_doesNotCrash() async {
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantThrowableError = TestingError.error

    await viewModel.submit()

    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
  }

  @Test
  func submit_appliesMinimumDelay() async {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    let startTime = Date()
    await viewModel.submit()
    let endTime = Date()

    let elapsedTime = endTime.timeIntervalSince(startTime)
    #expect(elapsedTime >= 1.8)
  }

  @Test
  func submit_fastResponse_stillAppliesMinimumDelay() async {
    let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue
    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase

    let startTime = Date()
    await viewModel.submit()
    let endTime = Date()

    let elapsedTime = endTime.timeIntervalSince(startTime)
    #expect(elapsedTime >= 1.8)
  }

  @Test
  func submit_autoVerificationWithDocumentRecording_routesToRecordDocumentInformation() async {
    context = EIDRequestContext.Mock.documentRecordingSample
    context.identityType = .identityCard
    Container.shared.eidRequestContext.register { @MainActor in self.context }
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    await viewModel.submit()

    #expect(viewModel.destination == .recordDocumentInformation)
    #expect(compareScanDocumentOutputUseCase.callAsFunctionForWithReceivedArguments?.caseId == "caseId")
    #expect(updateEIDRequestCaseFilesUseCase.callAsFunctionForScanDocumentOutputReceivedArguments?.caseId == "caseId")
    #expect(!applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantCalled)
    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
  }

  @Test
  func submit_autoVerificationWithoutDocumentRecording_routesToSelfieVideo() async {
    context = EIDRequestContext.Mock.sample
    context.identityType = .identityCard
    Container.shared.eidRequestContext.register { @MainActor in self.context }
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    await viewModel.submit()

    #expect(viewModel.destination == .avIntroSelfieVideo)
    #expect(updateEIDRequestCaseFilesUseCase.callAsFunctionForScanDocumentOutputReceivedArguments?.caseId == "caseId")
    #expect(!applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantCalled)
    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
  }

  @Test
  func submit_autoVerificationWrongDocument_routesToError() async {
    context = EIDRequestContext.Mock.sample
    context.identityType = .identityCard
    compareScanDocumentOutputUseCase.callAsFunctionForWithReturnValue = false
    Container.shared.eidRequestContext.register { @MainActor in self.context }
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    await viewModel.submit()

    if case .error(let dataset) = viewModel.destination {
      #expect(dataset == .ScanDocument.wrongDocument)
    } else {
      Issue.record("Expected wrong document error")
    }
    #expect(!updateEIDRequestCaseFilesUseCase.callAsFunctionForScanDocumentOutputCalled)
    #expect(!applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantCalled)
    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
  }

  @Test
  func submit_autoVerificationUploadFails_routesToRetryError() async {
    context = EIDRequestContext.Mock.sample
    context.identityType = .identityCard

    let throwingUseCase = ThrowingUpdateEIDRequestCaseFilesUseCase(error: TestingError.error)
    Container.shared.eidRequestContext.register { @MainActor in self.context }
    Container.shared.updateEIDRequestCaseFilesUseCase.register { @MainActor in throwingUseCase }
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    await viewModel.submit()

    if case .error(let dataset) = viewModel.destination {
      #expect(dataset == ErrorDataset.retry(TestingError.error) { _ in })
    } else {
      Issue.record("Expected retry error")
    }
    #expect(!applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantCalled)
    #expect(!enablePushNotificationsUseCase.callAsFunctionForCalled)
  }

  func test_onDisplay_whenImageIsRecto() throws {
    let scanDocumentOutput = try ScanDocumentOutput(
      mrz: MRZ(values: MRZ.Mock.sampleValues),
      files: EIDRequestCaseFile.Mock.sampleArray,
      identityType: .identityCard)
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    viewModel.displayScanImageOverview(.Mock.croppedIDScanRecto)

    #expect(viewModel.destination == .scanDocumentImageOverview(image: .Mock.fullframeIDScanRecto))
  }

  func test_onDisplay_whenImageIsVerso() throws {
    let scanDocumentOutput = try ScanDocumentOutput(
      mrz: MRZ(values: MRZ.Mock.sampleValues),
      files: EIDRequestCaseFile.Mock.sampleArray,
      identityType: .identityCard)
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    viewModel.displayScanImageOverview(.Mock.croppedIDScanVerso)

    #expect(viewModel.destination == .scanDocumentImageOverview(image: .Mock.fullframeIDScanVerso))
  }

  // MARK: Private

  private var context: EIDRequestContext!
  private let scanDocumentOutput = ScanDocumentOutput(
    mrz: MRZ.Mock.sample,
    files: EIDRequestCaseFile.Mock.sampleArray,
    scanningOrientiations: [.recto: .portrait, .verso: .portrait],
    identityType: .identityCard)
  private let mockEidRequestCase = EIDRequestCase.Mock.sampleInQueue

  private var viewModel: ScanDocumentSubmitViewModel
  private let applyEIDRequestUseCase: ApplyEIDRequestUseCaseProtocolSpy
  private let compareScanDocumentOutputUseCase: CompareScanDocumentOutputUseCaseProtocolSpy
  private let updateEIDRequestCaseFilesUseCase: UpdateEIDRequestCaseFilesUseCaseProtocolSpy
  private let enablePushNotificationsUseCase: EnablePushNotificationsUseCaseProtocolSpy
  private let coordinator: EIDRequestFlowCoordinatorProtocolSpy

  private func success() {
    viewModel = ScanDocumentSubmitViewModel(scanDocumentOutput: scanDocumentOutput)

    applyEIDRequestUseCase.callAsFunctionScanDocumentOutputHasLegalRepresentantReturnValue = mockEidRequestCase
    compareScanDocumentOutputUseCase.callAsFunctionForWithReturnValue = true
    if case .inQueue(let state) = try? RequestCaseViewState(mockEidRequestCase) {
      coordinator.getNextDestinationForReturnValue = .queueInformation(state.onlineSessionStartOpenAt)
    }
  }

}


private final class ThrowingUpdateEIDRequestCaseFilesUseCase: UpdateEIDRequestCaseFilesUseCaseProtocol {

  // MARK: Lifecycle

  init(error: Error) {
    self.error = error
  }

  // MARK: Internal

  func callAsFunction(for caseId: String, scanDocumentOutput: ScanDocumentOutput) async throws {
    throw error
  }

  // MARK: Private

  private let error: Error
}
