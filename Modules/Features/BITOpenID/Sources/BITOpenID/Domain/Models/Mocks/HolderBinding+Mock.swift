#if DEBUG
import BITVault
import Foundation

extension HolderBinding {
  public struct Mock {
    public static let attestedHardwareKey = [HolderBinding(keyPair: VaultKeyPair.Mock.ES256, keyAttestationJWS: "attestationJWS")]
    public static let softwareKey = [HolderBinding(keyPair: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()), keyAttestationJWS: nil)]
    public static let batch = [
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256, keyAttestationJWS: "attestationJWS-1"),
      HolderBinding(keyPair: VaultKeyPair.Mock.ES256SavePermanently(id: UUID()), keyAttestationJWS: nil),
    ]
  }
}
#endif
