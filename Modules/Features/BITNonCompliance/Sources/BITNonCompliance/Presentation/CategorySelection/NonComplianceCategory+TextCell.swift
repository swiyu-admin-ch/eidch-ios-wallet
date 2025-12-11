import BITL10n
import BITTheming

extension NonComplianceCategory {
  var cell: TextCell {
    switch self {
    case .excessiveDataRequest: TextCell(title: L10n.tkNonComplianceListExcessiveDataTitle, subtitle: L10n.tkNonComplianceListExcessiveDataBody)
    }
  }
}
