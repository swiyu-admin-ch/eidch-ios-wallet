// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import BITNetworking
import Factory
import Foundation
import XCTest
@testable import BITAnalytics
@testable import BITAnyCredentialFormat
@testable import BITAppAuth
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITOpenID
@testable import BITPresentation
@testable import BITSdJWT
@testable import BITTestingCore
@testable import BITVault

final class AuthorizationResponseBodyGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    setupMocks()
    success()

    generator = AuthorizationResponseBodyGenerator()
  }

  func testCallAsFunction_WithKeyBinding_ReturnsBody() async throws {
    let response = try await generator(for: compatibleCredentialMock, requestObject: mockRequestObject, withOrigin: nil)

    assertArguments(for: compatibleCredentialMock, assertKeyPair: true)

    XCTAssertEqual(response.vpToken[Self.mockDcqlQueryId], [Self.mockVpToken])
    XCTAssertEqual(response.asDictionary()["state"] as? String, Self.mockState)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testCallAsFunction_WithoutKeyBinding_ReturnsBody() async throws {
    let response = try await generator(for: compatibleCredentialWithoutKeyBindingMock, requestObject: mockRequestObject, withOrigin: nil)

    assertArguments(for: compatibleCredentialWithoutKeyBindingMock, assertKeyPair: false)

    XCTAssertEqual(response.vpToken[Self.mockDcqlQueryId], [Self.mockVpToken])
    XCTAssertEqual(response.asDictionary()["state"] as? String, Self.mockState)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testCallAsFunction_WithDcApiJwtResponseMode_ReturnsVpTokenDictionaryInBody() async throws {
    let requestObject = try makeRequestObject(responseMode: .dcApiJWT, clientMetadata: nil)

    let response = try await generator(for: compatibleCredentialMock, requestObject: requestObject, withOrigin: nil)

    let dictionary = response.asDictionary()
    XCTAssertEqual(dictionary["vp_token"] as? [String: [String]], [Self.mockDcqlQueryId: [Self.mockVpToken]])
    XCTAssertFalse(dictionary["vp_token"] is String)
    XCTAssertNil(dictionary["state"])
  }

  func testCallAsFunction_WithDcApiResponseMode_ReturnsVpTokenDictionaryInBody() async throws {
    let requestObject = try makeRequestObject(responseMode: .dcApi, clientMetadata: nil)

    let response = try await generator(for: compatibleCredentialMock, requestObject: requestObject, withOrigin: nil)

    let dictionary = response.asDictionary()
    XCTAssertEqual(dictionary["vp_token"] as? [String: [String]], [Self.mockDcqlQueryId: [Self.mockVpToken]])
    XCTAssertFalse(dictionary["vp_token"] is String)
    XCTAssertNil(dictionary["state"])
  }

  func testCallAsFunction_missingQueryId_throws() async throws {
    await XCTAssertThrowsErrorAsync(try await generator(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, withOrigin: nil)) { error in
      XCTAssertEqual(error as? RequestObjectError, .invalidQuery)
    }
  }

  func testCallAsFunction_CreateAnyCredentialUseCaseThrows_ThrowsError() async throws {
    spyCreateAnyCredentialUseCase.executeFromFormatThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await generator(for: compatibleCredentialWithoutKeyBindingMock, requestObject: mockRequestObject, withOrigin: nil)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyCreateAnyCredentialUseCase.executeFromFormatCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCallAsFunction_GetPrivateKeyThrows_ThrowsError() async throws {
    spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await generator(for: compatibleCredentialMock, requestObject: mockRequestObject, withOrigin: nil)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 1)
    }
  }

  func testCallAsFunction_AnyVpTokenGeneratorThrows_ThrowsError() async throws {
    spyVpTokenGenerator.generateRequestObjectCredentialKeyPairPathsWithOriginThrowableError = TestingError.error

    await XCTAssertThrowsErrorAsync(try await generator(for: compatibleCredentialMock, requestObject: mockRequestObject, withOrigin: nil)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyVpTokenGenerator.generateRequestObjectCredentialKeyPairPathsWithOriginCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCallAsFunction_userLoggedOut() async throws {
    userSession.isLoggedIn = false

    await XCTAssertThrowsErrorAsync(try await generator(for: compatibleCredentialMock, requestObject: mockRequestObject, withOrigin: nil)) { error in
      XCTAssertEqual(error as? UserSessionError, .notLoggedIn)
      XCTAssertEqual(userSession.endSessionCallsCount, 1)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  // MARK: Private

  private static let mockVpToken = "vpToken"
  private static let mockDcqlQueryId = "pid"
  private static let mockState = "1234"

  private var mockAnyCredential = AnyCredentialSpy()
  private var mockRequestObject = RequestObjectJWS.Mock.sample.payload
  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private var generator: AuthorizationResponseBodyGenerator!
  private var spyVpTokenGenerator: AnyVpTokenGeneratorProtocolSpy!
  private var spyKeyManager: KeyManagerProtocolSpy!
  private var spyCreateAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocolSpy!
  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!
  private var userSession: SessionSpy!
  private let selectCredentialBundleItemUseCaseSpy = SelectCredentialBundleItemUseCaseProtocolSpy()

  private var compatibleCredentialMock: CompatibleCredential {
    CompatibleCredential(
      credential: CompatibleCredential.Mock.BIT.credential,
      presentingPaths: [CompatibleCredential.Mock.pathFirstName, CompatibleCredential.Mock.pathLastName],
      dcqlQueryId: Self.mockDcqlQueryId)
  }

  private var compatibleCredentialWithoutKeyBindingMock: CompatibleCredential {
    CompatibleCredential(
      credential: CompatibleCredential.Mock.BITWithoutKeyBinding.credential,
      presentingPaths: [CompatibleCredential.Mock.pathFirstName, CompatibleCredential.Mock.pathLastName],
      dcqlQueryId: Self.mockDcqlQueryId)
  }

  // swiftlint:enable all

  private func setupMocks() {
    let spyKeyManager = KeyManagerProtocolSpy()
    self.spyKeyManager = spyKeyManager
    let userSession = SessionSpy()
    self.userSession = userSession
    let spyVpTokenGenerator = AnyVpTokenGeneratorProtocolSpy()
    self.spyVpTokenGenerator = spyVpTokenGenerator
    let spyCreateAnyCredentialUseCase = CreateAnyCredentialUseCaseProtocolSpy()
    self.spyCreateAnyCredentialUseCase = spyCreateAnyCredentialUseCase
    analyticsProvider = MockProvider()
    let analytics = AnalyticsSpy()
    self.analytics = analytics

    Container.shared.keyManager.register { spyKeyManager }
    Container.shared.userSession.register { userSession }
    Container.shared.anyVpTokenGenerator.register { spyVpTokenGenerator }
    Container.shared.createAnyCredentialUseCase.register { spyCreateAnyCredentialUseCase }
    Container.shared.analytics.register { analytics }

    analytics.register(analyticsProvider)

    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()

    selectCredentialBundleItemUseCaseSpy.callAsFunctionClosure = {
      $0.bundleItems.first!
    }
  }

  private func success() {
    spyCreateAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential
    spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryReturnValue = mockKeyPair
    spyVpTokenGenerator.generateRequestObjectCredentialKeyPairPathsWithOriginReturnValue = Self.mockVpToken
  }

  private func assertArguments(for compatibleCredential: CompatibleCredential, assertKeyPair: Bool) {
    let credential = compatibleCredential.credential
    let selectedBundleItem = try! selectCredentialBundleItemUseCaseSpy(credential)
    XCTAssertEqual(spyCreateAnyCredentialUseCase.executeFromFormatReceivedArguments?.payload, selectedBundleItem.payload)
    XCTAssertEqual(spyCreateAnyCredentialUseCase.executeFromFormatReceivedArguments?.format, credential.format)

    if assertKeyPair {
      XCTAssertEqual(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.identifier, selectedBundleItem.keyBinding?.id.uuidString)
      XCTAssertEqual(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.algorithm.rawValue, selectedBundleItem.keyBinding?.algorithm)
    } else {
      XCTAssertFalse(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryCalled)
    }

    guard let tokenGeneratorArguments = spyVpTokenGenerator.generateRequestObjectCredentialKeyPairPathsWithOriginReceivedArguments else {
      XCTFail("No arguments received")
      return
    }
    XCTAssertEqual(tokenGeneratorArguments.requestObject, mockRequestObject)
    if assertKeyPair {
      XCTAssertEqual(tokenGeneratorArguments.keyPair, mockKeyPair)
    } else {
      XCTAssertNil(tokenGeneratorArguments.keyPair)
    }
    XCTAssertEqual(tokenGeneratorArguments.paths, [[.string("firstName")], [.string("lastName")]])
  }

  private func makeRequestObject(
    responseMode: RequestObject.ResponseMode,
    clientMetadata: ClientMetadata?) throws
    -> RequestObject
  {
    try RequestObject(
      dcqlQuery: mockRequestObject.dcqlQuery,
      state: nil,
      nonce: "nonce",
      responseUri: URL(string: "https://example.com")!,
      clientMetadata: clientMetadata,
      responseType: "vp_token",
      clientId: "did:example:12345",
      responseMode: responseMode,
      scope: nil,
      transactionData: nil)
  }
}
