import BITL10n
import BITPushNotification
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
      if let pushId {
        try await deletePushIdUseCase(pushId)
      }

      try await deleteEIDRequestCaseUseCase.execute(id)
      delegate?.didDeleteRequestCase()
    } catch {
      // Silent failing
    }
  }

  // MARK: Private

  @Injected(\.deletePushIdUseCase) private var deletePushIdUseCase: DeletePushIdUseCaseProtocol
  @Injected(\.deleteEIDRequestCaseUseCase) private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol

}
