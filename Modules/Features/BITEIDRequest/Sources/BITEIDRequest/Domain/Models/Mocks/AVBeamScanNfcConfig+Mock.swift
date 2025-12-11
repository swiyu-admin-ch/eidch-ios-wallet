#if DEBUG
import Foundation
@testable import BITAVWrapper
@testable import BITTestingCore

extension AVBeamScanNfcConfig: Mockable {
  struct Mock {
    static let sample: AVBeamScanNfcConfig = Mocker.decode(fromFile: "avbeam-scan-nfc-config", bundle: Bundle.module)
  }
}
#endif
