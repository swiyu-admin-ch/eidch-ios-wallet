import BITNetworking
import Foundation
import Moya

// MARK: - EnvironmentFeatureFlags

struct EnvironmentFeatureFlags: Sendable {
  let isEIDRequestFeatureEnabled: Bool
  let imageValidatorEnabled: Bool
  let isNonComplianceEnabled: Bool
  let isProximityEnabled: Bool
  let isPayloadEncryptionEnabled: Bool
  let isBatchIssuanceEnabled: Bool
  let isLottieViewerEnabled: Bool
  let isOTPSkipEnabled: Bool
  let isOTPDebugToggleEnabled: Bool
}

// MARK: - EnvironmentBaseURLs

struct EnvironmentBaseURLs: Sendable {
  let versionEnforcement: String
  let sidBase: String
  let avBase: String
  let nonComplianceBase: String
  let avSocket: String
  let otpServiceBase: String
}

// MARK: - EnvironmentAttestationConfiguration

struct EnvironmentAttestationConfiguration: Sendable {
  let serviceURL: String
  let trustedDids: [String]
}

// MARK: - EnvironmentTrustConfiguration

struct EnvironmentTrustConfiguration: Sendable {
  let registryMapping: [String: String]
  let trustedDids: [String: [String]]
  let trustEnvironmentDidRegex: Regex<Substring>
  let demoTrustEnvironmentDidRegex: Regex<Substring>
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
