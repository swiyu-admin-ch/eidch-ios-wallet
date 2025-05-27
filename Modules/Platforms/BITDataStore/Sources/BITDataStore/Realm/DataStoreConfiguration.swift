import Factory
import Foundation
import RealmSwift
import Spyable

// MARK: - DataStoreConfigurationManagerProtocol

@Spyable
public protocol DataStoreConfigurationManagerProtocol {

  var configuration: Realm.Configuration { get }

  func setEncryption(key: Data)

}

// MARK: - DataStoreConfiguration

public class DataStoreConfiguration: DataStoreConfigurationManagerProtocol {

  // MARK: Lifecycle

  init(configuration: Realm.Configuration = Container.shared.realmDataStoreConfiguration()) {
    self.configuration = configuration

    if let url = configuration.fileURL {
      excludeFileFromBackup(at: url)
    }
  }

  // MARK: Public

  public private(set) var configuration: Realm.Configuration

  public func setEncryption(key: Data) {
    var configuration = Container.shared.realmDataStoreConfiguration()
    configuration.encryptionKey = key
    self.configuration = configuration
    Container.shared.realmDataStoreConfiguration.register { configuration }
  }

  // MARK: Internal

  func excludeFileFromBackup(at url: URL) {
    var url = url
    var resourceValues = URLResourceValues()
    resourceValues.isExcludedFromBackup = true
    try? url.setResourceValues(resourceValues)
  }

}
