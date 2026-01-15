public enum ActorCompliance: Equatable {
  case compliant
  case notCompliant(LocalizedNonComplianceReason)
}
