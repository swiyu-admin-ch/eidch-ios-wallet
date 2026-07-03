import Testing
@testable import BITCredential

struct GetCredentialRefreshThresholdUseCaseTests {

  @Test(arguments: [
    (batchSize: 1, threshold: 1),
    (batchSize: 5, threshold: 1),
    (batchSize: 10, threshold: 2),
    (batchSize: 14, threshold: 3),
  ])
  func callAsFunction_returnsTwentyPercentRoundedUp(batchSize: Int, threshold: Int) {
    let useCase = GetCredentialRefreshThresholdUseCase()

    #expect(useCase(for: batchSize) == threshold)
  }
}
