import Foundation

// MARK: - VcSdJwtCredentialRequestBody

/// The Credential Request object as defined in the OID4VCI specification
/// https://openid.net/specs/openid-4-verifiable-credential-issuance-1_0-13.html#appendix-A.3.4
public struct VcSdJwtCredentialRequestBody: Codable {

  var format: String
  let proof: Proof?
  let vct: String

  enum CodingKeys: String, CodingKey {
    case format
    case proof
    case vct
  }
}

// MARK: VcSdJwtCredentialRequestBody.Proof

extension VcSdJwtCredentialRequestBody {
  struct Proof: Codable {
    let jwt: String
    let proofType: String

    init(jwt: String) {
      self.jwt = jwt
      proofType = Type.jwt.rawValue
    }

    enum CodingKeys: String, CodingKey {
      case jwt
      case proofType = "proof_type"
    }

    private enum `Type`: String, Codable {
      case jwt
    }
  }
}
