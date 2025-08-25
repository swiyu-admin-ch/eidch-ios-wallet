#if DEBUG
import BITVault
import Foundation

extension HolderBindingContext {
  public struct Mock {
    public static let attestedHardwareKey = HolderBindingContext(keyPair: VaultKeyPair.Mock.ES256, keyAttestationJWS: "attestationJWS")
    public static let softwareKey = HolderBindingContext(keyPair: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()), keyAttestationJWS: nil)
  }
}
#endif
