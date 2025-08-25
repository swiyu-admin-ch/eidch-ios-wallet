import BITAVWrapper
import Foundation

extension MRZ {
  public init(from package: AVBeamPackageResult) throws {
    guard let packageData = package.data.getExtractedData() else {
      throw MRZError.missingPackageData
    }

    let fields: [AVBeamContentField] = [.mrzLine1, .mrzLine2, .mrzLine3]
    let extractedLines = fields
      .compactMap { packageData.object(forKey: $0.rawValue) as? String }
      .filter { !$0.isEmpty }

    try self.init(values: extractedLines)
  }
}
