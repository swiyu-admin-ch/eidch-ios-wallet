import BITNetworking
import Factory
import XCTest
@testable import BITAnalytics
@testable import BITAnalyticsMocks
@testable import BITAnyCredentialFormat
@testable import BITAppAuth
@testable import BITCredentialShared
@testable import BITCrypto
@testable import BITJWT
@testable import BITLocalAuthentication
@testable import BITOpenID
@testable import BITPresentation
@testable import BITSdJWT
@testable import BITSdJWTMocks
@testable import BITTestingCore
@testable import BITVault

final class PresentationRequestBodyGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    mockInputDescriptor = mockRequestObject.presentationDefinition.inputDescriptors.first
    setupMocks()
    success()

    generator = PresentationRequestBodyGenerator()
  }

  func testCreatePresentationRequestBody_WithKeyBinding_ReturnsBody() async throws {
    let body = try generator.generate(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)

    assertArguments(assertKeyPair: true)

    XCTAssertEqual(body.vpToken, Self.mockVpToken)
    XCTAssertEqual(body.presentationSubmission.definitionId, mockRequestObject.presentationDefinition.id)
    XCTAssertEqual(body.presentationSubmission.descriptorMap, mockDescriptorMaps)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testCreatePresentationRequestBody_WithoutKeyBinding_ReturnsBody() throws {
    let body = try generator.generate(for: CompatibleCredential.Mock.BITWithoutKeyBinding, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)

    assertArguments(assertKeyPair: false)

    XCTAssertEqual(body.vpToken, Self.mockVpToken)
    XCTAssertEqual(body.presentationSubmission.definitionId, mockRequestObject.presentationDefinition.id)
    XCTAssertEqual(body.presentationSubmission.descriptorMap, mockDescriptorMaps)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testCreatePresentationRequestBody_CreateAnyCredentialUseCaseThrows_ThrowsError() throws {
    spyCreateAnyCredentialUseCase.executeFromFormatThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: CompatibleCredential.Mock.BITWithoutKeyBinding, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyCreateAnyCredentialUseCase.executeFromFormatCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCreatePresentationRequestBody_GetPrivateKeyThrows_ThrowsError() throws {
    spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 1)
    }
  }

  func testCreatePresentationRequestBody_AnyVpTokenGeneratorThrows_ThrowsError() throws {
    spyVpTokenGenerator.generateRequestObjectCredentialKeyPairFieldsThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyVpTokenGenerator.generateRequestObjectCredentialKeyPairFieldsCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCreatePresentationRequestBody_AnyDescriptorMapGeneratorThrows_ThrowsError() throws {
    spyAnyDescriptorMapGenerator.generateUsingVcFormatThrowableError = TestingError.error

    XCTAssertThrowsError(try generator.generate(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyAnyDescriptorMapGenerator.generateUsingVcFormatCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCreatePresentationRequestBody_userLoggedOut() throws {
    userSession.isLoggedIn = false

    XCTAssertThrowsError(try generator.generate(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? UserSessionError, .notLoggedIn)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  // MARK: Private

  private static let mockVpToken = "vpToken"

  private var mockCredential = Credential.Mock.sample
  private var mockAnyCredential = AnyCredentialSpy()
  private var mockDescriptorMaps = [PresentationRequestBody.DescriptorMap(id: "id", format: "format", path: "path")]
  private var mockRequestObject = RequestObject.Mock.VcSdJwt.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256

  // swiftlint:disable all
  private var mockInputDescriptor: InputDescriptor!
  private var generator: PresentationRequestBodyGenerator!
  private var spyVpTokenGenerator: AnyVpTokenGeneratorProtocolSpy!
  private var spyKeyManager: KeyManagerProtocolSpy!
  private var spyAuthContext: LAContextProtocolSpy!
  private var spyCreateAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocolSpy!
  private var spyAnyDescriptorMapGenerator: AnyDescriptorMapGeneratorProtocolSpy!
  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!
  private var userSession: SessionSpy!

  // swiftlint:enable all

  private func setupMocks() {
    spyKeyManager = KeyManagerProtocolSpy()
    userSession = SessionSpy()
    spyVpTokenGenerator = AnyVpTokenGeneratorProtocolSpy()
    spyCreateAnyCredentialUseCase = CreateAnyCredentialUseCaseProtocolSpy()
    spyAnyDescriptorMapGenerator = AnyDescriptorMapGeneratorProtocolSpy()
    analyticsProvider = MockProvider()
    analytics = Analytics()

    Container.shared.keyManager.register { self.spyKeyManager }
    Container.shared.userSession.register { self.userSession }
    Container.shared.anyVpTokenGenerator.register { self.spyVpTokenGenerator }
    Container.shared.createAnyCredentialUseCase.register { self.spyCreateAnyCredentialUseCase }
    Container.shared.anyDescriptorMapGenerator.register { self.spyAnyDescriptorMapGenerator }
    Container.shared.analytics.register { self.analytics }

    analytics.register(analyticsProvider)

    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()
  }

  private func success() {
    spyCreateAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential
    spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryReturnValue = mockKeyPair
    spyVpTokenGenerator.generateRequestObjectCredentialKeyPairFieldsReturnValue = Self.mockVpToken
    spyAnyDescriptorMapGenerator.generateUsingVcFormatReturnValue = mockDescriptorMaps
  }

  private func assertArguments(assertKeyPair: Bool) {
    XCTAssertEqual(spyCreateAnyCredentialUseCase.executeFromFormatReceivedArguments?.payload, mockCredential.payload)
    XCTAssertEqual(spyCreateAnyCredentialUseCase.executeFromFormatReceivedArguments?.format, mockCredential.format)

    if assertKeyPair {
      XCTAssertEqual(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.identifier, mockCredential.keyBinding?.id.uuidString)
      XCTAssertEqual(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryReceivedArguments?.algorithm.rawValue, mockCredential.keyBinding?.algorithm)
    } else {
      XCTAssertFalse(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryCalled)
    }

    guard let tokenGeneratorArguments = spyVpTokenGenerator.generateRequestObjectCredentialKeyPairFieldsReceivedArguments else {
      XCTFail("No arguments received")
      return
    }
    XCTAssertEqual(tokenGeneratorArguments.requestObject, mockRequestObject)
    if assertKeyPair {
      XCTAssertEqual(tokenGeneratorArguments.keyPair, mockKeyPair)
    } else {
      XCTAssertNil(tokenGeneratorArguments.keyPair)
    }
    XCTAssertEqual(tokenGeneratorArguments.requestObject, mockRequestObject)
    XCTAssertEqual(tokenGeneratorArguments.fields, ["firstName", "lastName"])

    XCTAssertEqual(spyAnyDescriptorMapGenerator.generateUsingVcFormatReceivedArguments?.inputDescriptor, mockInputDescriptor)
    XCTAssertEqual(spyAnyDescriptorMapGenerator.generateUsingVcFormatReceivedArguments?.vcFormat, mockCredential.format)
  }

}
