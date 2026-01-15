import BITActivity
import BITL10n

extension ActivityType {
  var reportActorButtonTitle: String {
    switch self {
    case .issuance: L10n.tkActivityActivityDetailReportIssuerButton
    case .presentationAccepted,
         .presentationDeclined: L10n.tkActivityActivityDetailReportVerifierButton
    }
  }
}
