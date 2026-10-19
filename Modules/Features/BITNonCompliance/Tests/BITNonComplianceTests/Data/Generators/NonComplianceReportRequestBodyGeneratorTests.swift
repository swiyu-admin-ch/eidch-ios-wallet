import BITActivity
import Factory
import Foundation
import Testing
@testable import BITCredentialShared
@testable import BITJWT
@testable import BITNonCompliance
@testable import BITOpenID
@testable import BITTestingCore

struct NonComplianceReportRequestBodyGeneratorTests {

  // MARK: Lifecycle

  init() {
    let jwsDecoder = JWSDecoderMock(jwt: payloadMock, rawPayload: "rawPayload")
    self.jwsDecoder = jwsDecoder

    let languageMock = "de"

    Container.shared.jwsDecoder.register { jwsDecoder }
    Container.shared.preferredUserLanguageCodes.register { [languageMock] }

    generator = NonComplianceReportRequestBodyGenerator()
  }

  // MARK: Internal

  @Test
  func generate_jwtRequestObject_returnsBody() throws {
    let nonComplianceData = "jwt_request_object"
    var jwsDecoder = JWSDecoderMock(jwt: payloadMock, rawPayload: "rawPayload")
    jwsDecoder.expectedInput = nonComplianceData

    let activityMock = createActivity(nonComplianceData: nonComplianceData)

    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    let body = try #require(generator.generate(from: report) as? NonComplianceExcessiveDataReportBody)

    #expect(body.description == descriptionMock)
    #expect(body.email == emailMock)
    #expect(body.language == languageMock)
    #expect(body.metadata.verifierDid == payloadMock.clientIdentifier.clientId)
    #expect(body.metadata.verifierUrl == payloadMock.responseUri?.absoluteString)
    #expect(body.metadata.presentationActionCreatedAt == Self.createdAtMock)
    #expect(body.metadata.presentedCredentialIssuerDid == Self.issuerMock)
    #expect(body.metadata.presentationRequestJwt == nonComplianceData)
    assertRequestFields(body.metadata.presentationRequestFields)
  }

  @Test
  func generate_plainRequestObject_returnsBody() throws {
    let nonComplianceData = try #require(String(data: RequestObjectJWS.Mock.sampleData, encoding: .utf8))
    let activityMock = createActivity(nonComplianceData: nonComplianceData)
    var jwsDecoder = JWSDecoderMock(jwt: payloadMock, rawPayload: "rawPayload")
    jwsDecoder.throwingError = TestingError.error
    let generator = NonComplianceReportRequestBodyGenerator()

    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    let body = try #require(generator.generate(from: report) as? NonComplianceExcessiveDataReportBody)

    #expect(body.description == descriptionMock)
    #expect(body.email == emailMock)
    #expect(body.language == languageMock)
    #expect(body.metadata.verifierDid == requestObjectMock.clientIdentifier.clientId)
    #expect(body.metadata.verifierUrl == requestObjectMock.responseUri?.absoluteString)
    #expect(body.metadata.presentationActionCreatedAt == Self.createdAtMock)
    #expect(body.metadata.presentedCredentialIssuerDid == Self.issuerMock)
    #expect(body.metadata.presentationRequestJwt == nonComplianceData)
    assertRequestFields(body.metadata.presentationRequestFields)
  }

  @Test
  func generate_requestObjectWithConstraints_returnsFieldConstraints() throws {
    let nonComplianceData = try #require(String(data: RequestObjectJWS.Mock.withConstraintsData, encoding: .utf8))
    let activityMock = createActivity(nonComplianceData: nonComplianceData)
    var jwsDecoder = JWSDecoderMock(jwt: payloadMock, rawPayload: "rawPayload")
    jwsDecoder.throwingError = TestingError.error
    Container.shared.jwsDecoder.register { [jwsDecoder] in jwsDecoder }
    let generator = NonComplianceReportRequestBodyGenerator()

    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    let body = try #require(generator.generate(from: report) as? NonComplianceExcessiveDataReportBody)

    #expect(body.metadata.presentationRequestFields == [
      NonComplianceExcessiveDataReportBody.Field(name: "vct", constraint: "pid-vct, pid-vct-alt"),
      NonComplianceExcessiveDataReportBody.Field(name: "[\"firstName\"]", constraint: "\"Ada\", \"Bea\""),
      NonComplianceExcessiveDataReportBody.Field(name: "[\"age\"]", constraint: "42"),
    ])
  }

  @Test
  func generate_missingRequestObject_throwsDecodingError() {
    let activityMock = createActivity(nonComplianceData: nil)
    let report = NonComplianceExcessiveDataReport(description: descriptionMock, email: emailMock, activity: activityMock)

    #expect(throws: NonComplianceReportRequestBodyGeneratorError.requestObjectDecodingFailed) {
      try generator.generate(from: report)
    }
  }

  @Test
  func generate_wrongReportType_throwsWrongCategoryError() {
    struct FakeReport: NonComplianceReport { let category = NonComplianceCategory.excessiveDataRequest }

    #expect(throws: NonComplianceReportRequestBodyGeneratorError.wrongReportCategory) {
      try generator.generate(from: FakeReport())
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

  private var jwsDecoder: JWSDecoderMock<RequestObjectJWT>
  private var generator: NonComplianceReportRequestBodyGenerator

  private func createActivity(nonComplianceData: String? = nil, createdAt: Date = createdAtMock, issuer: String = issuerMock) -> NonComplianceActivity {
    NonComplianceActivity(nonComplianceData: nonComplianceData, createdAt: createdAt, issuer: issuer)
  }

  private func assertRequestFields(_ fields: [NonComplianceExcessiveDataReportBody.Field]) {
    guard fields.count == 6 else {
      fatalError("Unexpected number of fields: \(fields.count)")
    }

    #expect(fields[0].name == "vct")
    #expect(fields[0].constraint == "vcSchemaId")
    #expect(fields[1].name == "[\"firstName\"]")
    #expect(fields[2].name == "[\"lastName\"]")
    #expect(fields[3].name == "[\"dateOfBirth\"]")
    #expect(fields[4].name == "[\"hometown\"]")
    #expect(fields[5].name == "[\"categoryCode\"]")
  }
}
