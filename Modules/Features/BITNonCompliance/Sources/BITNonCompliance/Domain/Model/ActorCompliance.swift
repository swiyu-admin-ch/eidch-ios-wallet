// MARK: - ActorCompliance

public enum ActorCompliance: Equatable {
  case compliant
  case notCompliant(LocalizedNonComplianceReason)
}

// MARK: Hashable

extension ActorCompliance: Hashable {
  public func hash(into hasher: inout Hasher) {
    switch self {
    case .compliant: break
    case .notCompliant(let localizedNonComplianceReason):
      hasher.combine(localizedNonComplianceReason)
    }
  }
}
