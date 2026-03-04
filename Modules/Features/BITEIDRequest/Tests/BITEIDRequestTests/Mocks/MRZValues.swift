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
        "PM<<<WALLET<TESTER<A<Q<<HELVETIA<<<<<<<<<<<<",
        "S0A00L12<0<<<9508015X3209251<<<<<<<<<<<<<<04",
      ]
    }

  }
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
