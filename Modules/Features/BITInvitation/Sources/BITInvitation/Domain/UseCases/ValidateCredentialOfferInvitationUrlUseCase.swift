import BITCore
import BITCredential
import BITOpenID
import Foundation
import OSLog

// MARK: - ValidateCredentialOfferInvitationUrlError

enum ValidateCredentialOfferInvitationUrlError: Error {
  case missingUrlParameters
  case unexpectedScheme
  case missingExpectedOfferParameter
  case cannotDecodeParameter
}

// MARK: - ValidateCredentialOfferInvitationUrlUseCase

public struct ValidateCredentialOfferInvitationUrlUseCase: ValidateCredentialOfferInvitationUrlUseCaseProtocol {

  // MARK: Public

  public func execute(_ url: URL) throws -> CredentialOffer {
    guard let scheme = url.scheme, InvitationType.credentialOffer.schemes.contains(scheme) else { throw ValidateCredentialOfferInvitationUrlError.unexpectedScheme }
    guard let parameters = url.queryParameters else { throw ValidateCredentialOfferInvitationUrlError.missingUrlParameters }
    if let credentialEncodedParameter = parameters["credential_offer"] {
      return try createCredentialOffer(from: credentialEncodedParameter)
    }
    throw ValidateCredentialOfferInvitationUrlError.missingExpectedOfferParameter
  }

  // MARK: Private

  private func createCredentialOffer(from rawInvitation: String) throws -> CredentialOffer {
    guard
      let rawInvitation = rawInvitation
        .removingPercentEncoding else { throw ValidateCredentialOfferInvitationUrlError.cannotDecodeParameter }
    let credentialInvitation = rawInvitation.replacingOccurrences(of: "+", with: "")
    guard let data = credentialInvitation.data(using: .utf8) else {
      throw ValidateCredentialOfferInvitationUrlError.cannotDecodeParameter
    }
    return try JSONDecoder().decode(CredentialOffer.self, from: data)
  }

}
