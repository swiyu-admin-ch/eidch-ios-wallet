// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import BITActivity
import BITCredential
import BITNonCompliance
import BITOpenID
import Factory
import XCTest
@testable import BITAnalytics
@testable import BITInvitation
@testable import BITJWT
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - StartProximityEngagementUseCaseTests

@MainActor
final class StartProximityEngagementUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() async throws {
    try await super.setUp()
    registerMocks()
  }

  override func tearDown() async throws {
    Container.shared.reset()
    try await super.tearDown()
  }

  func testCallAsFunction_emitsQrCode_andCallsRepository() async throws {
    proximityPresentationRepository.startEngagementReturnValue = .just(.qrCode("qr-code"))

    useCase = StartProximityEngagementUseCase()

    try await useCase().collectAndAssertEquals([.qrCode("qr-code")])

    XCTAssertTrue(proximityPresentationRepository.startEngagementCalled)
    XCTAssertFalse(proximityPresentationRepository.startEngagementReverseQrCodeCalled)
  }

  func testCallAsFunction_withQrCode_callsRepository() async throws {
    proximityPresentationRepository.startEngagementReverseQrCodeReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: validOrigin))

    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = []

    useCase = StartProximityEngagementUseCase()

    let events = try await useCase(qrCode: "qr-code").collect()
    XCTAssert(events.count == 1)
    if case .request = events.first {
      XCTAssertTrue(proximityPresentationRepository.startEngagementReverseQrCodeCalled)
      XCTAssertFalse(proximityPresentationRepository.startEngagementCalled)
      XCTAssertEqual(proximityPresentationRepository.startEngagementReverseQrCodeReceivedQrCode, "qr-code")
    } else {
      XCTFail("unexpected event")
    }
  }

  func testCallAsFunction_returnsCompatibleCredentials() async throws {
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: validOrigin))

    try await assert_returns_compatible_credentials {
      useCase()
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementCallsCount, 1)
  }

  func testCallAsFunction_withQrCode_returns_compatible_credentials() async throws {
    proximityPresentationRepository.startEngagementReverseQrCodeReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: validOrigin))

    try await assert_returns_compatible_credentials {
      useCase(qrCode: "qr-code")
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementReverseQrCodeCallsCount, 1)
  }

  func testCallAsFunction_decodesJwt() async throws {
    let requestString = try XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8))
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(requestString), origin: validOrigin))

    try await assert_decodesJwt(requestString: requestString) {
      useCase()
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementCallsCount, 1)
  }

  func testCallAsFunction_withQrCode_decodesJwt() async throws {
    let requestString = try XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8))
    proximityPresentationRepository.startEngagementReverseQrCodeReturnValue = try .just(
      .request(requestObject: XCTUnwrap(requestString), origin: validOrigin))

    try await assert_decodesJwt(requestString: requestString) {
      useCase(qrCode: "qr-code")
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementReverseQrCodeCallsCount, 1)
  }

  func testCallAsFunction_throwsInvalidPayload_whenJwtDecodingFails() async throws {
    jwsDecoderSpy.throwingError = TestingError.error
    let decoder = try XCTUnwrap(jwsDecoderSpy)
    Container.shared.jwsDecoder.register { @MainActor in decoder }
    proximityPresentationRepository.startEngagementReturnValue = .just(.request(requestObject: "not-a-valid-jwt", origin: nil))
    useCase = StartProximityEngagementUseCase()

    do {
      _ = try await useCase().collect()
      XCTFail("Expected callAsFunction to throw")
    } catch {
      XCTAssertEqual(error as? StartProximityEngagementUseCaseError, .invalidRequest("invalid_request"))
    }
  }

  func testCallAsFunction_callsRequestObjectValidatorForProximity() async throws {
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: validOrigin))
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = []
    useCase = StartProximityEngagementUseCase()

    _ = try await useCase().collect()

    XCTAssertEqual(requestObjectValidatorSpy.validateTransportCallsCount, 1)
    XCTAssertEqual(requestObjectValidatorSpy.validateTransportReceivedArguments?.transport, .proximity)
  }

  func testCallAsFunction_setsTrustedCheckAppContext() async throws {
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: validOrigin))
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = []
    useCase = StartProximityEngagementUseCase()

    let events = try await useCase().collect()
    guard case .request(let context) = events.first else {
      return XCTFail("Expected .request event")
    }
    XCTAssertEqual(context.trustInformation.identity, .trustedCheckApp)
    XCTAssertEqual(context.trustInformation.vcSchema, .trusted)
    XCTAssertEqual(context.actorCompliance, .compliant)
    XCTAssertFalse(proximityPresentationRepository.declineCalled)
  }

  func testCallAsFunction_throwsInvalidRequest_whenRequestObjectValidationFails() async throws {
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: validOrigin))
    requestObjectValidatorSpy.validateTransportThrowableError = TestingError.error
    useCase = StartProximityEngagementUseCase()

    do {
      _ = try await useCase().collect()
      XCTFail("Expected callAsFunction to throw")
    } catch {
      XCTAssertEqual(error as? StartProximityEngagementUseCaseError, .invalidRequest("invalid_request"))
    }
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount, 0)
  }

  func testCallAsFunction_throwsInvalidOrigin_andDeclines_whenOriginIsNil() async throws {
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: nil))
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = []
    useCase = StartProximityEngagementUseCase()

    do {
      _ = try await useCase().collect()
      XCTFail("Expected callAsFunction to throw")
    } catch {
      XCTAssertEqual(error as? StartProximityEngagementUseCaseError, .invalidRequest("invalid_request"))
    }

    XCTAssertTrue(proximityPresentationRepository.declineCalled)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount, 0)
    XCTAssertEqual(analyticsProvider.logCounter, 1)
  }

  func testCallAsFunction_throwsInvalidOrigin_andDeclines_whenOriginNotInExpectedOrigins() async throws {
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: "https://malicious.example"))
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = []
    useCase = StartProximityEngagementUseCase()

    do {
      _ = try await useCase().collect()
      XCTFail("Expected callAsFunction to throw")
    } catch {
      XCTAssertEqual(error as? StartProximityEngagementUseCaseError, .invalidRequest("invalid_request"))
    }

    XCTAssertTrue(proximityPresentationRepository.declineCalled)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount, 0)
    XCTAssertEqual(analyticsProvider.logCounter, 1)
  }

  func testCallAsFunction_throwsInvalidOrigin_andDeclines_whenExpectedOriginsAbsent() async throws {
    // The network request object (`sampleJWT`) carries no `expected_origins`, so any origin must be rejected.
    Container.shared.jwsDecoder.register { @MainActor in
      JWSDecoderMock<RequestObjectJWT>(jwt: RequestObjectJWS.Mock.sampleJWT, rawPayload: "rawPayload")
    }
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(requestObject: XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8)), origin: validOrigin))
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = []
    useCase = StartProximityEngagementUseCase()

    do {
      _ = try await useCase().collect()
      XCTFail("Expected callAsFunction to throw")
    } catch {
      XCTAssertEqual(error as? StartProximityEngagementUseCaseError, .invalidRequest("invalid_request"))
    }

    XCTAssertTrue(proximityPresentationRepository.declineCalled)
    XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount, 0)
    XCTAssertEqual(analyticsProvider.logCounter, 1)
  }

  // MARK: Private

  /// Matches the single entry in `expected_origins` of the `request-object-dc-api-proximity` fixture.
  private let validOrigin = "iso18013-5://test"

  private var proximityPresentationRepository: ProximityPresentationRepositoryProtocolSpy!
  private var getCompatibleCredentialsUseCaseSpy: GetCompatibleCredentialsUseCaseProtocolSpy!
  private var jwsDecoderSpy: JWSDecoderMock<RequestObjectJWT>!
  private var requestObjectValidatorSpy: RequestObjectValidatorProtocolSpy!
  private var useCase: StartProximityEngagementUseCase!
  private var analytics: AnalyticsProtocol!
  private var analyticsProvider: MockProvider!

  private func assert_returns_compatible_credentials(stream: () -> AsyncThrowingStream<ProximityEngagementEvent, Error>) async throws {
    let mockCredentials = [CompatibleCredential.Mock.BIT]
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = mockCredentials

    useCase = StartProximityEngagementUseCase()

    let events = try await stream().collect()

    if case .request(let request) = events.first {
      XCTAssertEqual(request.transport, .proximity)
      XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingCallsCount, 1)
      XCTAssertEqual(request.compatibleCredentials, mockCredentials)
    } else {
      XCTFail("unexpected event")
    }
  }

  private func assert_decodesJwt(
    requestString: String,
    stream: () -> AsyncThrowingStream<ProximityEngagementEvent, Error>) async throws
  {
    getCompatibleCredentialsUseCaseSpy.callAsFunctionUsingReturnValue = []

    let decoder = JWSDecoderMock<RequestObjectJWT>(
      jwt: RequestObjectJWS.Mock.sampleProximityDcApiJWT.payload,
      rawPayload: "rawPayload",
      expectedInput: requestString)

    Container.shared.jwsDecoder.register { @MainActor in decoder }

    useCase = StartProximityEngagementUseCase()

    let events = try await stream().collect()

    let first = try XCTUnwrap(events.first)

    guard case .request = first else {
      return XCTFail("Expected .request, got \(first)")
    }
  }

  private func registerMocks() {
    let proximityPresentationRepository = ProximityPresentationRepositoryProtocolSpy()
    self.proximityPresentationRepository = proximityPresentationRepository
    let getCompatibleCredentialsUseCaseSpy = GetCompatibleCredentialsUseCaseProtocolSpy()
    self.getCompatibleCredentialsUseCaseSpy = getCompatibleCredentialsUseCaseSpy
    let jwsDecoderSpy = JWSDecoderMock<RequestObjectJWT>(jwt: RequestObjectJWS.Mock.sampleProximityDcApi.payload, rawPayload: "rawPayload")
    self.jwsDecoderSpy = jwsDecoderSpy
    let requestObjectValidatorSpy = RequestObjectValidatorProtocolSpy()
    self.requestObjectValidatorSpy = requestObjectValidatorSpy
    let analyticsProvider = MockProvider()
    self.analyticsProvider = analyticsProvider
    let analytics = AnalyticsSpy()
    self.analytics = analytics
    analytics.register(analyticsProvider)

    Container.shared.proximityPresentationRepository.register { @MainActor in proximityPresentationRepository }
    Container.shared.getCompatibleCredentialsUseCase.register { @MainActor in getCompatibleCredentialsUseCaseSpy }
    Container.shared.jwsDecoder.register { @MainActor in jwsDecoderSpy }
    Container.shared.requestObjectValidator.register { @MainActor in requestObjectValidatorSpy }
    Container.shared.analytics.register { @MainActor in analytics }
  }
}
