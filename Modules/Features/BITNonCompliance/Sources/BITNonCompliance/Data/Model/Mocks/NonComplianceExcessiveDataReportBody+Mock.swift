#if DEBUG
import Foundation
@testable import BITActivity
@testable import BITCore
@testable import BITCredentialShared

extension NonComplianceExcessiveDataReportBody: Mockable {
  public struct Mock {
    public static let `default` = NonComplianceExcessiveDataReportBody(
      description: String(repeating: "x", count: 20),
      email: "admin@example.com",
      language: "en",
      metadata: NonComplianceExcessiveDataReportBody.Metadata(
        verifierDid: "did:example:verifier",
        verifierUrl: "https://example.com",
        presentationActionCreatedAt: Date(timeIntervalSince1970: 0),
        presentedCredentialIssuerDid: "did:example:issuer",
        presentationRequestJwt: "jwt",
        presentationRequestFields: [
          NonComplianceExcessiveDataReportBody.Field(name: "field", constraint: "const"),
        ]))
  }
}
#endif
