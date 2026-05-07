#if DEBUG
import Foundation
@testable import BITAVWrapper
@testable import BITCore

extension AVBeamPackageResult: Mockable {

  struct Mock {

    static var sample = Self.with()

    static var defaultExtractedData: [Int: String] = [
      1: "name",
      43: "MINDERJAEHRIGE",
      44: "ANNETTE",
      46: "TEST NUMBER",
      188: "10-10-2022",
      64: "ID<<<I7A<<<<<<7<<<<<<<<<<<<<<<",
      65: "1001015X3012316<<<<<<<<<<<<<<2",
      66: "MINDERJAEHRIGE<<ANNETTE<<<<<<<",
    ]

    static var mrzData: [Int: String] = [
      64: "ID<<<I7A<<<<<<7<<<<<<<<<<<<<<<",
      65: "1001015X3012316<<<<<<<<<<<<<<2",
      66: "MINDERJAEHRIGE<<ANNETTE<<<<<<<",
    ]

    static func with(
      extractedData: [Int: String] = Self.defaultExtractedData,
      extractedDataDrivingLicense: [Int: String]? = nil,
      errorType: AVBeamPackageErrorType = .none,
      errorCode: AVBeamError = .none,
      errorCodes: [AVBeamError] = [],
      nfcError: AVBeamError = .none,
      status: AVBeamNotification = .initialized,
      activeScenario: AVBeamScenarioStep = .none,
      files: [AVBeamFile] = [
        AVBeamFile(type: .jpg, description: "Document front image", data: Data()),
        AVBeamFile(type: .jpg, description: "Document back image", data: Data()),
      ])
      -> AVBeamPackageResult
    {
      let data = AVBeamPackageData(
        extractedData: extractedData,
        extractedDataDrivingLicense: extractedDataDrivingLicense,
        errorType: errorType,
        errorCode: errorCode,
        errorCodes: errorCodes,
        nfcError: nfcError,
        status: status,
        activeScenario: activeScenario,
        files: files)

      return AVBeamPackageResult(data: data, files: files)
    }

  }
}
#endif
