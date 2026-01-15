import Factory
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping init_with_name

final class AVBeamNFCServiceTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.reset()
    service = AVBeamNFCService()
  }

  func testFetchResult_success() throws {
    let result = try service.fetchResult(for: mockCaseId, packageResult: .Mock.with(
      extractedData: AVBeamPackageResult.Mock.defaultExtractedData,
      files: [.init(type: .jpg, description: "images/id_document_nfc/NFCAvatar.jpg", data: Data())]))

    XCTAssertEqual(result.facePicture, mockAvBeamPackageResult.files.first?.data)
    XCTAssertEqual(result.surname, mockAvBeamPackageResult.data.extractedData[AVBeamNFCService.ExtractedDataIndex.surname.rawValue])
    XCTAssertEqual(result.givenName, mockAvBeamPackageResult.data.extractedData[AVBeamNFCService.ExtractedDataIndex.givenName.rawValue])
    XCTAssertEqual(result.passportNumber, mockAvBeamPackageResult.data.extractedData[AVBeamNFCService.ExtractedDataIndex.passportNumber.rawValue])
    XCTAssertEqual(result.expirationDate, mockAvBeamPackageResult.data.extractedData[AVBeamNFCService.ExtractedDataIndex.expirationDate.rawValue])
  }

  func testFetchResult_withNoPicture_throwsError() throws {
    let mockAvBeamPackageResultWithoutPicture = AVBeamPackageResult(data: .Mock.sample, files: [])

    do {
      _ = try service.fetchResult(for: mockCaseId, packageResult: mockAvBeamPackageResultWithoutPicture)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? NFCScanServiceError, .cannotReadPicture)
    }
  }

  // MARK: Private

  private let mockCaseId = "mockCaseId"
  private let mockAvBeamPackageResult: AVBeamPackageResult = .Mock.sample

  private var service: AVBeamNFCService!

}
