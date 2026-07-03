import BITNavigation
import BITPresentation
import BITTheming
import Factory
import Foundation

@MainActor
@Observable
class LegalRepresentantVerificationViewModel: NavigationBackable {

  // MARK: Lifecycle

  init(caseId: String) {
    self.caseId = caseId
  }

  // MARK: Internal

  var destination: EIDRequestDestinations?
  var isNavigationCloseTriggered = false
  var isNavigationBackTriggered = false

  func startVerification() async {
    do {
      let context = try await getLegalRepresentantPresentationRequestContextUseCase.execute(for: caseId)
      destination = .external(.presentation(context))
    } catch EIDRequestRepository.Error.legalRepresentantNotRequired {
      await openConsentState()
    } catch {
      destination = .error(.retry(error) { [weak self] _ in
        self?.errorCallback(error)
      })
    }
  }

  func close() {
    isNavigationCloseTriggered = true
    coordinator.cleanup()
  }

  func finish(with state: PresentationRequestResultState) async {
    switch state {
    case .dataTransmitted: await openConsentState()
    default: close()
    }
  }

  // MARK: Private

  private let caseId: String

  @ObservationIgnored @Injected(\.getLegalRepresentantPresentationRequestContextUseCase) private var getLegalRepresentantPresentationRequestContextUseCase
  @ObservationIgnored @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase
  @ObservationIgnored @Injected(\.eidRequestFlowCoordinator) private var coordinator

  private func openConsentState() async {
    do {
      let requestCase = try await updateEIDRequestCaseStatusUseCase.execute(for: caseId)
      let state = try RequestCaseViewState(requestCase)

      if case .unknown = state {
        return close()
      }

      destination = .legalRepresentantConsentState(state: state)
    } catch {
      destination = .error(.retry(error) { [weak self] _ in
        self?.errorCallback(error)
      })
    }
  }

  private func errorCallback(_ error: Error) {
    switch error {
    case EIDRequestRepository.Error.unknownError:
      back()
    default:
      close()
    }
  }

  private func back() {
    isNavigationBackTriggered = true
  }
}
