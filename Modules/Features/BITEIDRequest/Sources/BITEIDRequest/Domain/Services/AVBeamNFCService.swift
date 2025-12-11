import BITAVWrapper
import Spyable

// MARK: - AVBeamNFCServiceProtocol

@Spyable
protocol AVBeamNFCServiceProtocol {
  func fetchResult(for caseId: String, packageResult: AVBeamPackageResult) throws -> NFCScanResult
}

// MARK: - AVBeamNFCService

struct AVBeamNFCService: AVBeamNFCServiceProtocol {

  // MARK: Internal

  enum ExtractedDataIndex: Int {
    case surname = 43
    case givenName = 44
    case passportNumber = 46
    case expirationDate = 188
  }

  func fetchResult(for caseId: String, packageResult: AVBeamPackageResult) throws -> NFCScanResult {
    guard
      let facePicture = packageResult.files.first(where: { file in
        file.type == .jpg && file.description == Self.faceImageFileName
      }) else
    {
      throw NFCScanServiceError.cannotReadPicture
    }

    let extractedData = packageResult.data.extractedData

    guard
      let surname = extractedData[ExtractedDataIndex.surname.rawValue],
      let givenName = extractedData[ExtractedDataIndex.givenName.rawValue],
      let passportNumber = extractedData[ExtractedDataIndex.passportNumber.rawValue],
      let expirationDate = extractedData[ExtractedDataIndex.expirationDate.rawValue]
    else {
      throw NFCScanServiceError.invalidExtractedData
    }

    return NFCScanResult(
      facePicture: facePicture.data,
      surname: surname,
      givenName: givenName,
      passportNumber: passportNumber,
      expirationDate: expirationDate)
  }

  // MARK: Private

  private static let faceImageFileName = "images/id_document_nfc/NFCAvatar.jpg"
}

// MARK: - NFCScanServiceError

enum NFCScanServiceError: Error {
  case invalidExtractedData
  case cannotReadPicture
}
