import BITL10n
import Factory
import Foundation

public class DeclinedStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Internal

  func deleteRequestCase() async {
    do {
      try await deleteEIDRequestCaseUseCase.execute(requestCaseId)
      delegate?.didDeleteRequestCase()
    } catch {
      #warning("TODO: Handle fallback here")
    }
  }

  func openFAQ() {
    guard let url = URL(string: L10n.tkGetEidNotificationDeclinedFaqLink) else {
      return
    }

    delegate?.didOpenExternalLink(url: url)
  }

  // MARK: Private

  @Injected(\.deleteEIDRequestCaseUseCase) private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol
}
