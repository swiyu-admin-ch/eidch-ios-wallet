import Factory
import Foundation

extension Container {

  // MARK: Public

  public var isNonComplianceEnabled: Factory<Bool> {
    self { false }
  }

  public var nonComplianceBaseURL: Factory<URL> {
    self {
      guard let url = URL(string: "https://noncompliance.trust-infra.swiyu.admin.ch/non-compliance-service/") else {
        fatalError("No valid URL for Non-Compliance base url")
      }
      return url
    }
  }

  public var nonComplianceRepository: Factory<NonComplianceRepositoryProtocol> {
    self { NonComplianceRepository() }
  }

  // MARK: Internal

  var nonComplianceFormValidator: Factory<NonComplianceFormValidatorProtocol> {
    self { NonComplianceFormValidator() }
  }

  var nonComplianceReportRequestBodyGenerator: Factory<NonComplianceReportRequestBodyGeneratorProtocol> {
    self { NonComplianceReportRequestBodyGenerator() }
  }

  var submitNonComplianceReportUseCase: Factory<SubmitNonComplianceReportUseCaseProtocol> {
    self { SubmitNonComplianceReportUseCase() }
  }

  var getActivityActorDisplayUseCase: Factory<GetActivityActorDisplayUseCaseProtocol> {
    self { GetActivityActorDisplayUseCase() }
  }

  var nonComplianceActivityFactory: Factory<NonComplianceActivityFactoryProtocol> {
    self { NonComplianceActivityFactory() }
  }

  var descriptionFormFieldMinimumLength: Factory<Int> {
    self { 20 }
  }

  var descriptionFormFieldMaximumLength: Factory<Int> {
    self { 500 }
  }

  var nonComplianceJsonEncoder: Factory<JSONEncoder> {
    self { JSONEncoder(dateEncodingStrategy: .iso8601) }
  }
}
