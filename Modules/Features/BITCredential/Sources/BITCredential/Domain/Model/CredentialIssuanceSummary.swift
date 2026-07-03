import BITEntities
import Foundation

// MARK: - CredentialIssuanceSummary

public struct CredentialIssuanceSummary: Equatable {

  // MARK: Lifecycle

  public init(issuedAt: Date, available: Int, total: Int) {
    self.issuedAt = issuedAt
    self.available = available
    self.total = total
  }

  public init?(_ entity: CredentialEntity) {
    guard let verifiableCredential = entity.verifiableCredential else { return nil }

    issuedAt = verifiableCredential.refreshedAt ?? entity.createdAt
    available = verifiableCredential.bundleItems.count(where: { !$0.presented })
    total = verifiableCredential.bundleItems.count
  }

  // MARK: Public

  public let issuedAt: Date
  public let available: Int
  public let total: Int
}
