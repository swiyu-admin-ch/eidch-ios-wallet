import Foundation

extension SecKey {

  public func toData() throws -> Data {
    var error: Unmanaged<CFError>?
    guard let data = SecKeyCopyExternalRepresentation(self, &error) as? Data else {
      let errorDescription = (error?.takeRetainedValue() as Error?)?.localizedDescription ?? "Unknown error"
      throw VaultError.toDataFailed(errorDescription)
    }
    return data
  }
}
