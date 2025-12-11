#if DEBUG
import Foundation
@testable import BITAVWrapper
@testable import BITTestingCore

extension AVBeamPackageResult: Mockable {
  struct Mock {
    static let sample: AVBeamPackageResult = Mocker.decode(fromFile: "avbeam-package-result", bundle: Bundle.module)
  }
}
#endif
