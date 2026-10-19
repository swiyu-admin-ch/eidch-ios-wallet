import BITLocalAuthentication
import Foundation
import Spyable

@Spyable
protocol UniquePassphraseRepositoryProtocol: Sendable {
  func saveUniquePassphrase(_ data: Data, forAuthMethod authMethod: AuthMethod, inContext context: LAContextProtocol) throws
  func hasUniquePassphraseSaved(forAuthMethod authMethod: AuthMethod) -> Bool
  func getUniquePassphrase(forAuthMethod authMethod: AuthMethod, inContext context: LAContextProtocol) throws -> Data
  func deleteBiometricUniquePassphrase() throws
}
