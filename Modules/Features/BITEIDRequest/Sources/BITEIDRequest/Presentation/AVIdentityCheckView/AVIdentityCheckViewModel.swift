import BITAVWrapper
import BITNavigation
import Factory
import SwiftUI

class AVIdentityCheckViewModel: ObservableObject {

  // MARK: Internal

  @Published var destination: EIDRequestDestinations?

  @MainActor
  func primaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      Task.detached { [weak self] in
        guard let self else {
          return
        }

        try? avBeam.initialize(using: AVBeamInitConfig(appId: avBeamAppID))
      }

      let response = try await startAutoVerificationUseCase.execute(for: caseId)
      context.autoVerificationResponse = response
      context.identityType = response.isNFCRequired ? .passport : .identityCard

      destination = getNextDestination(from: response)
    } catch {
      #warning("TODO: Handle error case here when implemented")
    }
  }

  // MARK: Private

  @Injected(\.avBeamAppID) private var avBeamAppID
  @Injected(\.avBeam) private var avBeam: AVBeamProtocol
  @Injected(\.eidRequestContext) private var context
  @Injected(\.startAutoVerificationUseCase) private var startAutoVerificationUseCase

  private func getNextDestination(from response: AutoVerificationResponse) -> EIDRequestDestinations {
    if response.isNFCRequired {
      return .nfcScan
    }
    if response.isScanDocumentRequired {
      return .scanDocumentInformation(isBackEnabled: false)
    }
    if response.isDocumentVideoRecordingRequired {
      return .recordDocumentInformation
    }

    return .avIntroSelfieVideo
  }
}
