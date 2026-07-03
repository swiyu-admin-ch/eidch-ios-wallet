import BITCore
import BITCredentialShared
import BITL10n
import Foundation

struct CredentialClaimViewModel {

  // MARK: Lifecycle

  init(_ claim: CredentialClaim) {
    self.claim = claim
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
    if valueLabel.isEmpty || valueLabel == "–" {
      return "\(nameLabel), \(L10n.tkGlobalEmpty)"
    }
    return "\(nameLabel), \(valueLabel)"
  }

  var isSensitive: Bool {
    claim.isSensitive
  }

  // MARK: Private

  private let claim: CredentialClaim

  private var valueType: ValueType? {
    ValueType(rawValue: claim.valueType)
  }
}
