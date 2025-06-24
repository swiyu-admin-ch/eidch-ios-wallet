#if DEBUG
// swiftlint:disable force_unwrapping
import Foundation
import RealmSwift
@testable import BITTestingCore

// MARK: - Realm + Mockable

extension Realm {

  public struct Mock {
    public static let migrationTo5URL: URL = Bundle.module.url(forResource: "migrationTo5", withExtension: "realm")!
  }
}
// swiftlint:enable all
#endif
