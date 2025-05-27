#if DEBUG
import Foundation
@testable import BITTestingCore

extension OcaBundle: Mockable {
  enum Mock {
    static let elfa: OcaBundle = decode(fromFile: "oca-bundle-elfa", bundle: Bundle.module)
    static let elfaData: Data = getData(fromFile: "oca-bundle-elfa", bundle: Bundle.module) ?? Data()
    static let simpleSample: OcaBundle = decode(fromFile: "oca-bundle-simple-sample", bundle: Bundle.module)
    static let nested: OcaBundle = decode(fromFile: "oca-bundle-nested", bundle: Bundle.module)
    static let emptyLabelOverlay: OcaBundle = decode(fromFile: "oca-empty-label-overlay", bundle: Bundle.module)
  }
}

#endif
