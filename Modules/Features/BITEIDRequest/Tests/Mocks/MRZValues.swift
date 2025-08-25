import Foundation
@testable import BITEIDRequest

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
extension MRZ {
  enum Mock {

    static var sample: MRZ {
      try! MRZ(values: sampleValues)
    }

    static var sampleValues: [String] {
      [
        "ID<<<I7A<<<<<<7<<<<<<<<<<<<<<<",
        "1001015X3012316<<<<<<<<<<<<<<2",
        "MINDERJAEHRIGE<<ANNETTE<<<<<<<",
      ]
    }

  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
