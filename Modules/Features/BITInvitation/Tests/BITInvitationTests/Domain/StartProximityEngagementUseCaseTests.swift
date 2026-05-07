// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
import BITOpenID
import Factory
import XCTest
@testable import BITInvitation
@testable import BITJWT
@testable import BITPresentation
@testable import BITTestingCore

// MARK: - StartProximityEngagementUseCaseTests

@MainActor
final class StartProximityEngagementUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
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
      .request(XCTUnwrap(String(data: RequestObject.Mock.VcSdJwt.jsonSampleData, encoding: .utf8))))

    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = []

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
      .request(XCTUnwrap(String(data: RequestObject.Mock.VcSdJwt.jsonSampleData, encoding: .utf8))))

    try await assert_returns_compatible_credentials {
      useCase()
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementCallsCount, 1)
  }

  func testCallAsFunction_withQrCode_returns_compatible_credentials() async throws {
    proximityPresentationRepository.startEngagementReverseQrCodeReturnValue = try .just(
      .request(XCTUnwrap(String(data: RequestObject.Mock.VcSdJwt.jsonSampleData, encoding: .utf8))))

    try await assert_returns_compatible_credentials {
      useCase(qrCode: "qr-code")
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementReverseQrCodeCallsCount, 1)
  }

  func testCallAsFunction_decodesJwt() async throws {
    let requestString = try XCTUnwrap(String(data: RequestObject.Mock.VcSdJwt.jsonSampleData, encoding: .utf8))
    proximityPresentationRepository.startEngagementReturnValue = try .just(
      .request(XCTUnwrap(requestString)))

    try await assert_decodesJwt(requestString: requestString) {
      useCase()
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementCallsCount, 1)
  }

  func testCallAsFunction_withQrCode_decodesJwt() async throws {
    let requestString = try XCTUnwrap(String(data: RequestObject.Mock.VcSdJwt.jsonSampleData, encoding: .utf8))
    proximityPresentationRepository.startEngagementReverseQrCodeReturnValue = try .just(
      .request(XCTUnwrap(requestString)))

    try await assert_decodesJwt(requestString: requestString) {
      useCase(qrCode: "qr-code")
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementReverseQrCodeCallsCount, 1)
  }

  func testCallAsFunction_decodesJson_whenJwtDecodingFails() async throws {
    let requestString = try XCTUnwrap(String(data: RequestObject.Mock.VcSdJwt.jsonSampleData, encoding: .utf8))
    proximityPresentationRepository.startEngagementReturnValue = .just(.request(requestString))

    try await assert_decodesJson_whenJwtDecodingFails {
      useCase()
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementCallsCount, 1)
  }

  func testCallAsFunction_withQrCodeJwtDecodingFails_decodesJson() async throws {
    let requestString = try XCTUnwrap(String(data: RequestObject.Mock.VcSdJwt.jsonSampleData, encoding: .utf8))
    proximityPresentationRepository.startEngagementReverseQrCodeReturnValue = .just(.request(requestString))

    try await assert_decodesJson_whenJwtDecodingFails {
      useCase(qrCode: "qr-code")
    }

    XCTAssertEqual(proximityPresentationRepository.startEngagementReverseQrCodeCallsCount, 1)
  }

  func testCallAsFunction_throwsInvalidPayload_whenJwtAndJsonDecodingFail() async throws {
    try await assert_throwsInvalidPayload_whenJwtAndJsonDecodingFail {
      proximityPresentationRepository.startEngagementReturnValue = .just(.request($0))
    } stream: {
      useCase()
    }
  }

  func testCallAsFunction_withQrCode_throwsInvalidPayload_whenJwtAndJsonDecodingFail() async throws {
    try await assert_throwsInvalidPayload_whenJwtAndJsonDecodingFail {
      proximityPresentationRepository.startEngagementReverseQrCodeReturnValue = .just(.request($0))
    } stream: {
      useCase(qrCode: "qr-code")
    }
  }

  // MARK: Private

  private var proximityPresentationRepository: ProximityPresentationRepositoryProtocolSpy!
  private var getCompatibleCredentialsUseCaseSpy: GetCompatibleCredentialsUseCaseProtocolSpy!
  private var useCase: StartProximityEngagementUseCase!

  private func assert_decodesJson_whenJwtDecodingFails(stream: () -> AsyncThrowingStream<ProximityEngagementEvent, Error>) async throws {
    Container.shared.jwsDecoder.register {
      JWSDecoderMock<RequestObjectJWT>(
        jwt: nil,
        rawPayload: nil,
        throwingError: TestingError.error)
    }

    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = []

    useCase = StartProximityEngagementUseCase()

    let events = try await stream().collect()

    let first = try XCTUnwrap(events.first)

    guard case .request = first else {
      return XCTFail("Expected .request, got \(first)")
    }
  }

  private func assert_throwsInvalidPayload_whenJwtAndJsonDecodingFail(
    setReturnValue: (String) -> Void,
    stream: () -> AsyncThrowingStream<ProximityEngagementEvent, Error>) async throws
  {
    let jwtString = "not-a-valid-jwt"

    Container.shared.jwsDecoder.register {
      JWSDecoderMock(
        jwt: RequestObjectJWS.Mock.sampleJWT,
        rawPayload: "rawPayload",
        expectedInput: jwtString,
        throwingError: TestingError.error)
    }

    setReturnValue(jwtString)

    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = []

    useCase = StartProximityEngagementUseCase()

    do {
      _ = try await stream().collect()
      XCTFail("Expected callAsFunction to throw")
    } catch {
      XCTAssertEqual(error as? RequestObjectError, .invalidPayload())
    }
  }

  private func assert_returns_compatible_credentials(stream: () -> AsyncThrowingStream<ProximityEngagementEvent, Error>) async throws {
    let mockCredentials = [CompatibleCredential.Mock.BIT]
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = mockCredentials

    useCase = StartProximityEngagementUseCase()

    let events = try await stream().collect()

    if case .request(let request) = events.first {
      XCTAssertEqual(request.transport, .proximity)
      XCTAssertEqual(getCompatibleCredentialsUseCaseSpy.executeUsingCallsCount, 1)
      XCTAssertEqual(request.compatibleCredentials, mockCredentials)
    } else {
      XCTFail("unexpected event")
    }
  }

  private func assert_decodesJwt(
    requestString: String,
    stream: () -> AsyncThrowingStream<ProximityEngagementEvent, Error>) async throws
  {
    getCompatibleCredentialsUseCaseSpy.executeUsingReturnValue = []

    let decoder = JWSDecoderMock<RequestObjectJWT>(
      jwt: RequestObjectJWS.Mock.sampleJWT,
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
    proximityPresentationRepository = ProximityPresentationRepositoryProtocolSpy()
    getCompatibleCredentialsUseCaseSpy = GetCompatibleCredentialsUseCaseProtocolSpy()

    Container.shared.proximityPresentationRepository.register { @MainActor in self.proximityPresentationRepository }
    Container.shared.getCompatibleCredentialsUseCase.register { @MainActor in self.getCompatibleCredentialsUseCaseSpy }
  }
}
