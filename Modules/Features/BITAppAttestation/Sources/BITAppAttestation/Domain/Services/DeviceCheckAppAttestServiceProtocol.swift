import DeviceCheck
import Spyable

// MARK: - DeviceCheckAppAttestServiceProtocol

@Spyable
public protocol DeviceCheckAppAttestServiceProtocol {
  func generateKey() async throws -> String
  func attestKey(_ keyId: String, clientDataHash: Data) async throws -> Data
  func generateAssertion(_ keyId: String, clientDataHash: Data) async throws -> Data

  var isSupported: Bool { get }
}

// MARK: - DCAppAttestService + DeviceCheckAppAttestServiceProtocol

/// Extends DeviceCheck `DCAppAttestService` to conform to the managed `DeviceCheckAppAttestServiceProtocol`
/// in order to enable dependency injection and facilitate unit testing.
extension DCAppAttestService: DeviceCheckAppAttestServiceProtocol { }
