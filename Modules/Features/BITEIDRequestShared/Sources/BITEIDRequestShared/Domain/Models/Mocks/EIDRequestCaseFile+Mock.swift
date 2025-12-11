#if DEBUG
import Foundation
@testable import BITTestingCore

extension EIDRequestCaseFile {

  public enum Mock {
    static let sample = EIDRequestCaseFile(fileName: "sample.jpg", mime: .jpg, data: Data(), category: .documentScan)
    static let sampleArray: [EIDRequestCaseFile] = [
      EIDRequestCaseFile(fileName: "sample.jpg", mime: .jpg, data: Data(), category: .documentScan),
      EIDRequestCaseFile(fileName: "sample2.jpg", mime: .jpg, data: Data(), category: .documentScan),
      EIDRequestCaseFile(fileName: "sample3.jpg", mime: .jpg, data: Data(), category: .documentScan),
    ]

    static func sample(name: String = "sample.jpg", category: Category = .documentScan) -> EIDRequestCaseFile {
      EIDRequestCaseFile(fileName: name, mime: .jpg, data: Data(), category: category)
    }

  }

}
#endif
