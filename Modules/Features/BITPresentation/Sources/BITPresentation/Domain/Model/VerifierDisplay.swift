import BITCore
import BITCredential
import BITOpenID
import Factory
import Foundation

// MARK: - VerifierDisplay

public struct VerifierDisplay {

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

// MARK: Equatable

extension VerifierDisplay: Equatable {
  public static func == (lhs: VerifierDisplay, rhs: VerifierDisplay) -> Bool {
    lhs.name == rhs.name &&
      lhs.locale == rhs.locale &&
      lhs.logo == rhs.logo &&
      lhs.trustInformation == rhs.trustInformation
  }
}

#if DEBUG
extension VerifierDisplay {
  struct Mock {
    static let sample = VerifierDisplay(name: "Verifier", logo: nil, trustInformation: .Mock.trustedIdentity)
  }
}
#endif
