import BITL10n
import Factory
import Foundation

public class DeclinedStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Internal

  var notificationTitle: String {
    L10n.tkEidRequestNotificationDeclinedPrimary(fullName)
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationDeclinedSecondary
  }

  var primaryActionLabel: String {
    L10n.tkEidRequestNotificationDeclinedPrimaryButton
  }

  func deleteRequestCase() async {
    do {
      try await deleteEIDRequestCaseUseCase.execute(id)
      delegate?.didDeleteRequestCase()
    } catch {
      #warning("TODO: Handle fallback here")
    }
  }

  func openFAQ() {
    guard let url = URL(string: L10n.tkEidRequestNotificationDeclinedFaqLink) else {
      return
    }

    delegate?.didOpenExternalLink(url: url)
  }

  // MARK: Private

  @Injected(\.deleteEIDRequestCaseUseCase) private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol
}
