import Spyable

// MARK: - PinCodeSecretStoreProtocol

@Spyable
protocol PinCodeSecretStoreProtocol {
  @discardableResult
  func createPinCodeSecretMaterial() throws -> PinCodeSecretMaterial
  func getPinCodeSecretMaterial() throws -> PinCodeSecretMaterial
}
