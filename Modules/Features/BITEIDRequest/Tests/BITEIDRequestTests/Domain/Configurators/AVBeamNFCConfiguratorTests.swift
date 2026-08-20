import Factory
import Testing
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITEIDRequestShared
@testable import BITTestingCore

struct AVBeamNFCConfiguratorTests {

  // MARK: Lifecycle

  init() {
    let eIDRequestCaseRepository = EIDRequestCaseRepositoryProtocolSpy()
    self.eIDRequestCaseRepository = eIDRequestCaseRepository
    Container.shared.eIDRequestCaseRepository.register { eIDRequestCaseRepository }

    configurator = AVBeamNFCConfigurator()
  }

  // MARK: Internal

  @Test
  func configure_success() async throws {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryClosure = { _, _, _ in
      switch eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount {
      case 1:
        #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name == "result.json")
      case 2:
        #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name == "result.xml")
      case 3:
        #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.name == "extractedData.json")
        return mockEIDRequestCaseFileExtractedData
      default:
        break
      }

      #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.id == mockCaseId)
      #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryReceivedArguments?.category == .documentScan)

      return mockEIDRequestCaseFile
    }

    let result = try await configurator.configure(for: mockCaseId, authenticationToken: mockAuthenticationToken)

    #expect(result.authToken == mockAuthenticationToken)
    #expect(result.processId == mockCaseId)
    #expect(eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryCallsCount == 3)
  }

  @Test
  func configure_getFileFails_throwsError() async throws {
    eIDRequestCaseRepository.getFileForRequestCaseIdNameCategoryThrowableError = TestingError.error

    await #expect(throws: TestingError.error) {
      _ = try await configurator.configure(for: mockCaseId, authenticationToken: mockAuthenticationToken)
    }
  }

  // MARK: Private

  private let mockCaseId = "mockCaseId"
  private let mockAuthenticationToken = "mockAuthenticationToken"
  private let mockEIDRequestCaseFile = EIDRequestCaseFile.Mock.sample
  private let mockAvBeamPackageResult: AVBeamPackageResult = .Mock.sample
  private let mockEIDRequestCaseFileExtractedData = EIDRequestCaseFile(fileName: "sample", mime: .json, data: AVBeamPackageData.Mock.sampleExtractedData, category: .documentScan)

  private let configurator: AVBeamNFCConfigurator
  private let eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocolSpy
}
