import Spyable
import XCTest
@testable import BITNetworking
@testable import BITOpenID
@testable import BITTestingCore

final class FetchMetadataUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    spyRepository = OpenIDRepositoryProtocolSpy()
    useCase = FetchMetadataUseCase(repository: spyRepository)
  }

  func testFetchMetadataHappyPath() async throws {
    let mockMetadata = CredentialMetadata.Mock.sample
    let mockMetadataData = CredentialMetadata.Mock.sampleData
    guard let mockUrl = URL(string: "http://mock.url") else { fatalError("url generation") }
    spyRepository.fetchMetadataFromReturnValue = NetworkResponse(object: mockMetadata, data: mockMetadataData)

    let response = try await useCase.execute(from: mockUrl)
    let metadata = response.object

    XCTAssertEqual(mockMetadata.credentialEndpoint, metadata.credentialEndpoint)
    XCTAssertEqual(mockMetadata.credentialConfigurationsSupported.first?.value as? CredentialMetadata.VcSdJwtCredentialConfigurationSupported, metadata.credentialConfigurationsSupported.first?.value as? CredentialMetadata.VcSdJwtCredentialConfigurationSupported)
    XCTAssertEqual(mockMetadataData, response.data)
    XCTAssertTrue(spyRepository.fetchMetadataFromCalled)
    XCTAssertEqual(1, spyRepository.fetchMetadataFromCallsCount)
    XCTAssertEqual(mockUrl, spyRepository.fetchMetadataFromReceivedInvocations.first)
  }

  func testFetchMetadataFailurePath() async throws {
    guard let mockUrl = URL(string: "http://mock.url") else { fatalError("url generation") }
    spyRepository.fetchMetadataFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(from: mockUrl)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(spyRepository.fetchMetadataFromCalled)
      XCTAssertEqual(1, spyRepository.fetchMetadataFromCallsCount)
      XCTAssertEqual(mockUrl, spyRepository.fetchMetadataFromReceivedInvocations.first)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  // MARK: Private

  private var spyRepository = OpenIDRepositoryProtocolSpy()
  private var useCase = FetchMetadataUseCase()

}
