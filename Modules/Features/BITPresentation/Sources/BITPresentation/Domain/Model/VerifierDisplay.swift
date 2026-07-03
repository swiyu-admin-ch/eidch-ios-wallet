import BITCore
import BITCredential
import Factory
import Foundation

// MARK: - VerifierDisplay

struct VerifierDisplay: Equatable {

  init(name: String?, locale: UserLocale? = nil, logo: Data?, trustInformation: TrustInformation) {
    self.name = name
    self.locale = locale
    self.logo = logo
    self.trustInformation = trustInformation
  }

  // MARK: Internal

  var name: String?
  var locale: UserLocale?
  var logo: Data?
  var trustInformation: TrustInformation

}

#if DEBUG
extension VerifierDisplay {
  struct Mock {
    static let sample = VerifierDisplay(name: "Verifier", logo: nil, trustInformation: .Mock.trustedIdentity)
  }
}
#endif
