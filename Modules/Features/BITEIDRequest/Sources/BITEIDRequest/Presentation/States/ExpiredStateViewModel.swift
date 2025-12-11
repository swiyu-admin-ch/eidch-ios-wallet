import BITL10n
import Factory

public class ExpiredStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Internal

  var notificationTitle: String {
    L10n.tkEidRequestNotificationEidExpiredPrimary(fullName)
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationEidExpiredSecondary
  }

  func primaryAction() async {
    do {
      try await deleteEIDRequestCaseUseCase.execute(id)
      delegate?.didDeleteRequestCase()
    } catch {
      // Do nothing
    }
  }

  // MARK: Private

  @Injected(\.deleteEIDRequestCaseUseCase) private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol

}
