import BITNetworking
import XCTest
@testable import BITEIDRequest

// MARK: - OpenIDCredentialRepository

final class EIDRequestRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = EIDRequestRepository()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }
  }

  // MARK: - Metadata

  func testGetRequestStatus() async throws {
    let expectedStatus = EIDRequestStatus.Mock.inQueueSample

    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(200, EIDRequestStatus.Mock.sampleData)
    }

    let status = try await repository.fetchRequestStatus(for: mockeIDRequestResponse.caseId)

    XCTAssertEqual(expectedStatus, status)
  }

  func testSubmitRequest() async throws {
    let expectedResponse = EIDRequestResponse.Mock.sample

    guard let mockeIDRequestPayload: EIDRequestPayload = MRZData.Mock.array.first?.payload else {
      fatalError("Failed to create mock EIDRequestPayload")
    }

    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(200, EIDRequestResponse.Mock.sampleData)
    }

    let response = try await repository.submitRequest(with: mockeIDRequestPayload)

    XCTAssertEqual(expectedResponse, response)
  }

  func testFetchLegalRepresentantVerification() async throws {
    let expected = LegalRepresentantVerificationResponse.Mock.sample

    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(200, LegalRepresentantVerificationResponse.Mock.sampleData)
    }

    let response = try await repository.fetchLegalRepresentantVerification(for: "caseId")

    XCTAssertEqual(expected, response)
  }

  // MARK: Private

  private let strURL = "some://url"
  private var repository = EIDRequestRepository()
  private let mockeIDRequestResponse: EIDRequestResponse = .Mock.sample
}
