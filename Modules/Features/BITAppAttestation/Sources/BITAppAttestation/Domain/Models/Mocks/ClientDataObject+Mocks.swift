#if DEBUG
import Foundation
@testable import BITCore

extension ClientDataObject: Mockable {
  struct Mock {
    static let sample: ClientDataObject = decode(fromFile: "client-data-object", bundle: Bundle.module)
  }
}
#endif
