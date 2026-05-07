import BITCore
import Foundation
import Spyable

public typealias CredentialPayload = Data

// MARK: - AnyCredential

@Spyable
public protocol AnyCredential {
  var format: String { get }
  var raw: String { get }
  var issuer: String { get }
  var claims: [any AnyClaim] { get }
  var status: (any AnyStatus)? { get }
  var validFrom: Date? { get }
  var validUntil: Date? { get }
  var vcSchemaId: String { get }

  func getClaimsJSON(_ claimSet: ClaimKind) -> JSON
}
