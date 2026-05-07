import BITL10n
import BITOpenID
import BITTheming

extension PresentationError {

  var errorDataset: ErrorDataset? {
    switch self {
    case .submitPresentationError(let rawErrorCode, let description):
      var content: [InformationView2.ContentType] = [
        .title(L10n.tkPresentErrorPrimary),
        .body(L10n.tkPresentErrorSecondary),
      ]
      if let rawErrorCode {
        content.append(.caption(rawErrorCode))
      }
      if let description {
        content.append(.caption(description))
      }
      return ErrorDataset(content)
    default: return nil
    }
  }
}
