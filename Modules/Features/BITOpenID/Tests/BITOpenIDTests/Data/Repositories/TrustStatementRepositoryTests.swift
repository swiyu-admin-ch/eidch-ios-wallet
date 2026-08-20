// swiftlint: disable force_unwrapping implicitly_unwrapped_optional
import BITCore
import BITNetworking
import Factory
import XCTest
@testable import BITJWT
@testable import BITOpenID
@testable import BITSdJWT
@testable import BITTestingCore

// MARK: - TrustStatementRepositoryTests

final class TrustStatementRepositoryTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    createSuccessState()
    repository = TrustStatementRepository()
  }

  // MARK: - fetchIdentityTrustStatements

  func testFetchIdentityTrustStatements_multipleStatements_returnsAll() async throws {
    let expectedStatements = [rawTrustStatement1Mock, rawTrustStatement2Mock]
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    let trustStatements = try await repository.fetchIdentityTrustStatements(from: urlMock, for: subjectDidMock)

    XCTAssertEqual(trustStatements.count, 2)
    XCTAssertEqual(trustStatements[0], trustStatement1Mock)
    XCTAssertEqual(trustStatements[1], trustStatement2Mock)
  }

  func testFetchIdentityTrustStatements_decodingError_throwsError() async throws {
    let expectedStatements = [rawTrustStatement1Mock]
    vcSdJwsDecoderMock.decodeFromThrowableError = TestingError.error
    let mockStatementData = try JSONEncoder().encode(expectedStatements)
    mockResponse(code: 200, data: mockStatementData)

    do {
      _ = try await repository.fetchIdentityTrustStatements(from: urlMock, for: subjectDidMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchIdentityTrustStatements_serverError_throwsServerError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchIdentityTrustStatements(from: urlMock, for: subjectDidMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: - fetchProtectedIssuanceTrustListStatement

  func testFetchProtectedIssuanceTrustListStatement_success_returnsStatement() async throws {
    mockResponse(code: 200, data: ProtectedIssuanceTrustListStatementJWT.Mock.rawJWSData)

    let trustStatement = try await repository.fetchProtectedIssuanceTrustListStatement(for: subjectDidMock)

    XCTAssertEqual(mapperSpy.mapDidCallsCount, 1)
    XCTAssertEqual(mapperSpy.mapDidReceivedDid, subjectDidMock)
    XCTAssertEqual(trustStatement, protectedIssuanceTrustListStatementMock)
  }

  func testFetchProtectedIssuanceTrustListStatement_decodingError_throwsError() async throws {
    var jwsDecoderMock = makeJwsDecoderMock()
    jwsDecoderMock.throwingError = TestingError.error
    Container.shared.jwsDecoder.register { jwsDecoderMock }
    repository = TrustStatementRepository()
    mockResponse(code: 200, data: ProtectedIssuanceTrustListStatementJWT.Mock.rawJWSData)

    do {
      _ = try await repository.fetchProtectedIssuanceTrustListStatement(for: subjectDidMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchProtectedIssuanceTrustListStatement_urlMapperThrows_throwsError() async throws {
    mapperSpy.mapDidThrowableError = TestingError.error
    mockResponse(code: 200, data: ProtectedIssuanceTrustListStatementJWT.Mock.rawJWSData)

    do {
      _ = try await repository.fetchProtectedIssuanceTrustListStatement(for: subjectDidMock)
      XCTFail("Should have thrown an error")
    } catch {
      XCTAssertEqual(error as? TestingError, .error)
    }
  }

  func testFetchProtectedIssuanceTrustListStatement_serverError_throwsServerError() async throws {
    mockResponse(code: 500)

    do {
      _ = try await repository.fetchProtectedIssuanceTrustListStatement(for: subjectDidMock)
      XCTFail("Should have thrown an error")
    } catch {
      guard let error = error as? NetworkError else { return XCTFail("Expected a NetworkError") }
      XCTAssertEqual(error.status, .internalServerError)
    }
  }

  // MARK: Private

  private let urlMock = URL(string: "some://url")!
  private let trustRegistryURLMock = URL(string: "https://example.com")!
  private let subjectDidMock = "did:example:subject"
  private let rawTrustStatement1Mock = "trustStatement1"
  private let rawTrustStatement2Mock = "trustStatement2"
  private let trustStatement1Mock = IdentityTrustStatementV1JWT.Mock.validSample
  private let trustStatement2Mock = IdentityTrustStatementV1JWT.Mock.validSampleItalian
  private let protectedIssuanceTrustListStatementMock = ProtectedIssuanceTrustListStatementJWT.Mock.sample

  private var mapperSpy: TrustRegistryUrlMapperProtocolSpy!
  private var vcSdJwsDecoderMock: VcSdJWSDecoderMock<IdentityTrustStatementV1JWT>!
  private var repository: TrustStatementRepository!

  private func registerMocks() {
    NetworkContainer.shared.reset()
    NetworkContainer.shared.stubClosure.register {
      { _ in .immediate }
    }

    mapperSpy = TrustRegistryUrlMapperProtocolSpy()
    vcSdJwsDecoderMock = VcSdJWSDecoderMock()
    let jwsDecoderMock = makeJwsDecoderMock()

    Container.shared.trustRegistryUrlMapper.register { self.mapperSpy }
    Container.shared.vcSdJwsDecoder.register { self.vcSdJwsDecoderMock }
    Container.shared.jwsDecoder.register { jwsDecoderMock }
  }

  private func createSuccessState() {
    mapperSpy.mapDidReturnValue = trustRegistryURLMock
    vcSdJwsDecoderMock.decodeFromClosure = { data in
      let string = String(decoding: data, as: UTF8.self)
      switch string {
      case self.rawTrustStatement1Mock:
        return self.trustStatement1Mock
      case self.rawTrustStatement2Mock:
        return self.trustStatement2Mock
      default:
        fatalError("Unexpected string in decoding: \(string)")
      }
    }
  }

  private func makeJwsDecoderMock() -> JWSDecoderMock<ProtectedIssuanceTrustListStatementJWT> {
    var jwsDecoderMock = JWSDecoderMock(
      jwt: protectedIssuanceTrustListStatementMock.payload,
      rawPayload: protectedIssuanceTrustListStatementMock.rawPayload,
      expectedInput: ProtectedIssuanceTrustListStatementJWT.Mock.rawJWS)
    jwsDecoderMock.header = protectedIssuanceTrustListStatementMock.header
    return jwsDecoderMock
  }

  private func mockResponse(code: Int, data: Data = Data()) {
    NetworkContainer.shared.endpointClosure.register {
      .networkResponse(code, data)
    }
  }
}
