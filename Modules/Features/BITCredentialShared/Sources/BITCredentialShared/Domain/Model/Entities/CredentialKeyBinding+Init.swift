import BITEntities
import Foundation

extension CredentialKeyBindingEntity {

  // MARK: Lifecycle

  public convenience init(keyBinding: CredentialKeyBinding) {
    self.init()
    id = keyBinding.id
    setValues(from: keyBinding)
  }

  // MARK: Internal

  func setValues(from keyBinding: CredentialKeyBinding) {
    algorithm = keyBinding.algorithm
    bindingType = keyBinding.bindingType.rawValue
    publicKey = keyBinding.publicKey
    privateKey = keyBinding.privateKey
  }
}
