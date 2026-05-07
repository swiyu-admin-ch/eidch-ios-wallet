import BITEntities

extension BundleItemEntity {

  convenience init(_ bundleItem: BundleItem) {
    self.init()

    id = bundleItem.id
    payload = bundleItem.payload
    status = BundleItemEntity.CredentialStatus(bundleItem.status)
    presented = bundleItem.presented
    keyBinding = bundleItem.keyBinding.flatMap(CredentialKeyBindingEntity.init)
  }
}
