public enum IdentityType: String, Codable, Equatable, CaseIterable {
  case identityCard = "SWISS_IDK"
  case passport = "SWISS_PASS"
  case foreignerPermit = "FOREIGNER_PERMIT"
}
