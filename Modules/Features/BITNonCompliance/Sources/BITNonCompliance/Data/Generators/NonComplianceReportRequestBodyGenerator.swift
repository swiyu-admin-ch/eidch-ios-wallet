import BITJWT
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - NonComplianceReportRequestBodyGeneratorError

enum NonComplianceReportRequestBodyGeneratorError: Error {
  case wrongReportCategory
  case requestObjectDecodingFailed
}

// MARK: - NonComplianceReportRequestBodyGeneratorProtocol

@Spyable
protocol NonComplianceReportRequestBodyGeneratorProtocol {
  func generate(from report: NonComplianceReport) throws -> any Encodable
}

// MARK: - NonComplianceReportRequestBodyGenerator

struct NonComplianceReportRequestBodyGenerator: NonComplianceReportRequestBodyGeneratorProtocol {

  // MARK: Internal

  func generate(from report: NonComplianceReport) throws -> any Encodable {
    switch report.category {
    case .excessiveDataRequest:
      try buildExcessiveDataReportBody(from: report)
    }
  }

  // MARK: Private

  @Injected(\.jwsDecoder) private var jwsDecoder: JWSDecoderProtocol

  private func buildExcessiveDataReportBody(from report: NonComplianceReport) throws -> NonComplianceExcessiveDataReportBody {
    guard let excessiveDataReport = report as? NonComplianceExcessiveDataReport else {
      throw NonComplianceReportRequestBodyGeneratorError.wrongReportCategory
    }

    let requestObject = try getRequestObject(from: excessiveDataReport.activity.nonComplianceData)
    let presentationRequestFields = getPresentationRequestFields(from: requestObject)

    let metadata = NonComplianceExcessiveDataReportBody.Metadata(
      verifierDid: requestObject.clientId,
      verifierUrl: requestObject.responseUri.absoluteString,
      presentationActionCreatedAt: excessiveDataReport.activity.createdAt,
      presentedCredentialIssuerDid: excessiveDataReport.credential.issuer,
      presentationRequestJwt: excessiveDataReport.activity.nonComplianceData,
      presentationRequestFields: presentationRequestFields)

    return NonComplianceExcessiveDataReportBody(
      description: excessiveDataReport.description,
      email: excessiveDataReport.email,
      metadata: metadata)
  }

  private func getRequestObject(from rawData: String?) throws -> RequestObject {
    guard let rawData, let data = rawData.data(using: .utf8) else {
      throw NonComplianceReportRequestBodyGeneratorError.requestObjectDecodingFailed
    }

    if let jws = try? jwsDecoder.decode(RequestObjectJWT.self, from: data) {
      return jws.payload
    }

    return try JSONDecoder().decode(RequestObject.self, from: data)
  }

  private func getPresentationRequestFields(from requestObject: RequestObject) -> [NonComplianceExcessiveDataReportBody.Field] {
    guard let presentationDefinition = requestObject.presentationDefinition else {
      return []
    }

    return presentationDefinition.inputDescriptors
      .flatMap(\.constraints.fields)
      .flatMap { field in
        field.path.map { path in
          NonComplianceExcessiveDataReportBody.Field(name: path, constraint: field.filter?.const)
        }
      }
  }
}
