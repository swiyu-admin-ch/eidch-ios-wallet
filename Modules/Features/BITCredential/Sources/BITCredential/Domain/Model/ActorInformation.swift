import Foundation

// MARK: - ActorInformation

public struct ActorInformation: Equatable, Hashable {

  // MARK: Lifecycle

  public init(
    identity: IdentityTrust,
    actorName: String,
    imageData: Data? = nil,
    nonComplianceReason: String? = nil)
  {
    self.identity = identity
    self.actorName = actorName
    self.imageData = imageData
    self.nonComplianceReason = nonComplianceReason
  }

  // MARK: Public

  public let identity: IdentityTrust
  public let actorName: String
  public let imageData: Data?
  public let nonComplianceReason: String?

  public var isNonCompliant: Bool {
    nonComplianceReason != nil
  }
}
