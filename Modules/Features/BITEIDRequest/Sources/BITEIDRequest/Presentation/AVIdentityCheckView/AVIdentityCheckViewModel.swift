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

      destination = getNextDestination(from: response)
    } catch {
      #warning("TODO: Handle error case here when implemented")
    }
  }

  // MARK: Private

  @Injected(\.eidRequestContext) private var context
  @Injected(\.startAutoVerificationUseCase) private var startAutoVerificationUseCase

  private func getNextDestination(from response: AutoVerificationResponse) -> EIDRequestDestinations {
    if response.isScanDocumentRequired {
      .scanDocument
    } else if response.isNFCRequired {
      .nfcScan
    } else {
      .recordDocument
    }
  }
}
