import BITAVWrapper
import BITL10n
import BITNavigation
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

@Observable
final class AVIdentityCheckViewModel {

  // MARK: Lifecycle

  init(caseId: String) {
    context.caseId = caseId
  }

  // MARK: Internal

  var destination: EIDRequestDestinations?

  @MainActor
  func primaryAction() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      async let avBeamInit = Task.detached { [weak avBeam, avBeamAppID] in
        try avBeam?.initialize(using: AVBeamInitConfig(appId: avBeamAppID))
      }.result
      async let startAutoVerification = startAutoVerificationUseCase.execute(for: caseId)

      let (_, response) = try await (avBeamInit, startAutoVerification)
      context.autoVerificationResponse = response
      context.identityType = response.isNFCRequired ? .passport : .identityCard

      try await compareWalletPairingUseCase(for: caseId)

      destination = getNextDestination(from: response)
    } catch CompareWalletPairingUseCaseError.invalidPairingCount {
      let errorDataset = ErrorDataset(
        [
          .title(L10n.tkErrorGenericPrimary),
          .body(L10n.tkEidRequestWalletPairingInvalidPairingCountErrorSecondary),
        ],
        actions: [.primaryAsync(L10n.tkGlobalClose) { navigator in
          await self.cancelRequestCase(navigator: navigator)
        }])
      destination = .error(errorDataset)
    } catch {
      destination = .error(.retry(error, { navigator in
        navigator.pop()
      }))
    }
  }

  // MARK: Private

  @ObservationIgnored @Injected(\.avBeamAppID) private var avBeamAppID
  @ObservationIgnored @Injected(\.avBeam) private var avBeam: AVBeamProtocol
  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.startAutoVerificationUseCase) private var startAutoVerificationUseCase
  @ObservationIgnored @Injected(\.compareWalletPairingUseCase) private var compareWalletPairingUseCase: CompareWalletPairingUseCaseProtocol
  @ObservationIgnored @Injected(\.cancelRequestCaseUseCase) private var cancelRequestCaseUseCase: CancelRequestCaseUseCaseProtocol

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

  @MainActor
  private func cancelRequestCase(navigator: Navigator) async {
    guard let caseId = context.caseId else {
      return
    }

    try? await cancelRequestCaseUseCase(for: caseId)
    navigator.returnToHomeSafely()
  }

}
