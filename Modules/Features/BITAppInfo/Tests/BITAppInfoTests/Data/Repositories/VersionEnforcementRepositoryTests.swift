import Factory
import FactoryTesting
import Foundation
import Moya
import Testing
@testable import BITAppInfo
@testable import BITNetworking
@testable import BITTestingCore

@Suite(.container)
struct VersionEnforcementRepositoryTests {

  // MARK: Lifecycle

  init() throws {
    let signatureValidator = VersionEnforcementSignatureValidatorProtocolSpy()
    self.signatureValidator = signatureValidator

    let versionEnforcementUrl = try #require(URL(string: "https://versioning.example.com/api/versioning"))
    self.versionEnforcementUrl = versionEnforcementUrl

    Container.shared.versionEnforcementSignatureValidator.register { signatureValidator }
    Container.shared.versionEnforcementUrl.register { versionEnforcementUrl }

    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }

    repository = VersionEnforcementRepository()
  }

  // MARK: Internal

  @Test
  func fetchVersionEnforcement_signedResponse_validatesBodyAgainstDetachedJWSHeader() async throws {
    try mockResponse(headerFields: [Self.detachedJWSHeaderField: Self.detachedJWS])

    let response = try await repository.fetchVersionEnforcement()

    let arguments = try #require(signatureValidator.validateDetachedJWSReceivedArguments)
    #expect(arguments.detachedJWS == Self.detachedJWS)
    #expect(arguments.payload == VersionEnforcement.Response.Mock.sampleData)
    #expect(response.platform == "ios")
  }

  @Test
  func fetchVersionEnforcement_missingDetachedJWSHeader_throwsMissingDetachedJWS() async throws {
    try mockResponse(headerFields: [:])

    await #expect(throws: VersionEnforcementRepositoryError.missingDetachedJWS) {
      _ = try await repository.fetchVersionEnforcement()
    }
    #expect(!signatureValidator.validateDetachedJWSCalled)
  }

  @Test
  func fetchVersionEnforcement_invalidSignature_throwsAndDoesNotCacheResponse() async throws {
    signatureValidator.validateDetachedJWSThrowableError = TestingError.error
    try mockResponse(headerFields: [Self.detachedJWSHeaderField: Self.detachedJWS])

    await #expect(throws: TestingError.error) {
      _ = try await repository.fetchVersionEnforcement()
    }

    signatureValidator.validateDetachedJWSThrowableError = nil
    let response = try await repository.fetchVersionEnforcement()

    #expect(response.platform == "ios")
    #expect(signatureValidator.validateDetachedJWSCallsCount == 2)
  }

  @Test
  func fetchSwissProfiles_signedResponse_validatesSignatureAndFiltersProfiles() async throws {
    try mockResponse(headerFields: [Self.detachedJWSHeaderField: Self.detachedJWS])

    let profiles = try await repository.fetchSwissProfiles(.verifiableCredential)

    #expect(signatureValidator.validateDetachedJWSCallsCount == 1)
    #expect(!profiles.isEmpty)
    #expect(profiles.allSatisfy { $0.type == .verifiableCredential })
  }

  // MARK: Private

  private static let detachedJWSHeaderField = "detached-jws"
  private static let detachedJWS = "eyJhbGciOiJFUzI1NiJ9..c2lnbmF0dXJl"

  private let repository: VersionEnforcementRepository
  private let signatureValidator: VersionEnforcementSignatureValidatorProtocolSpy
  private let versionEnforcementUrl: URL

  private func mockResponse(statusCode: Int = 200, headerFields: [String: String]) throws {
    let httpResponse = try #require(HTTPURLResponse(url: versionEnforcementUrl, statusCode: statusCode, httpVersion: nil, headerFields: headerFields))
    NetworkContainer.shared.endpointClosure.register {
      .response(httpResponse, VersionEnforcement.Response.Mock.sampleData)
    }
  }
}
