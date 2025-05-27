import BITCore
import BITCredentialShared
import BITOpenID
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - GetCredentialIssuerDisplayUseCaseProtocol

@Spyable
protocol GetCredentialIssuerDisplayUseCaseProtocol {
  func execute(for credentialId: UUID, trustStatement: TrustStatement, fallbackDisplay: CredentialIssuerDisplay?) -> CredentialIssuerDisplay?
}

// MARK: - GetCredentialIssuerDisplayUseCase

/// Get `CredentialIssuerDisplay` from `Credential` and `TrustStatement` if present
/// If cannot decode the `TrustStatement`, return credential's `preferredIssuerDisplay`
///
/// Note: Issuer's `image` is always taken from the credential,the trust statement is considered only for the `name`
struct GetCredentialIssuerDisplayUseCase: GetCredentialIssuerDisplayUseCaseProtocol {

  // MARK: Internal

  func execute(for credentialId: UUID, trustStatement: TrustStatement, fallbackDisplay: CredentialIssuerDisplay?) -> CredentialIssuerDisplay? {
    let preferredImage = fallbackDisplay?.image
    let payload = trustStatement.rawPayload
    guard
      let orgName = payload[Self.orgNameKey] as? [String: Any],
      let name = getDisplayForClaim(orgName, with: Self.orgNameKey, in: payload)
    else {
      return fallbackDisplay
    }

    return CredentialIssuerDisplay(name: name, credentialId: credentialId, image: preferredImage)
  }

  // MARK: Private

  private static let orgNameKey = "orgName"
  private static let prefLangKey = "prefLang"

  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]

  private func getDisplayForClaim(_ claim: [String: Any], with key: String, in dictionary: [String: Any]) -> String? {
    for preferredLanguageCode in preferredUserLanguageCodes {
      if let entry = claim.first(where: { $0.key.starts(with: "\(preferredLanguageCode)") }) {
        return entry.value as? String
      }
    }

    if let entry = claim.first(where: { $0.key.starts(with: UserLanguageCode.defaultAppLanguageCode) }) {
      return entry.value as? String
    }

    guard
      let prefLang = dictionary[Self.prefLangKey] as? String,
      let entry = claim.first(where: { $0.key.starts(with: prefLang) })
    else {
      return key
    }

    return entry.value as? String
  }

}
