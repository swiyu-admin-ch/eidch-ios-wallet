import Factory
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping

final class AVBeamNFCConfiguratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    Container.shared.reset()
    registerMocks()
    configurator = AVBeamNFCConfigurator()
  }

  func testConfigure_success() async throws {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryClosure = { _, _, _ in
      if self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount == 1 {
        XCTAssertEqual(self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name, "mobile-result.json")
      } else if self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount == 2 {
        XCTAssertEqual(self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name, "mobile-result.xml")
      } else if self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount == 3 {
        XCTAssertEqual(self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name, "extractedData.json")
        return self.mockEIDRequestCaseFileExtractedData
      }

      XCTAssertEqual(self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.id, self.mockCaseId)
      XCTAssertEqual(self.eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.category, .documentScan)

      return self.mockEIDRequestCaseFile
    }

    let result = try await configurator.configure(for: mockCaseId, authenticationToken: mockAuthenticationToken)

    XCTAssertEqual(result.authToken, mockAuthenticationToken)
    XCTAssertEqual(result.processId, mockCaseId)
    XCTAssertEqual(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount, 3)
  }

  func testConfigure_getFileFails_throwsError() async throws {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryThrowableError = TestingError.error

    do {
      _ = try await configurator.configure(for: mockCaseId, authenticationToken: mockAuthenticationToken)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  // MARK: Private

  private let mockCaseId = "mockCaseId"
  private let mockAuthenticationToken = "mockAuthenticationToken"
  private let mockEIDRequestCaseFile = EIDRequestCaseFile.Mock.sample
  private let mockAvBeamPackageResult: AVBeamPackageResult = .Mock.sample
  private let mockEIDRequestCaseFileExtractedData = EIDRequestCaseFile(fileName: "sample", mime: .json, data: AVBeamPackageData.Mock.sampleExtractedData, category: .documentScan)

  private var configurator: AVBeamNFCConfigurator!
  private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy!

  private func registerMocks() {
    eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    Container.shared.eIDRequestCaseRepository.register { self.eIDRequestCaseRepository }
  }

}
