import BITCredentialShared
import BITOpenID
import Foundation

// MARK: - ActivityDetailCredential

public struct ActivityDetailCredential: Identifiable, Codable, Equatable, Sendable {

  // MARK: Lifecycle

  public init(
    id: UUID,
    displays: [CredentialDisplay],
    environment: TrustEnvironment,
    clusters: [CredentialClaimCluster],
    statusListState: CredentialStatus? = nil)
  {
    self.id = id
    self.displays = displays
    self.environment = environment
    self.clusters = clusters
    self.statusListState = statusListState
  }

  // MARK: Public

  public let id: UUID
  public let displays: [CredentialDisplay]
  public let environment: TrustEnvironment
  public let clusters: [CredentialClaimCluster]

  public let statusListState: CredentialStatus?
}
