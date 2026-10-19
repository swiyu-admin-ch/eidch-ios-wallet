import BITCredentialShared
import BITEntities
import Foundation

extension ActivityBundleItemEntity {

  public convenience init(_ bundleItem: ActivityBundleItem) {
    self.init()
    payload = bundleItem.payload
    statusListState = BundleItemEntity.CredentialStatus(bundleItem.statusListState)
  }
}
