import BITCrypto
import BITLocalAuthentication
import Security
import Spyable

// MARK: - AppAttestationKeyRepositoryProtocol

@Spyable
public protocol AppAttestationKeyRepositoryProtocol {
  func getAttestionKey(for attestKey: AppAttestationKey) throws -> SecKey
  func createAttestationKey(for attestKey: AppAttestationKey, with context: LAContextProtocol) throws -> SecKey
}

// MARK: - AppAttestationKey

public enum AppAttestationKey {
  case clientAttestation
  case keyAttestation
}
