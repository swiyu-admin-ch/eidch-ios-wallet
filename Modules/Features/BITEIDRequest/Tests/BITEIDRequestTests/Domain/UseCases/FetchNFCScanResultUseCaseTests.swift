import Factory
import XCTest
@testable import BITAVWrapper
@testable import BITEIDRequest
@testable import BITTestingCore

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

final class FetchNFCScanResultUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()

    registerMocks()
    useCase = FetchNFCScanResultUseCase()
  }

  func testExecute_success() async throws {
    _ = try await useCase.execute(for: mockCaseId, packageResult: mockPackageResult)

    XCTAssertEqual(avBeamNFCService.fetchResultForPackageResultCallsCount, 1)
    XCTAssertEqual(avBeamNFCService.fetchResultForPackageResultReceivedArguments?.caseId, mockCaseId)
    XCTAssertEqual(avBeamNFCService.fetchResultForPackageResultReceivedArguments?.packageResult, mockPackageResult)
  }

  // MARK: Private

  private var useCase: FetchNFCScanResultUseCase!

  private let mockCaseId = "caseId"
  private let mockPackageResult = AVBeamPackageResult.Mock.sample
  private var avBeamNFCService: AVBeamNFCServiceProtocolSpy!

  private func registerMocks() {
    avBeamNFCService = AVBeamNFCServiceProtocolSpy()
    avBeamNFCService.fetchResultForPackageResultReturnValue = NFCScanResult.Mock.sample
    Container.shared.avBeamNFCService.register { self.avBeamNFCService }
  }

}
