#if DEBUG
import Foundation
@testable import BITCore

// MARK: OpenIdConfiguration.Mock

extension OpenIdConfiguration: Mockable {
  struct Mock {
    static let sample: OpenIdConfiguration = Mocker.decode(fromFile: "openid-configuration", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "openid-configuration", bundle: Bundle.module) ?? Data()
  }
}
#endif
