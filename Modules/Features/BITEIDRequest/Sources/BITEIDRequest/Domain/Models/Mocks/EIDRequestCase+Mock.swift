#if DEBUG
import Foundation
@testable import BITTestingCore

extension EIDRequestCase: Mockable {
  struct Mock {
    static let sampleInQueue: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-queue", bundle: Bundle.module)
    static let sampleInQueueNotVerified: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-queue-not-verified", bundle: Bundle.module)
    static let sampleExpired: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-expired", bundle: Bundle.module)
    static let sampleCancelled: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-cancelled", bundle: Bundle.module)
    static let sampleInQueueNoOnlineSessionStart: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-queue-without-online-session-start", bundle: Bundle.module)
    static let sampleAVReady: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-av-ready", bundle: Bundle.module)
    static let sampleAVReadyNotVerified: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-av-ready-not-verified", bundle: Bundle.module)
    static let sampleAVReadyNoOnlineSessionTimeout: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-av-ready-without-online-session-timeout", bundle: Bundle.module)
    static let sampleWithoutState: EIDRequestCase = Mocker.decode(fromFile: "eid-request-case-without-state", bundle: Bundle.module)
  }
}
#endif
