#if DEBUG
import Foundation
@testable import BITCore

extension PresentationErrorRequestBody: Mockable {
  enum Mock {
    static let sampleData: Data = Mocker.getData(fromFile: "presentation-error-request-body", bundle: Bundle.module) ?? Data()
    static func sample() -> PresentationErrorRequestBody {
      Mocker.decode(fromData: sampleData)
    }
  }
}
#endif
