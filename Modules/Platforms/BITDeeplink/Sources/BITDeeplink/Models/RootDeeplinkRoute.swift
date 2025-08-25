import Foundation

public enum RootDeeplinkRoute: DeeplinkRoute, CaseIterable {
  case credentialOffer
  case presentation

  public var schemes: [String] {
    switch self {
    case .credentialOffer:
      ["openid-credential-offer", "swiyu"]
    case .presentation:
      ["openid4vp", "swiyu-verify"]
    }
  }

  public var action: String {
    switch self {
    case .credentialOffer: "" // Credential offer invitation link does not have any action
    case .presentation: "" // Presentation invitation link does not have any action
    }
  }
}
