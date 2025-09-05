import BITCore
import BITCredentialShared
import BITOpenID
import Factory
import Foundation

/// Get `VerifierDisplay` from `Verifier` and `TrustStatement` if present
/// If we cannot decode the `TrustStatement`, return the localized verifier display from the verifier's client metadata
///
/// Note: Verifier's `logo` is always taken from the verifier's client metadata, the trust statement is considered only for the `name`
struct GetVerifierDisplayUseCase: GetVerifierDisplayUseCaseProtocol {

  // MARK: Internal

  func execute(for verifier: Verifier?, trustStatement: TrustStatement?) -> VerifierDisplay? {
    let trustStatus: TrustStatus = trustStatement != nil ? .verified : .unverified
    let logo = verifier?.logoUri?.getPreferredDisplay(considering: preferredUserLanguageCodes)
    let name = if let trustStatement {
      trustStatement.getLocalizedEntityName(considering: preferredUserLanguageCodes)
    } else {
      verifier?.clientName?.getPreferredDisplay(considering: preferredUserLanguageCodes)
    }
    return VerifierDisplay(name: name, logo: logo?.dataURLData, trustStatus: trustStatus)
  }

  // MARK: Private

  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
}
