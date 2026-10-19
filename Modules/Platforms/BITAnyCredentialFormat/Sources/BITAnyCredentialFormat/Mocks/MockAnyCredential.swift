#if DEBUG
import BITClaimsPathPointer
import BITCore
import Foundation

/// VcSdJwt mocks represented as an AnyCredential type created from the CredentialPayload.Mock.default value
public struct MockAnyCredential: AnyCredential, Changeable {

  // MARK: Lifecycle

  init(payload: Data = CredentialPayload.Mock.default, swissProfileVersion: String? = "1.0.0") {
    self.payload = payload
    self.swissProfileVersion = swissProfileVersion
  }

  // MARK: Public

  public var format = CredentialFormat.vcSdJwt

  public var issuer = "did:tdw:mock=:mock.swiyu.admin.ch:api:v1:did:25c2db14-8dc8-4e58-933f-070048079748"

  public var swissProfileVersion: String?

  public var raw: String {
    String(data: payload, encoding: .utf8) ?? UUID().uuidString
  }

  public var status: (any AnyStatus)? {
    nil
  }

  public var validFrom: Date? {
    nil
  }

  public var validUntil: Date? {
    nil
  }

  public var vcSchemaId: String {
    "vcSchemaId"
  }

  public func getClaimsJSON(_ claimSet: ClaimKind) -> JSON {
    [:]
  }

  public func getPresentingPaths(for paths: [ClaimsPathPointer]) -> [ClaimsPathPointer] {
    []
  }

  // MARK: Internal

  let payload: Data
}
#endif
