#if DEBUG
import Foundation
@testable import BITAVWrapper
@testable import BITTestingCore

extension AVBeamPackageData: Mockable {
  struct Mock {
    static let sample: AVBeamPackageData = Mocker.decode(fromFile: "avbeam-package-data", bundle: Bundle.module)
    static let sampleExtractedData: Data = Mocker.getData(fromFile: "extracted-data", bundle: Bundle.module) ?? Data()
  }
}
#endif
