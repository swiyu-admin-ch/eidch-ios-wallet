import BITEntities
import Foundation

extension CredentialKeyBindingEntity {

  public convenience init(keyBinding: KeyBinding) {
    self.init()
    id = keyBinding.id
    algorithm = keyBinding.algorithm
    bindingType = keyBinding.bindingType.rawValue
    publicKey = keyBinding.publicKey
    privateKey = keyBinding.privateKey
  }
}
