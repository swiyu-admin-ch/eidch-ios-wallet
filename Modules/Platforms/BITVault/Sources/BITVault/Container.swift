import Factory
import Foundation

extension Container {

  public var supportedKeyStorageSecurityLevel: Factory<[KeyStorageSecurityLevel]> {
    self { [.iso18045EnhancedBasic, .iso18045High] }
  }

  public var keyManager: Factory<KeyManagerProtocol> {
    self { KeyManager() }
  }

  public var secretManager: Factory<SecretManagerProtocol> {
    self { SecretManager() }
  }

}
