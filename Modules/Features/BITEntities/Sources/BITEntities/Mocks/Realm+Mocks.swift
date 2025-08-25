#if DEBUG
// swiftlint:disable force_unwrapping
import Foundation
import RealmSwift
@testable import BITTestingCore

// MARK: - Realm + Mockable

extension Realm {

  public struct Mock {
    public static let version4Snapshot: URL = Bundle.module.url(forResource: "version4Snapshot", withExtension: "realm")!
    public static let version5Snapshot: URL = Bundle.module.url(forResource: "version5Snapshot", withExtension: "realm")!
  }
}
// swiftlint:enable all
#endif
