import BITAVWrapper
import Factory
import Spyable

// MARK: - FetchNFCScanResultUseCaseProtocol

@Spyable
protocol FetchNFCScanResultUseCaseProtocol {
  func execute(for caseId: String, packageResult: AVBeamPackageResult) throws -> NFCScanResult
}

// MARK: - FetchNFCScanResultUseCase

struct FetchNFCScanResultUseCase: FetchNFCScanResultUseCaseProtocol {

  // MARK: Internal

  func execute(for caseId: String, packageResult: AVBeamPackageResult) throws -> NFCScanResult {
    try avBeamNFCService.fetchResult(for: caseId, packageResult: packageResult)
  }

  // MARK: Private

  @Injected(\.avBeamNFCService) private var avBeamNFCService: AVBeamNFCServiceProtocol
}
