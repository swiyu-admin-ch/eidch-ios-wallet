import Foundation

// MARK: - NonComplianceExcessiveDataReportBody

struct NonComplianceExcessiveDataReportBody: Encodable {

  // MARK: - Metadata

  struct Metadata: Encodable {
    let verifierDid: String?
    let verifierUrl: String?
    let presentationActionCreatedAt: Date?
    let presentedCredentialIssuerDid: String?
    let presentationRequestJwt: String?
    let presentationRequestFields: [Field]

    enum CodingKeys: String, CodingKey {
      case verifierDid = "verifier_did"
      case verifierUrl = "verifier_url"
      case presentationActionCreatedAt = "presentation_action_created_at"
      case presentedCredentialIssuerDid = "presented_credential_issuer_did"
      case presentationRequestJwt = "presentation_request_jwt"
      case presentationRequestFields = "presentation_request_fields"
    }
  }

  // MARK: - Field

  struct Field: Encodable, Equatable {
    let name: String
    let constraint: String?
  }

  let type = NonComplianceCategory.excessiveDataRequest
  let description: String
  let email: String?
  let metadata: Metadata
}
