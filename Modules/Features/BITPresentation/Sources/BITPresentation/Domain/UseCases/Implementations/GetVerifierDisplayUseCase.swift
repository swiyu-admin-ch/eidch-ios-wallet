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
    let logo = getVerifierLogo(from: verifier)
    var name = getVerifierName(from: verifier)
    if
      let trustStatement,
      let data = trustStatement.rawPayload.data(using: .utf8),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let orgName = json[Self.orgNameKey] as? [String: Any],
      let trustedName = getDisplayForClaim(orgName, with: Self.orgNameKey, in: json)
    {
      name = trustedName
    }
    return VerifierDisplay(name: name, logo: logo, trustStatus: trustStatus)
  }

  // MARK: Private

  private static let orgNameKey = "orgName"
  private static let logoUriKey = "logoUri"
  private static let prefLangKey = "prefLang"

  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]
  @Injected(\.credentialDisplayLogoURIDecoder) private var credentialDisplayLogoURIDecoder: CredentialDisplayLogoURIDecoderProtocol

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

  private func getVerifierName(from verifier: Verifier?) -> String? {
    Verifier.LocalizedDisplay.getPreferredDisplay(from: verifier?.clientName, considering: preferredUserLanguageCodes)
  }

  private func getVerifierLogo(from verifier: Verifier?) -> Data? {
    guard let logoUri = Verifier.LocalizedDisplay.getPreferredDisplay(from: verifier?.logoUri, considering: preferredUserLanguageCodes) else {
      return nil
    }
    return credentialDisplayLogoURIDecoder.decode(from: logoUri)
  }
}
