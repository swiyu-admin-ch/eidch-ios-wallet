import Foundation

// MARK: - CredentialFormat

/// Represents the credential formats supported according to the OpenID for Verifiable Credential Issuance specification.
///
/// - `vcSdJwt`: Represents a Verifiable Credential in SD-JWT-based Verifiable Credentials (SD-JWT VC) format
public enum CredentialFormat: String, Codable {
  case vcSdJwt = "vc+sd-jwt"
  case dcSdJwt = "dc+sd-jwt"
}

// MARK: - CredentialFormatError

public enum CredentialFormatError: Error {
  case formatNotSupported
}
