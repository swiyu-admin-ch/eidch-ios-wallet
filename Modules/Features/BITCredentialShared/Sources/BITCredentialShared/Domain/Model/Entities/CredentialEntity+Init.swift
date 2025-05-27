import BITEntities
import Foundation

extension CredentialEntity {

  // MARK: Lifecycle

  public convenience init(credential: Credential) {
    self.init()
    id = credential.id
    setValues(from: credential)

    let sortedClaims = credential.claims.sorted(by: { $0.order < $1.order })
    claims.insert(contentsOf: sortedClaims.map { CredentialClaimEntity(claim: $0) }, at: 0)
    issuerDisplays.append(objectsIn: credential.issuerDisplays.map { CredentialIssuerDisplayEntity($0) })
    displays.append(objectsIn: credential.displays.map { CredentialDisplayEntity(display: $0) })
  }

  // MARK: Public

  public func setValues(from credential: Credential) {
    status = credential.status.rawValue
    keyBindingIdentifier = credential.keyBindingIdentifier
    keyBindingAlgorithm = credential.keyBindingAlgorithm
    payload = credential.payload
    format = credential.format
    issuer = credential.issuer
    validFrom = credential.validFrom
    validUntil = credential.validUntil
    createdAt = credential.createdAt
    updatedAt = credential.updatedAt
  }

}
