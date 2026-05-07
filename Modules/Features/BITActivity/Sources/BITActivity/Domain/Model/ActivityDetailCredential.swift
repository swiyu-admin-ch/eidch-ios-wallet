import BITCredentialShared
import BITOpenID
import Foundation

// MARK: - ActivityDetailCredential

public struct ActivityDetailCredential: Identifiable, Codable, Equatable {

  public let id: UUID
  public let displays: [CredentialDisplay]
  public let environment: TrustEnvironment
  public let clusters: [CredentialClaimCluster]
}
