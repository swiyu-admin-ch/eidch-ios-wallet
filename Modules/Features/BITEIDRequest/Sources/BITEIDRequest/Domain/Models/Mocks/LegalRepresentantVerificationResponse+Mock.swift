#if DEBUG
import Foundation
@testable import BITTestingCore

extension LegalRepresentantVerificationResponse: Mockable {
  struct Mock {
    static let sample: LegalRepresentantVerificationResponse = Mocker.decode(fromFile: "legal-representant-verification", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "legal-representant-verification", bundle: Bundle.module) ?? Data()
  }
}
#endif
