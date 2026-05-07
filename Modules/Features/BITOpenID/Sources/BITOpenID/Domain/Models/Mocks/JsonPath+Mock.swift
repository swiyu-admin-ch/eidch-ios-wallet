#if DEBUG
import Foundation
@testable import BITCore

// MARK: String.Mock

extension String {
  struct Mock {
    static let jsonPathsSample: String = Mocker.getString(fromFile: "json-paths-sample", ofType: "json", bundle: Bundle.module)
  }
}

#endif
