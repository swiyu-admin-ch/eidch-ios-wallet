public enum GovernanceError: String, Error, Equatable {
  case unverifiedActor = "unverified_actor"
  case unknownRegistry = "unknown_registry"
  case unauthorizedIssuance = "unauthorized_issuance"
  case invalidEnvironment = "invalid_environment"
  case unauthorizedVerification = "unauthorized_verification"
}
