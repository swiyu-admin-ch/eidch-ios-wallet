import BITActivity
import BITCore
import BITL10n
import BITNonCompliance
import Factory
import Foundation

// MARK: - ActorHeaderViewModel

public struct ActorHeaderViewModel: Equatable {

  // MARK: Lifecycle

  public init(name: String? = nil, trustInformation: TrustInformation, actorCompliance: ActorCompliance, imageData: Data? = nil) {
    self.init(
      name: name,
      identity: trustInformation.identity,
      imageData: imageData,
      nonComplianceReason: actorCompliance.nonComplianceReason)
  }

  public init(
    name: String? = nil,
    actorTrust: ActorTrust,
    imageData: Data? = nil,
    nonComplianceReason: String? = nil)
  {
    self.init(
      name: name,
      identity: actorTrust.identity,
      imageData: imageData,
      nonComplianceReason: nonComplianceReason)
  }

  public init(
    name: String? = nil,
    identity: IdentityTrust,
    imageData: Data? = nil,
    nonComplianceReason: String? = nil)
  {
    self.name = name ?? L10n.tkErrorNotregisteredTitle
    self.identity = identity
    self.imageData = imageData
    self.nonComplianceReason = nonComplianceReason
  }

  // MARK: Public

  public let name: String
  public let imageData: Data?
  public let nonComplianceReason: String?

  // MARK: Internal

  let identity: IdentityTrust

  var actorInformation: ActorInformation {
    ActorInformation(
      identity: identity,
      actorName: name,
      imageData: imageData)
  }

  var nonComplianceActorInformation: ActorInformation {
    ActorInformation(
      identity: identity,
      actorName: name,
      imageData: imageData,
      nonComplianceReason: nonComplianceReason)
  }

  var showsTrustBadge: Bool {
    identity == .trusted || identity == .trustedCheckApp
  }

  var isNonCompliant: Bool {
    nonComplianceReason != nil
  }
}

extension ActorCompliance {
  fileprivate var nonComplianceReason: String? {
    guard case .notCompliant(let localizedReason) = self else { return nil }
    return localizedReason?.getPreferredDisplay(considering: Container.shared.preferredUserLanguageCodes()) ?? L10n.tkNonComplianceReasonFallback
  }
}

extension ActorTrust {
  fileprivate var identity: IdentityTrust {
    switch self {
    case .trusted:
      .trusted
    case .trustedCheckApp:
      .trustedCheckApp
    case .untrusted:
      .untrusted
    case .unknown:
      .unknown
    }
  }
}
