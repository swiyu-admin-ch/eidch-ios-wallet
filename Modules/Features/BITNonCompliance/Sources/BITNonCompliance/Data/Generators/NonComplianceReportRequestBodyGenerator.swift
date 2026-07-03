import BITClaimsPathPointer
import BITCore
import BITJWT
import BITOpenID
import BITSwiyuSharedKMP
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
  @Injected(\.preferredUserLanguageCodes) private var preferredUserLanguageCodes: [UserLanguageCode]

  private func buildExcessiveDataReportBody(from report: NonComplianceReport) throws -> NonComplianceExcessiveDataReportBody {
    guard let excessiveDataReport = report as? NonComplianceExcessiveDataReport else {
      throw NonComplianceReportRequestBodyGeneratorError.wrongReportCategory
    }

    let requestObject = try getRequestObject(from: excessiveDataReport.activity.nonComplianceData)
    let presentationRequestFields = getPresentationRequestFields(from: requestObject)

    let metadata = NonComplianceExcessiveDataReportBody.Metadata(
      verifierDid: requestObject.clientId,
      verifierUrl: requestObject.responseUri?.absoluteString,
      presentationActionCreatedAt: excessiveDataReport.activity.createdAt,
      presentedCredentialIssuerDid: excessiveDataReport.activity.issuer,
      presentationRequestJwt: excessiveDataReport.activity.nonComplianceData,
      presentationRequestFields: presentationRequestFields)

    return NonComplianceExcessiveDataReportBody(
      description: excessiveDataReport.description,
      email: excessiveDataReport.email,
      language: preferredUserLanguageCodes.first,
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
    guard let credentials = requestObject.dcqlQuery?.credentials else {
      return []
    }

    return credentials.flatMap { credential in
      var fields = [
        NonComplianceExcessiveDataReportBody.Field(
          name: "vct",
          constraint: getVctConstraint(from: credential.meta)),
      ]

      let claimFields = credential.claims?.map { claim in
        NonComplianceExcessiveDataReportBody.Field(
          name: ClaimsPathPointer(heidiPath: claim.path).stringValue,
          constraint: getConstraint(from: claim.values))
      } ?? []

      fields.append(contentsOf: claimFields)
      return fields
    }
  }

  private func getVctConstraint(from meta: Heidi_dcqlMeta?) -> String? {
    guard let meta = meta as? Heidi_dcqlMeta.SdjwtVc else { return nil }

    return meta.vctValues.joined(separator: ", ")
  }

  private func getConstraint(from values: [Heidi_utilValue]?) -> String? {
    values?
      .map { value in
        let type = BITSwiyuSharedKMP.onEnum(of: value)
        if case .string = type {
          return "\"\(value.jsonString())\""
        }
        return value.jsonString()
      }
      .joined(separator: ", ")
  }
}

extension ClaimsPathPointer {
  init(heidiPath: [Heidi_credentialsPointerPart]) {
    self = heidiPath.map { pathPart in
      switch BITSwiyuSharedKMP.onEnum(of: pathPart) {
      case .string(let value):
        .string(value.v1)
      case .index(let value):
        .index(Int(value.v1))
      case .null:
        .null
      }
    }
  }
}
