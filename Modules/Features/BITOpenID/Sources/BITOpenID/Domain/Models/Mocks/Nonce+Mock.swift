// swiftlint: disable implicitly_unwrapped_optional force_try
#if DEBUG
import Foundation
@testable import BITTestingCore

// MARK: Nonce.Mock

extension Nonce: Mockable {
  struct Mock {
    static let `default` = Nonce(cNonce: "502b8c3c-5343-4e13-8a72-963fc53d2ea1")
    static var defaultData: Data { try! JSONEncoder().encode(Mock.default) }
  }
}
#endif
