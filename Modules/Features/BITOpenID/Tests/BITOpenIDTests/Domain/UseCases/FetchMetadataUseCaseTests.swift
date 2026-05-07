import Factory
import Spyable
import XCTest
@testable import BITOpenID
@testable import BITTestingCore

final class FetchMetadataUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    registerMocks()
    useCase = FetchMetadataUseCase()
    success()
  }

  func testExecute_success() async throws {
    let metadataWrapper = try await useCase.execute(for: offerMock)

    XCTAssertEqual(mockMetadata.credentialEndpoint, metadataWrapper.credentialIssuerMetadata.credentialEndpoint)
    XCTAssertEqual(mockMetadata.credentialConfigurationsSupported.first?.value as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported, metadataWrapper.credentialIssuerMetadata.credentialConfigurationsSupported.first?.value as? CredentialIssuerMetadata.VcSdJwtCredentialConfigurationSupported)
    XCTAssertEqual(metadataWrapper.rawData, mockMetadataData)
    XCTAssertEqual(spyRepository.fetchMetadataFromCallsCount, 1)
    XCTAssertEqual(spyRepository.fetchMetadataFromReceivedIssuerUrl, URL(string: offerMock.issuer))
  }

  func testExecute_repositoryThrows_throws() async throws {
    guard let mockUrl = URL(string: "http://mock.url") else { fatalError("url generation") }
    spyRepository.fetchMetadataFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(for: offerMock)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(spyRepository.fetchMetadataFromCalled)
      XCTAssertEqual(spyRepository.fetchMetadataFromCallsCount, 1)
      XCTAssertEqual(spyRepository.fetchMetadataFromReceivedIssuerUrl, URL(string: offerMock.issuer))
    } catch {
      XCTFail("Not the error expected")
    }
  }

  // MARK: Private

  private let offerMock = CredentialOffer.Mock.sample
  private let mockMetadata = CredentialIssuerMetadata.Mock.sample
  private let mockMetadataData = CredentialIssuerMetadata.Mock.sampleData

  private var spyRepository = OpenIDRepositoryProtocolSpy()
  private var useCase = FetchMetadataUseCase()

  private func success() {
    guard let mockUrl = URL(string: "http://mock.url") else { fatalError("url generation") }
    spyRepository.fetchMetadataFromReturnValue = CredentialIssuerMetadataResponse(metadata: mockMetadata, raw: mockMetadataData)
  }

  private func registerMocks() {
    Container.shared.openIDRepository.register { self.spyRepository }
  }

}
