import Moya
import XCTest
@testable import BITAppAttestation
@testable import BITEIDRequest
@testable import BITNetworking

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
    mockResponse(code: 200, data: EIDRequestStatus.Mock.sampleData)

    let status = try await repository.fetchRequestStatus(for: mockeIDRequestResponse.caseId)

    XCTAssertEqual(expectedStatus, status)
  }

  func testSubmitRequest() async throws {
    let expectedResponse = EIDRequestResponse.Mock.sample

    guard let mockeIDRequestPayload: EIDRequestPayload = MRZData.Mock.array.first?.payload else {
      fatalError("Failed to create mock EIDRequestPayload")
    }

    mockResponse(code: 200, data: EIDRequestResponse.Mock.sampleData)

    let response = try await repository.submitRequest(
      ClientAttestedRequest(
        body: mockeIDRequestPayload,
        header: ClientAttestedRequest.Header(clientAttestation: "clientAttestation", clientAttestationPoP: "clientAttestationPoP"))
    )

    XCTAssertEqual(expectedResponse, response)
  }

  func testFetchLegalRepresentantVerification() async throws {
    let expected = LegalRepresentantVerificationResponse.Mock.sample
    mockResponse(code: 200, data: LegalRepresentantVerificationResponse.Mock.sampleData)

    let response = try await repository.fetchLegalRepresentantVerification(for: "caseId")

    XCTAssertEqual(expected, response)
  }

  func testFetchChallenge_success() async throws {
    let expectedResponse = AttestationChallenge.Response.Mock.sample.challenge
    mockResponse(code: 200, data: AttestationChallenge.Response.Mock.sampleData)

    let response = try await repository.fetchChallenge()

    XCTAssertEqual(response, expectedResponse)
  }

  func testExecute_validateAttestationsClientAttestationInvalid_throwsInvalidClientAttestationError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(ValidateAttestationsErrorResponse.Mock.clientAttestationSample))

    do {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .invalidClientAttestation)
    }
  }

  func testExecute_validateAttestationsKeyAttestationInvalid_throwsInvalidKeyAttestationError() async throws {
    try mockResponse(code: 422, data: JSONEncoder().encode(ValidateAttestationsErrorResponse.Mock.keyAttestationSample))

    do {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .invalidKeyAttestation)
    }
  }

  func testExecute_validateAttestationsFails_throwsUnknownError() async throws {
    mockResponse(code: 400)

    do {
      try await repository.validateAttestations(mockValidateAttestationsRequestBody)
      XCTFail("Expected an error")
    } catch {
      XCTAssertEqual(error as? EIDRequestRepository.Error, .unknownError)
    }
  }

  // MARK: Private

  private let strURL = "some://url"
  private var repository = EIDRequestRepository()
  private let mockeIDRequestResponse: EIDRequestResponse = .Mock.sample
  private let mockValidateAttestationsRequestBody: ValidateAttestationsRequestBody = .Mock.sample

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }

}
