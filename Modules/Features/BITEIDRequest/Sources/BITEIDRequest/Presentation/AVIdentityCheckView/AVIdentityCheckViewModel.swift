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

      let response = try await startAutoVerificationUseCase.execute(for: caseId)
      context.autoVerificationResponse = response
      context.identityType = response.isNFCRequired ? .passport : .identityCard

      destination = getNextDestination(from: response)
    } catch {
      #warning("TODO: Handle error case here when implemented")
    }
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
  @Injected(\.startAutoVerificationUseCase) private var startAutoVerificationUseCase

  private func getNextDestination(from response: AutoVerificationResponse) -> EIDRequestDestinations {
    if response.isNFCRequired {
      return .nfcScan
    }
    if response.isScanDocumentRequired {
      return .scanDocumentInformation
    }
    if response.isDocumentVideoRecordingRequired {
      return .recordDocumentInformation
    }

    return .avIntroSelfieVideo
  }
}
