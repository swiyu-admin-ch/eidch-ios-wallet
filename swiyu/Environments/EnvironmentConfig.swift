import BITNetworking
import BITOpenID
import Foundation
import Moya

// MARK: - EnvironmentFeatureFlags

struct EnvironmentFeatureFlags {
  let isEIDRequestFeatureEnabled: Bool
  let isNonComplianceEnabled: Bool
  let isVersionEnforcementEnabled: Bool
  let isDPoPEnabled: Bool
  let isProximityEnabled: Bool
  let isBatchIssuanceEnabled: Bool
  let isActorIdentityValidationEnabled: Bool
  let isLottieViewerEnabled: Bool
  let isOTPSkipEnabled: Bool
  let isOTPDebugToggleEnabled: Bool
}

// MARK: - EnvironmentBaseURLs

struct EnvironmentBaseURLs {
  let versionEnforcement: String
  let sidBase: String
  let avBase: String
  let nonComplianceBase: String
  let avSocket: String
  let otpServiceBase: String
  let pushNotification: String
}

// MARK: - EnvironmentAttestationConfiguration

struct EnvironmentAttestationConfiguration {
  let serviceURL: String
  let trustedDids: [String]
}

// MARK: - EnvironmentTrustConfiguration

struct EnvironmentTrustConfiguration {
  let registryMapping: [String: String]
  let statusRegistryMapping: [String: String]
  let trustedDidsV1: [String: [String]]
  let trustedDids: [String: [String: [String]]]
  let trustEnvironmentDidRegex: Regex<Substring>
  let demoTrustEnvironmentDidRegex: Regex<Substring>
}

extension EnvironmentTrustConfiguration {
  static func trustedDidsByTrustStatementType(
    trustStatementIssuer: String,
    publicTransparencyStatementIssuer: String)
    -> [String: [String]]
  {
    [
      TrustStatementType.verificationQueryPublic: [publicTransparencyStatementIssuer],
      TrustStatementType.identity: [trustStatementIssuer],
      TrustStatementType.protectedIssuanceTrustList: [trustStatementIssuer],
      TrustStatementType.protectedIssuanceAuthorization: [trustStatementIssuer],
      TrustStatementType.nonComplianceTrustList: [trustStatementIssuer],
      TrustStatementType.protectedVerificationAuthorization: [trustStatementIssuer],
    ]
  }
}

// MARK: - EnvironmentNetworkingConfiguration

struct EnvironmentNetworkingConfiguration {
  let plugins: [PluginType]
  let userAgent: String
}

// MARK: - EnvironmentConfig

struct EnvironmentConfig {

  static var current: Self? {
    #if DEV
    .dev
    #elseif REF
    .ref
    #elseif ABN
    .abn
    #elseif SANDBOX
    .sandbox
    #else
    nil
    #endif
  }

  let trust: EnvironmentTrustConfiguration
  let features: EnvironmentFeatureFlags
  let baseURLs: EnvironmentBaseURLs
  let attestation: EnvironmentAttestationConfiguration?
  let networking: EnvironmentNetworkingConfiguration
}
