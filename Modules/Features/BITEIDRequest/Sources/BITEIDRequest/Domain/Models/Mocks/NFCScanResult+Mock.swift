#if DEBUG
import Foundation
@testable import BITCore

extension NFCScanResult: Mockable {
  struct Mock {
    static let sample: NFCScanResult = Mocker.decode(fromFile: "nfc-scan-result", bundle: Bundle.module)
  }
}
#endif
