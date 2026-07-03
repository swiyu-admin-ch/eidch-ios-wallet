import BITEntities

extension DPoPBindingEntity {

  // MARK: Lifecycle

  public convenience init(_ keyBinding: KeyBinding) {
    self.init()
    id = keyBinding.id
    setValues(from: keyBinding)
  }

  // MARK: Internal

  func setValues(from keyBinding: KeyBinding) {
    algorithm = keyBinding.algorithm
    bindingType = keyBinding.bindingType.rawValue
    publicKey = keyBinding.publicKey
    privateKey = keyBinding.privateKey
  }
}
