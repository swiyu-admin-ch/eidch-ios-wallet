#if DEBUG
import Foundation
@testable import BITCore

extension CredentialOffer: Mockable {
  struct Mock {
    static let sample: CredentialOffer = Mocker.decode(fromFile: "oid-credential-offer", bundle: Bundle.module)
  }
}
#endif
