import Foundation

// MARK: - InvitationType

public enum InvitationType {
  case credentialOffer
  case presentation
}

extension InvitationType {
  var schemes: [String] {
    switch self {
    case .credentialOffer:
      ["openid-credential-offer", "swiyu"]
    case .presentation:
      ["https", "openid4vp", "swiyu-verify"]
    }
  }
}
