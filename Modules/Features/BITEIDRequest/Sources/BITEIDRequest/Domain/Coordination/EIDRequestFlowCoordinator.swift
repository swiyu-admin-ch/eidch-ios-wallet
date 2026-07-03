import BITAVWrapper
import BITEIDRequestShared
import BITPushNotification
import Factory
import Foundation
import Spyable


@Spyable @MainActor
protocol EIDRequestFlowCoordinatorProtocol: AnyObject {
  func getNextDestination(for requestCase: EIDRequestCase) async throws -> EIDRequestDestinations?
  func getNextDestinationAfterApply(for requestCase: EIDRequestCase) throws -> EIDRequestDestinations?
  func cleanup()
}


@MainActor
class EIDRequestFlowCoordinator: EIDRequestFlowCoordinatorProtocol {

  // MARK: Internal

  func getNextDestination(for requestCase: EIDRequestCase) async throws -> EIDRequestDestinations? {
    guard requestCase.state != nil else {
      return nil
    }

    let pushPermissionStatus = await getPushPermissionStatusUseCase()

    return switch pushPermissionStatus {
    case .authorized,
         .ephemeral,
         .provisional:
      try getNextDestinationAfterApply(for: requestCase)
    case .denied,
         .notDetermined:
      .pushPermission(requestCase)
    @unknown default:
      .pushPermission(requestCase)
    }
  }

  func getNextDestinationAfterApply(for requestCase: EIDRequestCase) throws -> EIDRequestDestinations? {
    let viewState = try RequestCaseViewState(requestCase)
    context.caseId = requestCase.id

    if !viewState.isLegalRepresentantConsentVerified {
      return .legalRepresentantConsent(caseId: requestCase.id)
    }

    switch viewState {
    case .inQueue(let state):
      return .queueInformation(state.onlineSessionStartOpenAt)
    case .readyForOnlineSession:
      return .walletPairing
    default:
      return nil
    }
  }

  func cleanup() {
    shutdownAVBeam()
    cleanupContext()
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
  @Injected(\.avBeam) private var avBeam: AVBeamProtocol
  @Injected(\.getPushPermissionStatusUseCase) private var getPushPermissionStatusUseCase: GetPushPermissionStatusUseCaseProtocol

  private func shutdownAVBeam() {
    avBeam.stopCaptureFace()
    avBeam.stopRecordDocument()
    avBeam.stopScanDocument()
    try? avBeam.stopCamera()
    avBeam.shutdown()
  }

  private func cleanupContext() {
    context.hasLegalRepresentant = false
    context.identityType = nil
    context.caseId = nil
    context.autoVerificationResponse = nil
  }
}
