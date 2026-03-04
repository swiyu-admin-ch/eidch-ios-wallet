import BITVault

public struct HolderBindingContext: Equatable {

  public init(keyPair: VaultKeyPair, keyAttestationJWS: String? = nil) {
    self.keyPair = keyPair
    self.keyAttestationJWS = keyAttestationJWS
  }

  public let keyPair: VaultKeyPair
  public let keyAttestationJWS: String?
}
