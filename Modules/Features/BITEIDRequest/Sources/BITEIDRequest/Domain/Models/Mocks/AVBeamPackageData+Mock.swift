#if DEBUG
import Foundation
@testable import BITAVWrapper
@testable import BITCore

extension AVBeamPackageData: Mockable {
  struct Mock {
    nonisolated(unsafe) static let sample: AVBeamPackageData = Mocker.decode(fromFile: "avbeam-package-data", bundle: Bundle.module)
    nonisolated(unsafe) static let sampleExtractedData: Data = Mocker.getData(fromFile: "extracted-data", bundle: Bundle.module) ?? Data()
  }
}
#endif
