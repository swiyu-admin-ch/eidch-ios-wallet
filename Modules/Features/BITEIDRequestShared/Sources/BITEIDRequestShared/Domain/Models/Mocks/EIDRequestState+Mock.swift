#if DEBUG
import Foundation
@testable import BITCore

extension EIDRequestState: Mockable {
  struct Mock {
    static let sample: EIDRequestState = Mocker.decode(fromFile: "eid-request-case-state", bundle: Bundle.module)
  }
}
#endif
