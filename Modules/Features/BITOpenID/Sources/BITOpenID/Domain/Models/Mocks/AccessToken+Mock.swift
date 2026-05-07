#if DEBUG
import Foundation
@testable import BITCore

// MARK: AccessToken.Mock

extension AccessToken: Mockable {
  struct Mock {
    static let sample: AccessToken = Mocker.decode(fromFile: "access-token", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "access-token", bundle: Bundle.module) ?? Data()

    static let sampleWithoutTokenTypeData: Data = Mocker.getData(fromFile: "access-token-unknown-token-type", bundle: Bundle.module) ?? Data()
  }
}
#endif
