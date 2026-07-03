import BITActivity
import Factory
import XCTest
@testable import BITCredentialShared
@testable import BITJWT
@testable import BITNonCompliance
@testable import BITOpenID
@testable import BITTestingCore

// swiftlint: disable implicitly_unwrapped_optional force_unwrapping

final class NonComplianceReportRequestBodyGeneratorTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    super.setUp()
    Container.shared.reset()
    registerMocks()
    generator = NonComplianceReportRequestBodyGenerator()
  }

  func testGenerate_jwtRequestObject_returnsBody() throws {
    let nonComplianceData = "jwt_request_object"
    jwsDecoder.expectedInput = nonComplianceData
    let activityMock = createActivity(nonComplianceData: nonComplianceData)

    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    let body = try XCTUnwrap(generator.generate(from: report) as? NonComplianceExcessiveDataReportBody)

    XCTAssertEqual(body.description, descriptionMock)
    XCTAssertEqual(body.email, emailMock)
    XCTAssertEqual(body.language, languageMock)
    XCTAssertEqual(body.metadata.verifierDid, payloadMock.clientId)
    XCTAssertEqual(body.metadata.verifierUrl, payloadMock.responseUri?.absoluteString)
    XCTAssertEqual(body.metadata.presentationActionCreatedAt, Self.createdAtMock)
    XCTAssertEqual(body.metadata.presentedCredentialIssuerDid, Self.issuerMock)
    XCTAssertEqual(body.metadata.presentationRequestJwt, nonComplianceData)
    assertRequestFields(body.metadata.presentationRequestFields)
  }

  func testGenerate_plainRequestObject_returnsBody() throws {
    let nonComplianceData = try XCTUnwrap(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8))
    let activityMock = createActivity(nonComplianceData: nonComplianceData)
    jwsDecoder.throwingError = TestingError.error
    generator = NonComplianceReportRequestBodyGenerator()

    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    let body = try XCTUnwrap(generator.generate(from: report) as? NonComplianceExcessiveDataReportBody)

    XCTAssertEqual(body.description, descriptionMock)
    XCTAssertEqual(body.email, emailMock)
    XCTAssertEqual(body.language, languageMock)
    XCTAssertEqual(body.metadata.verifierDid, requestObjectMock.clientId)
    XCTAssertEqual(body.metadata.verifierUrl, requestObjectMock.responseUri?.absoluteString)
    XCTAssertEqual(body.metadata.presentationActionCreatedAt, Self.createdAtMock)
    XCTAssertEqual(body.metadata.presentedCredentialIssuerDid, Self.issuerMock)
    XCTAssertEqual(body.metadata.presentationRequestJwt, nonComplianceData)
    assertRequestFields(body.metadata.presentationRequestFields)
  }

  func testGenerate_requestObjectWithConstraints_returnsFieldConstraints() throws {
    let nonComplianceData = try XCTUnwrap(String(data: RequestObjectJWS.Mock.withConstraintsData, encoding: .utf8))
    let activityMock = createActivity(nonComplianceData: nonComplianceData)
    jwsDecoder.throwingError = TestingError.error
    generator = NonComplianceReportRequestBodyGenerator()

    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    let body = try XCTUnwrap(generator.generate(from: report) as? NonComplianceExcessiveDataReportBody)

    XCTAssertEqual(body.metadata.presentationRequestFields, [
      NonComplianceExcessiveDataReportBody.Field(name: "vct", constraint: "pid-vct, pid-vct-alt"),
      NonComplianceExcessiveDataReportBody.Field(name: "[\"firstName\"]", constraint: "\"Ada\", \"Bea\""),
      NonComplianceExcessiveDataReportBody.Field(name: "[\"age\"]", constraint: "42"),
    ])
  }

  func testGenerate_missingRequestObject_throwsDecodingError() {
    let activityMock = createActivity(nonComplianceData: nil)
    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    XCTAssertThrowsError(try generator.generate(from: report)) { error in
      XCTAssertEqual(error as? NonComplianceReportRequestBodyGeneratorError, .requestObjectDecodingFailed)
    }
  }

  func testGenerate_wrongReportType_throwsWrongCategoryError() {
    struct FakeReport: NonComplianceReport { let category = NonComplianceCategory.excessiveDataRequest }

    XCTAssertThrowsError(try generator.generate(from: FakeReport())) { error in
      XCTAssertEqual(error as? NonComplianceReportRequestBodyGeneratorError, .wrongReportCategory)
    }
  }

  // MARK: Private

  private static let createdAtMock = Date()
  private static let issuerMock = "issuer"

  private let descriptionMock = String(repeating: "x", count: 20)
  private let emailMock = "email@example.org"
  private let languageMock = "de"
  private let requestObjectMock = RequestObjectJWS.Mock.sample.payload
  private var payloadMock = RequestObjectJWS.Mock.sampleJWT

  private var generator: NonComplianceReportRequestBodyGenerator!
  private var jwsDecoder: JWSDecoderMock<RequestObjectJWT>!

  private func registerMocks() {
    jwsDecoder = JWSDecoderMock(jwt: payloadMock, rawPayload: "rawPayload")
    Container.shared.jwsDecoder.register { self.jwsDecoder }
    Container.shared.preferredUserLanguageCodes.register { [self.languageMock] }
  }

  private func createActivity(nonComplianceData: String? = nil, createdAt: Date = createdAtMock, issuer: String = issuerMock) -> NonComplianceActivity {
    NonComplianceActivity(nonComplianceData: nonComplianceData, createdAt: createdAt, issuer: issuer)
  }

  private func assertRequestFields(_ fields: [NonComplianceExcessiveDataReportBody.Field]) {
    guard fields.count == 6 else {
      XCTFail("Unexpected number of fields: \(fields.count)")
      return
    }
    XCTAssertEqual(fields[0].name, "vct")
    XCTAssertEqual(fields[0].constraint, "vcSchemaId")
    XCTAssertEqual(fields[1].name, "[\"firstName\"]")
    XCTAssertEqual(fields[2].name, "[\"lastName\"]")
    XCTAssertEqual(fields[3].name, "[\"dateOfBirth\"]")
    XCTAssertEqual(fields[4].name, "[\"hometown\"]")
    XCTAssertEqual(fields[5].name, "[\"categoryCode\"]")
  }
}
