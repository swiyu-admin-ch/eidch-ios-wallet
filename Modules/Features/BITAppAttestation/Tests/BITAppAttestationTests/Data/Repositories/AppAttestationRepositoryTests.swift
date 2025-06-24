// swiftlint: disable implicitly_unwrapped_optional force_unwrapping
import BITNetworking
import Factory
import XCTest
@testable import BITAppAttestation
@testable import BITCrypto
@testable import BITJWT

final class AppAttestationRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    repository = AppAttestationRepository()

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register { { _ in .immediate } }
  }

  // MARK: - FetchChallenge

  func testFetchChallenge_success() async throws {
    let expectedResponse = AttestationChallenge.Response.Mock.sample.challenge
    mockResponse(code: 200, data: AttestationChallenge.Response.Mock.sampleData)

    let response = try await repository.fetchChallenge()

    XCTAssertEqual(response, expectedResponse)
  }

  func testFetchChallenge_failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchChallenge()
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .internalServerError)
    }
  }

  // MARK: - FetchClientAttestation

  func testFetchClientAttestation_success() async throws {
    let jwsDecoderMock = JWSDecoderMock(payload: ClientAttestationPayload.Mock.samplePayload, rawPayload: "rawPayload")
    Container.shared.jwsDecoder.register { jwsDecoderMock }

    repository = AppAttestationRepository()

    let expectedResponse = ClientAttestationPayload.Mock.sample
    mockResponse(code: 200, data: ClientAttestationResponse.Mock.sampleData)

    let response = try await repository.fetchClientAttestation(mockClientAttestationRequestBody)

    XCTAssertEqual(response.payload, expectedResponse.payload)
  }

  func testFetchClientAttestation_failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchClientAttestation(mockClientAttestationRequestBody)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .internalServerError)
    }
  }

  // MARK: - FetchKeyAttestation

  func testFetchKeyAttestation_success() async throws {
    let jwsDecoderMock = JWSDecoderMock(payload: KeyAttestationPayload.Mock.samplePayload, rawPayload: "rawPayload")
    Container.shared.jwsDecoder.register { jwsDecoderMock }

    repository = AppAttestationRepository()

    let expectedResponse = KeyAttestationPayload.Mock.sample
    mockResponse(code: 200, data: KeyAttestationResponse.Mock.sampleData)

    let response = try await repository.fetchKeyAttestation(with: mockClientAttestedRequest)

    XCTAssertEqual(response.payload, expectedResponse.payload)
  }

  func testFetchKeyAttestation_failure() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchKeyAttestation(with: mockClientAttestedRequest)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual((error as? NetworkError)?.status, .internalServerError)
    }
  }

  // MARK: Private

  private let mockClientAttestationRequestBody = ClientAttestationRequestBody.Mock.sample
  private var mockClientAttestedRequest = ClientAttestedRequest(
    body: "body",
    header: ClientAttestedRequest.Header(clientAttestation: "clientAttestation", clientAttestationPoP: "clientAttestationPoP"))

  private var repository: AppAttestationRepository!

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}

// swiftlint: enable implicitly_unwrapped_optional force_unwrapping
