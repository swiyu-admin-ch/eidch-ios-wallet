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

  @Published var isErrorPresented = false
  @Published var errorDescription: String? = nil

  func submit(_ payload: EIDRequestPayload) async {
    do {
      let (requestCase, status) = try await submitEIDRequestUseCase.execute(payload.mrz)

      guard let status else {
        return close()
      }

      if let legalRepresentant = status.legalRepresentant, !legalRepresentant.isVerified {
        return router.legalRepresentantConsent(caseId: requestCase.id)
      }

      let viewState = try RequestCaseViewState(requestCase)

      return switch viewState {
      case .inQueue(let state): router.queueInformation(state.onlineSessionStartOpenAt)
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
