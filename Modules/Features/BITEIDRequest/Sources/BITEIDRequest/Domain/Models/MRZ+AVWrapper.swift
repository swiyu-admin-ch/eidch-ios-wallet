import BITAVWrapper
import Foundation

extension MRZ {
  public init(from package: AVBeamPackageResult) throws {
    let fields: [AVBeamContentField] = [.mrzLine1, .mrzLine2, .mrzLine3]
    let extractedLines = fields
      .compactMap { package.data.extractedData[$0.rawValue] as? String }
      .filter { !$0.isEmpty }

    try self.init(values: extractedLines)
  }
}
