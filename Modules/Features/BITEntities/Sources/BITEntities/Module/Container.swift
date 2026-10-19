import Factory
import Foundation

extension Container {

  public var databaseCleaner: Factory<DatabaseCleanerProtocol> {
    self { DatabaseCleaner() }
  }

}
