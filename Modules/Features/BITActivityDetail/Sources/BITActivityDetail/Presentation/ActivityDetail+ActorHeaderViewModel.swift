import BITActivity
import BITCredential
import BITL10n

extension ActivityDetail {

  // MARK: Internal

  var actorHeaderViewModel: ActorHeaderViewModel {
    ActorHeaderViewModel(
      name: actorDisplay?.name,
      actorTrust: actorTrust,
      imageData: actorDisplay?.image,
      nonComplianceReason: nonComplianceReason)
  }

  // MARK: Private

  private var nonComplianceReason: String? {
    guard actorCompliance == .notCompliant else { return nil }
    return nonComplianceReasonDisplay?.value ?? L10n.tkNonComplianceReasonFallback
  }
}
