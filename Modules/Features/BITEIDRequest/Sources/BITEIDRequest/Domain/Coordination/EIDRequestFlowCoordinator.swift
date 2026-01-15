import BITAVWrapper
import Factory
import Foundation
import Spyable


@Spyable @MainActor
protocol EIDRequestFlowCoordinatorProtocol: AnyObject {
  func cleanup()
}


@MainActor
class EIDRequestFlowCoordinator: EIDRequestFlowCoordinatorProtocol {

  // MARK: Internal

  func cleanup() {
    shutdownAVBeam()
    cleanupContext()
  }

  // MARK: Private

  @Injected(\.avBeam) private var avBeam: AVBeamProtocol
  @Injected(\.eidRequestContext) private var context

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
