import BITNetworking
import Foundation
import Moya

// MARK: - EnvironmentFeatureFlags

struct EnvironmentFeatureFlags {
  let isEIDRequestFeatureEnabled: Bool
  let isNonComplianceEnabled: Bool
  let isDPoPEnabled: Bool
  let isProximityEnabled: Bool
  let isBatchIssuanceEnabled: Bool
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
      "swiyu-verification-query-public-statement+jwt": [publicTransparencyStatementIssuer],
      "swiyu-identity-trust-statement+jwt": [trustStatementIssuer],
      "swiyu-protected-issuance-trust-list-statement+jwt": [trustStatementIssuer],
      "swiyu-protected-issuance-authorization-trust-statement+jwt": [trustStatementIssuer],
      "swiyu-non-compliance-trust-list-statement+jwt": [trustStatementIssuer],
      "swiyu-protected-verification-authorization-trust-statement+jwt": [trustStatementIssuer],
    ]
  }
}

// MARK: - EnvironmentNetworkingConfiguration

struct EnvironmentNetworkingConfiguration {
  let plugins: [PluginType]
}

// MARK: - EnvironmentConfig

struct EnvironmentConfig {
  let trust: EnvironmentTrustConfiguration
  let features: EnvironmentFeatureFlags
  let baseURLs: EnvironmentBaseURLs
  let attestation: EnvironmentAttestationConfiguration
  let networking: EnvironmentNetworkingConfiguration

  static var current: Self? {
    #if DEV
    .dev
    #elseif REF
    .ref
    #elseif ABN
    .abn
    #else
    nil
    #endif
  }
}
