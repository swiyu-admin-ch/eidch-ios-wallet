import BITNetworking
import Factory
import Spyable
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint: disable force_unwrapping implicitly_unwrapped_optional

final class FetchRequestObjectUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()

    repositorySpy = OpenIDRepositoryProtocolSpy()
    jwsDecoderMock = JWSDecoderMock(payload: RequestObject.Mock.VcSdJwt.sample, rawPayload: "rawPayload")

    Container.shared.openIDRepository.register { self.repositorySpy }
    Container.shared.jwsDecoder.register { self.jwsDecoderMock }

    useCase = FetchRequestObjectUseCase()
  }

  func testFetchJwtRequestObject_Success() async throws {
    repositorySpy.fetchRequestObjectFromReturnValue = Self.jwsDataMock
    let jwtRequestObjectMock = JWTRequestObject.Mock.sample
    jwsDecoderMock = JWSDecoderMock(payload: jwtRequestObjectMock.jws.payload, rawPayload: jwtRequestObjectMock.jws.rawPayload)
    jwsDecoderMock.expectedInput = Self.jwsStringMock
    useCase = FetchRequestObjectUseCase()

    let requestObject = try await useCase.execute(mockUrl)

    XCTAssertEqual(requestObject.nonce, mockNonce)
    XCTAssertTrue(requestObject is JWTRequestObject)
    XCTAssertNotNil((requestObject as? JWTRequestObject)?.jws)
    XCTAssertEqual(repositorySpy.fetchRequestObjectFromReceivedUrl, mockUrl)
  }

  func testFetchJsonRequestObject_Success() async throws {
    repositorySpy.fetchRequestObjectFromReturnValue = RequestObject.Mock.VcSdJwt.jsonSampleData
    jwsDecoderMock.throwingError = TestingError.error
    useCase = FetchRequestObjectUseCase()

    let requestObject = try await useCase.execute(mockUrl)

    XCTAssertEqual(requestObject.nonce, mockNonce)
    XCTAssertFalse(requestObject is JWTRequestObject)
    XCTAssertEqual(repositorySpy.fetchRequestObjectFromReceivedUrl, mockUrl)
  }

  func testFetchRequestObject_DecodingError_Failure() async throws {
    repositorySpy.fetchRequestObjectFromReturnValue = "invalid".data(using: .utf8)
    jwsDecoderMock.throwingError = TestingError.error
    useCase = FetchRequestObjectUseCase()

    do {
      _ = try await useCase.execute(mockUrl)
      XCTFail("Should have thrown an exception")
    } catch FetchRequestObjectError.invalid {
      XCTAssertTrue(repositorySpy.fetchRequestObjectFromCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  func testFetchRequestObject_PresentationProcessClosed_Failure() async throws {
    repositorySpy.fetchRequestObjectFromThrowableError = OpenIdRepositoryError.presentationProcessClosed

    do {
      _ = try await useCase.execute(mockUrl)
      XCTFail("Should have thrown an exception")
    } catch FetchRequestObjectError.expired {
      XCTAssertTrue(repositorySpy.fetchRequestObjectFromCalled)
    } catch {
      XCTFail("No the expected execution")
    }
  }

  func testFetchRequestObject_AuthorizationRequestObjectNotFound_Failure() async throws {
    repositorySpy.fetchRequestObjectFromThrowableError = OpenIdRepositoryError.authorizationRequestObjectNotFound

    do {
      _ = try await useCase.execute(mockUrl)
      XCTFail("Should have thrown an exception")
    } catch FetchRequestObjectError.invalid {
      XCTAssertTrue(repositorySpy.fetchRequestObjectFromCalled)
    } catch {
      XCTFail("No the expected execution")
    }
  }

  func testFetchRequestObject_Failure() async throws {
    repositorySpy.fetchRequestObjectFromThrowableError = TestingError.error

    do {
      _ = try await useCase.execute(mockUrl)
      XCTFail("Should have thrown an exception")
    } catch TestingError.error {
      XCTAssertTrue(repositorySpy.fetchRequestObjectFromCalled)
    } catch {
      XCTFail("Not the error expected")
    }
  }

  // MARK: Private

  private static let jwsStringMock = "jwsMock"
  private static let jwsDataMock = jwsStringMock.data(using: .utf8)!

  private let mockUrl = URL(string: "some://url")!
  private let mockNonce = "nonce"
  private var useCase = FetchRequestObjectUseCase()
  private var repositorySpy = OpenIDRepositoryProtocolSpy()
  private var jwsDecoderMock: JWSDecoderMock<RequestObject>!
}

// swiftlint: enable all
