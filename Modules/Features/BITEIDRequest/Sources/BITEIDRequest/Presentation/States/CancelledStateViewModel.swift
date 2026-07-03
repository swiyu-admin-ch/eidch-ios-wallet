import BITL10n
import BITPushNotification
import Factory
import Foundation

public class CancelledStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Internal

  var notificationTitle: String {
    L10n.tkEidRequestNotificationCancelledPrimary
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationCancelledSecondary
  }

  func deleteRequestCase() async {
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
