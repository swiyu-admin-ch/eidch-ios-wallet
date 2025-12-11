import Factory

public enum TrustEnvironment: Equatable {
  case swiyu
  case swiyuInt
  case external

  public init(did: String) {
    if did.firstMatch(of: Container.shared.trustEnvironmentDidRegex()) != nil {
      self = .swiyu
    } else if did.firstMatch(of: Container.shared.demoTrustEnvironmentDidRegex()) != nil {
      self = .swiyuInt
    } else {
      self = .external
    }
  }
}
