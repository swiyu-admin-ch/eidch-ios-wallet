import BITCore
import BITCredentialShared
import BITL10n
import Foundation

struct CredentialClaimViewModel {

  // MARK: Lifecycle

  init(_ claim: CredentialClaim, isSensitive: Bool) {
    self.claim = claim
    isClusterSensitive = isSensitive
  }

  // MARK: Internal

  var imageData: Data? {
    guard let type = valueType, type.isImage else { return nil }
    return claim.value.flatMap { Data(base64Encoded: $0) }
  }

  var nameLabel: String {
    claim.preferredDisplay.name ?? claim.path.stringValue
  }

  var valueLabel: String {
    claim.localizedValue
  }

  var accessibilityValueLabel: String {
    var labels = [nameLabel]

    let valueLabel = if valueLabel.isEmpty || valueLabel == "–" {
      L10n.tkGlobalEmpty
    } else {
      valueLabel
    }

    labels.append(valueLabel)

    if isSensitive {
      labels.append(L10n.tkGlobalSensitiveDataAlt)
    }

    return labels.joined(separator: ", ")
  }

  var isSensitive: Bool {
    isClusterSensitive || claim.isSensitive
  }

  // MARK: Private

  private let claim: CredentialClaim
  private let isClusterSensitive: Bool

  private var valueType: ValueType? {
    ValueType(rawValue: claim.valueType)
  }
}
