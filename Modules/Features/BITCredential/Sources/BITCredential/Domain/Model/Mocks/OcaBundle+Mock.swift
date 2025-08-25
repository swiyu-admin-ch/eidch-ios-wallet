#if DEBUG
import Foundation
@testable import BITOca
@testable import BITTestingCore

extension OcaBundle {
  enum Mock {
    static let oneAttribute = create(from: "oca-bundle-one-attribute")

    // swiftlint:disable force_try
    static func create(from file: String) -> OcaBundle {
      let data = getData(fromFile: file, bundle: Bundle.module) ?? Data()
      return try! OcaBundler().createOcaBundle(data)
    }
    // swiftlint:enable force_try
  }
}

#endif
