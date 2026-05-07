#if DEBUG
import Foundation
@testable import BITCore

extension AppAttestedKey: Mockable {
  struct Mock {
    static let sample: AppAttestedKey = decode(fromFile: "attested-key", bundle: Bundle.module)
  }
}
#endif
