#if DEBUG
import Foundation
@testable import BITTestingCore

extension VersionEnforcement: Mockable {
  public struct Mock {
    static let highMinVersionSample: VersionEnforcement = Mocker.decode(fromFile: "high-min-version-sample", bundle: .module)
    static let noMinVersionSample: VersionEnforcement = Mocker.decode(fromFile: "no-min-version-sample", bundle: .module)
    static let maxVersionSample: VersionEnforcement = Mocker.decode(fromFile: "max-version-sample", bundle: .module)
    static let lowPrioritySample: VersionEnforcement = Mocker.decode(fromFile: "low-priority-sample", bundle: .module)
    static let otherPlatformSample: VersionEnforcement = Mocker.decode(fromFile: "other-platform-sample", bundle: .module)
    static let sample: VersionEnforcement = Mocker.decode(fromFile: "sample", bundle: .module)
    static let sampleData: Data = Mocker.getData(fromFile: "version-enforcement-response", bundle: .module) ?? Data()
    static let noDisplaysSample: VersionEnforcement = Mocker.decode(fromFile: "no-displays-sample", bundle: .module)
  }
}
#endif
