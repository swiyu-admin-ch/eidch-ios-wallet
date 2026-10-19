import BITCore

// MARK: - ActorCompliance

public enum ActorCompliance: Equatable, Sendable {
  case compliant
  case notCompliant(LocalizedDisplay<String>?)
}

// MARK: Hashable

extension ActorCompliance: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .compliant: break
    case .notCompliant(let reason):
      hasher.combine(reason)
    }
  }
}
