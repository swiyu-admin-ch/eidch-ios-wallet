import BITNetworking
import Factory
import Foundation

@MainActor
class MRZScannerViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  @Published var isLoading = false
  @Published var isErrorPresented = false
  @Published var errorDescription: String? = nil

  func submit(_ payload: EIDRequestPayload) async {
    if isLoading {
      return
    }

    do {
      isLoading = true
      let requestCase = try await submitEIDRequestUseCase.execute(mrz: payload.mrz, hasLegalRepresentant: router.context.hasLegalRepresentant)
      isLoading = false

      guard requestCase.state != nil else {
        return close()
      }

      let viewState = try RequestCaseViewState(requestCase)

      if !viewState.isLegalRepresentantConsentVerified {
        return router.legalRepresentantConsent(caseId: requestCase.id)
      }

      return switch viewState {
      case .inQueue(let state): router.queueInformation(state.onlineSessionStartOpenAt)
      case .readyForOnlineSession: router.avIdentityCheck()
      default: close()
      }
    } catch let error as NetworkError {
      if let data = error.response?.data {
        errorDescription = String(data: data, encoding: .utf8)
        isErrorPresented = true
      }
    } catch {
      errorDescription = error.localizedDescription
      isErrorPresented = true
    }

    isLoading = false
  }

  func close() {
    router.close()
  }

  func resetError() {
    isErrorPresented = false
    errorDescription = nil
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes

  @Injected(\.submitEIDRequestUseCase) private var submitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol
}
