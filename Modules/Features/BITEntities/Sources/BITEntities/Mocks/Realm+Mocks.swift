#if DEBUG
// swiftlint:disable force_unwrapping
import Foundation
import RealmSwift
@testable import BITCore

// MARK: - Realm + Mockable

extension Realm {

  public struct Mock {
    public static let version1Snapshot: URL = Bundle.module.url(forResource: "version1Snapshot", withExtension: "realm")!
    public static let version4Snapshot: URL = Bundle.module.url(forResource: "version4Snapshot", withExtension: "realm")!
    public static let version5Snapshot: URL = Bundle.module.url(forResource: "version5Snapshot", withExtension: "realm")!
    public static let version10Snapshot: URL = Bundle.module.url(forResource: "version10Snapshot", withExtension: "realm")!
    public static let version14Snapshot: URL = Bundle.module.url(forResource: "version14Snapshot", withExtension: "realm")!
    public static let version16Snapshot: URL = Bundle.module.url(forResource: "version16Snapshot", withExtension: "realm")!
    public static let version23Snapshot: URL = Bundle.module.url(forResource: "version23Snapshot", withExtension: "realm")!
    public static let version26Snapshot: URL = Bundle.module.url(forResource: "version26Snapshot", withExtension: "realm")!
  }
}
// swiftlint:enable all
#endif
