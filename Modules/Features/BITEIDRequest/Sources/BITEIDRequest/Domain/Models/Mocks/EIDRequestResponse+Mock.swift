#if DEBUG
import Foundation
@testable import BITCore

extension EIDRequestResponse: Mockable {
  struct Mock {
    static let sample: EIDRequestResponse = Mocker.decode(fromFile: "eid-request-response", dateFormatter: .formatted(DateFormatter(format: "YYYY-MM-dd")), bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "eid-request-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
