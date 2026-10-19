import BITCredentialShared
import Foundation

// MARK: - ActivityBundleItem

public struct ActivityBundleItem: Codable, Equatable, Hashable, Sendable {

  // MARK: Lifecycle

  public init(payload: Data? = nil, statusListState: CredentialStatus) {
    self.payload = payload
    self.statusListState = statusListState
  }

  // MARK: Public

  public var payload: Data?
  public var statusListState: CredentialStatus
}

extension ActivityBundleItem {

  public init(_ bundleItem: BundleItem) {
    self.init(payload: bundleItem.payload, statusListState: bundleItem.status)
  }
}
