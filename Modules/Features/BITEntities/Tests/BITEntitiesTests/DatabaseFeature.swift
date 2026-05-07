import Foundation

// MARK: - DatabaseFeature

enum DatabaseFeature {
  case rawCredentialData
  case cluster
  case deferredCredential
  case none

  // MARK: Internal

  func getKeyBindingCount() -> Int {
    switch self {
    case .cluster,
         .deferredCredential,
         .rawCredentialData: 3
    case .none: 4
    }
  }

  func getRawCredentialDataCount() -> Int {
    switch self {
    case .rawCredentialData: 0
    case .cluster,
         .deferredCredential: 3
    case .none: 4
    }
  }

  func getDeferredCredentialCount() -> Int {
    switch self {
    case .cluster,
         .deferredCredential,
         .rawCredentialData: 0
    case .none: 1
    }
  }

  func getCredentialIssuerDisplayCount() -> Int {
    switch self {
    case .cluster,
         .deferredCredential,
         .rawCredentialData: 12
    case .none: 14
    }
  }

  func getCredentialDisplayCount() -> Int {
    switch self {
    case .cluster,
         .deferredCredential,
         .rawCredentialData: 12
    case .none: 14
    }
  }

  func getCredentialClaimClusterDisplayCount() -> Int {
    switch self {
    case .cluster,
         .rawCredentialData: 0
    case .deferredCredential,
         .none: 5
    }
  }
}
