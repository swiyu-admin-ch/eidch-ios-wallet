import Alamofire
import BITNetworking
import Factory
import Foundation

// MARK: - BITServerTrustManager

/// `BITServerTrustManager`: A subclass of `WildcardServerTrustManager` provided by BITNetworking.
/// Designed for handling server trust and configure certificate pinning for the BIT application based on domain name patterns.
class BITServerTrustManager: WildcardServerTrustManager {

  // MARK: Lifecycle

  init() {
    let evaluators = TrustEvaluator.allCases.compactMap { Self.createEvaluator($0) }
    super.init(evaluators: Dictionary(uniqueKeysWithValues: evaluators))
  }

  // MARK: Private

  private static func createEvaluator(_ evaluator: TrustEvaluator) -> (String, ServerTrustEvaluating)? {
    let secCertificates = evaluator.certificate.compactMap { certificateName in
      CertificateLoader.loadDERCertificate(named: certificateName.rawValue, from: .main)
    }

    return (evaluator.domain.rawValue, PinnedCertificatesTrustEvaluator(certificates: secCertificates))
  }
}

// MARK: BITServerTrustManager.TrustEvaluator

extension BITServerTrustManager {
  fileprivate enum TrustEvaluator: CaseIterable {
    case dynatrace
    case versionEnforcement
    case trustInfra
    case trustInfraInt
    case attestationService

    // MARK: Internal

    var domain: Domain {
      switch self {
      case .dynatrace: Domain.mamManagedBitAdminCh
      case .versionEnforcement: Domain.enforcementServiceBitAdminCh
      case .trustInfra: Domain.trustInfraSwiyuAdminCh
      case .trustInfraInt: Domain.trustInfraIntSwiyuAdminCh
      case .attestationService: Domain.attestationServiceCh
      }
    }

    var certificate: [Certificate] {
      switch self {
      case .dynatrace: [.dynatraceRoot]
      case .attestationService,
           .trustInfra,
           .trustInfraInt,
           .versionEnforcement: [.adminChRoot]
      }
    }
  }

  fileprivate enum Domain: String, CaseIterable {
    case mamManagedBitAdminCh
    case enforcementServiceBitAdminCh
    case trustInfraSwiyuAdminCh
    case trustInfraIntSwiyuAdminCh
    case attestationServiceCh

    // MARK: Internal

    var rawValue: String {
      switch self {
      case .mamManagedBitAdminCh: Self.getMamManagedDomain()
      case .enforcementServiceBitAdminCh: Self.getVersionEnforcementDomain()
      case .trustInfraSwiyuAdminCh: Self.getTrustInfraDomain()
      case .trustInfraIntSwiyuAdminCh: Self.getTrustInfraIntDomain()
      case .attestationServiceCh: Self.getAttestationServiceDomain()
      }
    }

    // MARK: Private

    private static func getVersionEnforcementDomain() -> String {
      guard let domain = Container.shared.versionEnforcementUrl().host else {
        fatalError("Unavailable app version enforcement domain")
      }
      return domain
    }

    private static func getMamManagedDomain() -> String {
      Container.shared.mamManagedDomain()
    }

    private static func getTrustInfraDomain() -> String {
      Container.shared.trustInfraWildCardDomain()
    }

    private static func getTrustInfraIntDomain() -> String {
      Container.shared.trustInfraIntWildCardDomain()
    }

    private static func getAttestationServiceDomain() -> String {
      Container.shared.attestationServiceDomain()
    }
  }

  fileprivate enum Certificate: String, CaseIterable {
    case dynatraceRoot = "qvrca2g3"
    case adminChRoot = "dcgrg2"
  }
}
