import BITCore
import BITCredential
import BITNonCompliance
import Factory
import Foundation

// MARK: - VerifierDisplay

struct VerifierDisplay: Equatable {

  // MARK: Lifecycle

  init(
    name: String?, locale: UserLocale? = nil, logo: Data?, trustInformation: TrustInformation,
    actorCompliance: ActorCompliance = .compliant)
  {
    self.name = name
    self.locale = locale
    self.logo = logo
    self.trustInformation = trustInformation
    self.actorCompliance = actorCompliance
  }

  // MARK: Internal

  var name: String?
  var locale: UserLocale?
  var logo: Data?
  var trustInformation: TrustInformation
  var actorCompliance: ActorCompliance

}

#if DEBUG
extension VerifierDisplay {
  struct Mock {
    static let sample = VerifierDisplay(
      name: "Verifier", logo: nil, trustInformation: .Mock.trustedIdentity)
  }
}
#endif
