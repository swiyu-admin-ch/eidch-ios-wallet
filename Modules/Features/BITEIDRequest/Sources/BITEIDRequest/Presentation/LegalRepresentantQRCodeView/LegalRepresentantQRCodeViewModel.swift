import BITNavigation
import Factory
import Foundation

@MainActor
class LegalRepresentantQRCodeViewModel: ObservableObject {

  // MARK: Lifecycle

  init(caseId: String) {
    self.caseId = caseId
  }

  // MARK: Internal

  enum QRCodeViewState: Equatable {
    case loading
    case error
    case result(Data, URL)
  }

  @Published var state = QRCodeViewState.loading
  @Published var destination: EIDRequestDestinations?
  @Published var isNavigationCloseTriggered = false

  var isShareQRCodeDisabled: Bool {
    state == .loading || state == .error
  }

  func finish() async {
    do {
      let requestCase = try await updateEIDRequestCaseStatusUseCase.execute(for: caseId)
      let state = try RequestCaseViewState(requestCase)

      if case .unknown = state {
        return close()
      }

      destination = .legalRepresentantConsentState(state: state)
    } catch {
      #warning("TODO: errors must be managed. We temporary close the flow for now.")
      isNavigationCloseTriggered = true
    }
  }

  func getVerificationQRCode() async {
    state = .loading

    do {
      let verificationQRCode = try await getLegalRepresentantVerificationQRCodeUseCase.execute(for: caseId)
      state = .result(verificationQRCode.imageData, verificationQRCode.shareLink)
    } catch {
      state = .error
    }
  }

  // MARK: Private

  private let caseId: String

  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase
  @Injected(\.getLegalRepresentantVerificationQRCodeUseCase) private var getLegalRepresentantVerificationQRCodeUseCase
  @Injected(\.eidRequestFlowCoordinator) private var coordinator

  private func close() {
    isNavigationCloseTriggered = true
    coordinator.cleanup()
  }

}
