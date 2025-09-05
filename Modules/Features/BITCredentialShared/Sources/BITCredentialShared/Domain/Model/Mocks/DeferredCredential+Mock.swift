#if DEBUG
import Foundation
@testable import BITTestingCore

extension DeferredCredential: Mockable {

  struct Mock {
    static let sample: DeferredCredential = Mocker.decode(fromFile: "deferred-credential", bundle: .module)
  }
}
#endif
