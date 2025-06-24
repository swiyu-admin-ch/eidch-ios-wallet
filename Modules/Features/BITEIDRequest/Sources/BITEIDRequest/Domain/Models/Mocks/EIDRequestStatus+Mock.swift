#if DEBUG
import Foundation
@testable import BITTestingCore

extension EIDRequestStatus: Mockable {
  struct Mock {

    // MARK: Internal

    static let inQueueSample: EIDRequestStatus = Mocker.decode(fromFile: "eid-request-status-queue", bundle: Bundle.module)
    static let readyForAVSample: EIDRequestStatus = Mocker.decode(fromFile: "eid-request-status-ready", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "eid-request-status-queue", bundle: Bundle.module) ?? Data()
  }
}
#endif
