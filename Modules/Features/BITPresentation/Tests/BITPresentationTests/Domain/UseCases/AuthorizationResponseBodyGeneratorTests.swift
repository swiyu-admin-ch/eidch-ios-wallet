// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import BITNetworking
import Factory
import Foundation
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

final class AuthorizationResponseBodyGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    guard let descriptor = presentationDefinition.inputDescriptors.first else {
      fatalError("Missing input descriptor fixture")
    }
    mockInputDescriptor = descriptor
    setupMocks()
    success()

    generator = AuthorizationResponseBodyGenerator()
  }

  func testCreateAuthorizationResponseBody_WithKeyBinding_ReturnsBody() throws {
    let body = try generator(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)

    guard case .json(let payload, let type) = body else {
      XCTFail("Expected json authorization response body")
      return
    }
    guard let response = payload as? AuthorizationResponse else {
      XCTFail("Expected AuthorizationResponse")
      return
    }
    guard let presentationSubmission = response.presentationSubmission else {
      XCTFail("Expected presentation submission")
      return
    }

    assertArguments(assertKeyPair: true)

    XCTAssertEqual(response.vpToken, Self.mockVpToken)
    XCTAssertEqual(presentationSubmission.definitionId, presentationDefinition.id)
    XCTAssertEqual(presentationSubmission.descriptorMap, mockDescriptorMaps)
    XCTAssertEqual(type, .dif)
    XCTAssertEqual(body.type, .dif)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testCreateAuthorizationResponseBody_WithoutKeyBinding_ReturnsBody() throws {
    let body = try generator(for: CompatibleCredential.Mock.BITWithoutKeyBinding, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)

    guard case .json(let payload, let type) = body else {
      XCTFail("Expected json authorization response body")
      return
    }
    guard let response = payload as? AuthorizationResponse else {
      XCTFail("Expected AuthorizationResponse")
      return
    }
    guard let presentationSubmission = response.presentationSubmission else {
      XCTFail("Expected presentation submission")
      return
    }

    assertArguments(assertKeyPair: false)

    XCTAssertEqual(response.vpToken, Self.mockVpToken)
    XCTAssertEqual(presentationSubmission.definitionId, presentationDefinition.id)
    XCTAssertEqual(presentationSubmission.descriptorMap, mockDescriptorMaps)
    XCTAssertEqual(type, .dif)
    XCTAssertEqual(body.type, .dif)
    XCTAssertEqual(analyticsProvider.logCounter, 0)
  }

  func testCreateAuthorizationResponseBody_WithDcqlRequest_ReturnsBodyWithDcqlType() throws {
    let body = try generator(for: dcqlCompatibleCredentialMock, requestObject: RequestObject.Mock.Dcql.sample, inputDescriptor: nil)

    guard case .json(let payload, let type) = body else {
      XCTFail("Expected json authorization response body")
      return
    }
    guard let response = payload as? AuthorizationResponse else {
      XCTFail("Expected AuthorizationResponse")
      return
    }

    XCTAssertEqual(type, .dcql)
    XCTAssertEqual(body.type, .dcql)
    XCTAssertNil(response.presentationSubmission)
    XCTAssertNil(response.vpToken)
    XCTAssertEqual(response.vpTokenByCredentialQueryId?[Self.mockDcqlQueryId], [Self.mockVpToken])
    XCTAssertFalse(spyAnyDescriptorMapGenerator.generateUsingVcFormatCalled)
  }

  func testCreateAuthorizationResponseBody_missingQueryId_throws() throws {
    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BIT, requestObject: RequestObject.Mock.Dcql.sample, inputDescriptor: nil)) { error in
      XCTAssertEqual(error as? RequestObjectError, .invalidDcqlQuery)
    }
  }

  func testCreateAuthorizationResponseBody_directPostJwtEncryptionEnabled_returnsJwe() throws {
    let metadata = try makeClientMetadata(jwks: ClientMetadata.JWKs(keys: [payloadEncryptionJwk]))
    let requestObject = makeRequestObject(queryType: .presentationDefinition(presentationDefinition), responseMode: .directPostJWT, clientMetadata: metadata)
    let body = try generator(for: CompatibleCredential.Mock.BIT, requestObject: requestObject, inputDescriptor: mockInputDescriptor)

    guard case .jwe(let token, let type) = body else {
      XCTFail("Expected jwe authorization response body")
      return
    }

    XCTAssertEqual(token, Self.mockJweToken)
    XCTAssertEqual(type, .dif)
    XCTAssertEqual(body.type, .dif)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmCallsCount, 1)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.publicKey, payloadEncryptionJwk)
    XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.encryptionAlgorithm, .A128GCM)
    XCTAssertNil(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReceivedArguments?.compressionAlgorithm)
  }

  func testCreateAuthorizationResponseBody_directPostJwtEncryptionEnabledDcql_returnsJwe() throws {
    let metadata = try makeClientMetadata(jwks: ClientMetadata.JWKs(keys: [payloadEncryptionJwk]))
    let requestObject = try makeRequestObject(queryType: .dcqlRaw(XCTUnwrap(RequestObject.Mock.Dcql.sample.rawDcqlQuery)), responseMode: .directPostJWT, clientMetadata: metadata)
    let body = try generator(for: dcqlCompatibleCredentialMock, requestObject: requestObject, inputDescriptor: nil)

    guard case .jwe(let token, let type) = body else {
      XCTFail("Expected jwe authorization response body")
      return
    }

    XCTAssertEqual(token, Self.mockJweToken)
    XCTAssertEqual(body.type, .dcql)
  }

  func testCreateAuthorizationResponseBody_directPostJwtMissingJwk_throwsPayloadEncryptionFailed() throws {
    let requestObject = makeRequestObject(queryType: .presentationDefinition(presentationDefinition), responseMode: .directPostJWT, clientMetadata: nil)

    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BIT, requestObject: requestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? AuthorizationResponseBodyGeneratorError, .payloadEncryptionFailed)
      XCTAssertEqual(jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmCallsCount, 0)
    }
  }

  func testCreateAuthorizationResponseBody_directPostJwtEncrypterThrows_throwsError() throws {
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmThrowableError = TestingError.error

    let metadata = try makeClientMetadata(jwks: ClientMetadata.JWKs(keys: [payloadEncryptionJwk]))
    let requestObject = makeRequestObject(queryType: .presentationDefinition(presentationDefinition), responseMode: .directPostJWT, clientMetadata: metadata)

    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BIT, requestObject: requestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testCreateAuthorizationResponseBody_CreateAnyCredentialUseCaseThrows_ThrowsError() throws {
    spyCreateAnyCredentialUseCase.executeFromFormatThrowableError = TestingError.error

    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BITWithoutKeyBinding, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyCreateAnyCredentialUseCase.executeFromFormatCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCreateAuthorizationResponseBody_GetPrivateKeyThrows_ThrowsError() throws {
    spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryThrowableError = TestingError.error

    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 1)
    }
  }

  func testCreateAuthorizationResponseBody_AnyVpTokenGeneratorThrows_ThrowsError() throws {
    spyVpTokenGenerator.generateRequestObjectCredentialKeyPairFieldsThrowableError = TestingError.error

    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyVpTokenGenerator.generateRequestObjectCredentialKeyPairFieldsCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCreateAuthorizationResponseBody_AnyDescriptorMapGeneratorThrows_ThrowsError() throws {
    spyAnyDescriptorMapGenerator.generateUsingVcFormatThrowableError = TestingError.error

    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? TestingError, .error)
      XCTAssertTrue(spyAnyDescriptorMapGenerator.generateUsingVcFormatCalled)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  func testCreateAuthorizationResponseBody_userLoggedOut() throws {
    userSession.isLoggedIn = false

    XCTAssertThrowsError(try generator(for: CompatibleCredential.Mock.BIT, requestObject: mockRequestObject, inputDescriptor: mockInputDescriptor)) { error in
      XCTAssertEqual(error as? UserSessionError, .notLoggedIn)
      XCTAssertEqual(userSession.endSessionCallsCount, 1)
      XCTAssertEqual(analyticsProvider.logCounter, 0)
    }
  }

  // MARK: Private

  private static let mockVpToken = "vpToken"
  private static let mockJweToken = "jweToken"
  private static let mockDcqlQueryId = "pid"

  private var mockCredential = VerifiableCredential.Mock.sample
  private var mockAnyCredential = AnyCredentialSpy()
  private var mockDescriptorMaps = [AuthorizationResponse.DescriptorMap(id: "id", format: "format", path: "path")]
  private var mockRequestObject = RequestObject.Mock.VcSdJwt.sample
  private let mockKeyPair = VaultKeyPair.Mock.ES256
  private let payloadEncryptionJwk = JWK.Mock.validSample
  private var mockInputDescriptor: InputDescriptor!
  private var generator: AuthorizationResponseBodyGenerator!
  private var spyVpTokenGenerator: AnyVpTokenGeneratorProtocolSpy!
  private var spyKeyManager: KeyManagerProtocolSpy!
  private var spyAuthContext: LAContextProtocolSpy!
  private var spyCreateAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocolSpy!
  private var spyAnyDescriptorMapGenerator: AnyDescriptorMapGeneratorProtocolSpy!
  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!
  private var userSession: SessionSpy!
  private var jweEncrypterSpy: JWEEncrypterProtocolSpy!

  private var dcqlCompatibleCredentialMock: CompatibleCredential {
    CompatibleCredential(
      credential: CompatibleCredential.Mock.BIT.credential,
      requestedFields: [CompatibleCredential.Mock.fieldFirstName, CompatibleCredential.Mock.fieldLastName],
      dcqlQueryId: Self.mockDcqlQueryId)
  }

  private var presentationDefinition: PresentationDefinition {
    guard let definition = mockRequestObject.presentationDefinition else {
      fatalError("Missing presentation definition fixture")
    }
    return definition
  }

  // swiftlint:enable all

  private func setupMocks() {
    spyKeyManager = KeyManagerProtocolSpy()
    userSession = SessionSpy()
    spyVpTokenGenerator = AnyVpTokenGeneratorProtocolSpy()
    spyCreateAnyCredentialUseCase = CreateAnyCredentialUseCaseProtocolSpy()
    spyAnyDescriptorMapGenerator = AnyDescriptorMapGeneratorProtocolSpy()
    jweEncrypterSpy = JWEEncrypterProtocolSpy()
    analyticsProvider = MockProvider()
    analytics = Analytics()

    Container.shared.keyManager.register { self.spyKeyManager }
    Container.shared.userSession.register { self.userSession }
    Container.shared.anyVpTokenGenerator.register { self.spyVpTokenGenerator }
    Container.shared.createAnyCredentialUseCase.register { self.spyCreateAnyCredentialUseCase }
    Container.shared.anyDescriptorMapGenerator.register { self.spyAnyDescriptorMapGenerator }
    Container.shared.analytics.register { self.analytics }
    Container.shared.jweEncrypter.register { self.jweEncrypterSpy }
    Container.shared.isPayloadEncryptionEnabled.register { true }

    analytics.register(analyticsProvider)

    userSession.isLoggedIn = true
    userSession.context = LAContextProtocolSpy()
  }

  private func success() {
    spyCreateAnyCredentialUseCase.executeFromFormatReturnValue = mockAnyCredential
    spyKeyManager.getKeyPairWithIdentifierAlgorithmQueryReturnValue = mockKeyPair
    spyVpTokenGenerator.generateRequestObjectCredentialKeyPairFieldsReturnValue = Self.mockVpToken
    spyAnyDescriptorMapGenerator.generateUsingVcFormatReturnValue = mockDescriptorMaps
    jweEncrypterSpy.encryptDataPublicKeyEncryptionAlgorithmCompressionAlgorithmReturnValue = Self.mockJweToken
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

  private func makeClientMetadata(jwks: ClientMetadata.JWKs?) throws -> ClientMetadata {
    try ClientMetadata(
      clientName: nil,
      logoUri: nil,
      jwks: jwks,
      encryptedResponseEncValuesSupported: nil)
  }

  private func makeRequestObject(
    queryType: PresentationRequestQueryType,
    responseMode: RequestObject.ResponseMode,
    clientMetadata: ClientMetadata?)
    -> RequestObject
  {
    RequestObject(
      queryType: queryType,
      nonce: "nonce",
      responseUri: URL(string: "https://example.com")!,
      clientMetadata: clientMetadata,
      responseType: "vp_token",
      clientId: "did:example:12345",
      clientIdScheme: "did",
      responseMode: responseMode)
  }
}
