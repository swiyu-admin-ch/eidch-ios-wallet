import BITL10n
import Factory

public class UnknownStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Internal

  var notificationTitle: String {
    L10n.tkEidRequestNotificationEidUnknownStatePrimary(fullName)
  }

  var notificationContent: String {
    L10n.tkEidRequestNotificationEidUnknownStateSecondary
  }

  var primaryActionLabel: String {
    L10n.tkEidRequestNotificationEidUnknownStateButton
  }

  func primaryAction() async {
    do {
      try await updateEIDRequestCaseStatusUseCase.execute(for: id)
      delegate?.didUpdateRequestCaseState()
    } catch {
      // Do nothing
    }
  }

  // MARK: Private

  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol

}
