#if DEBUG
import Foundation
@testable import BITCore

extension JSON: Mockable {
  enum Mock {
    static let credentialNested: JSON = create(from: "credential-nested")
    static let credentialNestedWithClaimNotInOCA: JSON = create(from: "credential-nested-with-claim-not-in-oca")
    static let credentialOcaOnlyClusters: JSON = create(from: "credential-oca-only-clusters")
    static let credentialNestedOneCaptureBase: JSON = create(from: "credential-nested-one-capture-base")
    static let credentialArrayObjectNestedClaim: JSON = create(from: "credential-array-object-nested-claim")
    static let credentialComplex: JSON = create(from: "credential-complex") // https://www.rfc-editor.org/rfc/rfc9901.html#name-complex-structured-sd-jwt

    private static func create(from file: String) -> JSON {
      let data = getData(fromFile: file, bundle: Bundle.module) ?? Data()
      return (try? JSONSerialization.jsonObject(with: data) as? JSON) ?? [:]
    }
  }
}

#endif
