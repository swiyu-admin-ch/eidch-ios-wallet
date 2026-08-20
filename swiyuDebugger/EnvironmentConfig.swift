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
    EnvironmentConfig(
      trust: EnvironmentTrustConfiguration(
        registryMapping: [
          "identifier-reg-r.trust-infra.swiyu.admin.ch": "trust-reg-r.trust-infra.swiyu.admin.ch",
          "identifier-reg-a.trust-infra.swiyu.admin.ch": "trust-reg-a.trust-infra.swiyu.admin.ch",
          "identifier-reg-a.trust-infra.swiyu-int.admin.ch": "trust-reg-a.trust-infra.swiyu-int.admin.ch",
          "identifier-reg.trust-infra.swiyu-int.admin.ch": "trust-reg.trust-infra.swiyu-int.admin.ch",
          "identifier-reg.trust-infra.swiyu.admin.ch": "trust-reg.trust-infra.swiyu.admin.ch",
        ],
        statusRegistryMapping: [
          "identifier-reg-r.trust-infra.swiyu.admin.ch": "status-reg-r.trust-infra.swiyu.admin.ch",
          "identifier-reg-a.trust-infra.swiyu.admin.ch": "status-reg-a.trust-infra.swiyu.admin.ch",
          "identifier-reg-a.trust-infra.swiyu-int.admin.ch": "status-reg-a.trust-infra.swiyu-int.admin.ch",
          "identifier-reg.trust-infra.swiyu-int.admin.ch": "status-reg.trust-infra.swiyu-int.admin.ch",
          "identifier-reg.trust-infra.swiyu.admin.ch": "status-reg.trust-infra.swiyu.admin.ch",
        ],
        trustedDidsV1: [
          "trust-reg-r.trust-infra.swiyu.admin.ch": [
            "did:tdw:QmU4hxq3dT3UoQGy8PYo2xHhs3X9KvqdWQnkuEiyHyiT73:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:39bed985-f2a1-45fb-997f-a3f31a611c6f",
          ],
          "trust-reg-a.trust-infra.swiyu.admin.ch": [
            "did:tdw:QmaAejs3zkeVYoviFWXzZoVy7x7arkZfYumGhhj3btbGZ5:identifier-reg-a.trust-infra.swiyu.admin.ch:api:v1:did:6262c85b-3c44-4c0c-b2b4-50ca4e0f3dd9",
          ],
          "trust-reg-a.trust-infra.swiyu-int.admin.ch": [
            "did:tdw:QmRNavmCeGwoxRU1ddgPWGnKZYHjtNGikfoRCkRruTjRRx:identifier-reg-a.trust-infra.swiyu-int.admin.ch:api:v1:did:99d8d850-10f3-45fa-a3b1-f130c019ddc3",
            "did:tdw:QmTmECx792eAzcn2h4KeELuC1GeK4RUU9Mv5dpuWf67nch:identifier-reg-a.trust-infra.swiyu-int.admin.ch:api:v1:did:99d8d850-10f3-45fa-a3b1-f130c019ddc3",
          ],
          "trust-reg.trust-infra.swiyu-int.admin.ch": [
            "did:tdw:QmWrXWFEDenvoYWFXxSQGFCa6Pi22Cdsg2r6weGhY2ChiQ:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:2e246676-209a-4c21-aceb-721f8a90b212",
          ],
          "trust-reg.trust-infra.swiyu.admin.ch": [
            "did:tdw:QmerEFUx69M5AB7oyoPQG6P17MbZQUHoe2Jxz9tXk7cSdf:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:02ee8aca-041f-4683-b878-8c6efa977292",
          ],
        ],
        trustedDids: [
          "trust-reg-r.trust-infra.swiyu.admin.ch": EnvironmentTrustConfiguration.trustedDidsByTrustStatementType(
            trustStatementIssuer: "did:webvh:QmQqecEZwo24bbEDW5ygYg6NxhQ8R4oVNC11JqHtvxRcCz:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:a533038b-8abb-4d1f-b77f-c17dfb76f23c",
            publicTransparencyStatementIssuer: "did:webvh:QmWARZUExTea76sivyu4xvrUzxvSuBtCK24h7kLfy1BsAL:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:74940e9b-d6d6-4007-94b9-e9465fa245ca"),
          "trust-reg-a.trust-infra.swiyu.admin.ch": EnvironmentTrustConfiguration.trustedDidsByTrustStatementType(
            trustStatementIssuer: "did:webvh:QmPoeRRafAuWdfhExchuAdKqVp9bdmUd3jNLPHagzL4qjg:identifier-reg-a.trust-infra.swiyu.admin.ch:api:v1:did:31aeea1b-e562-4d80-b7a4-d8aff3785810",
            publicTransparencyStatementIssuer: "did:webvh:QmdM6ThrT3b7DkL9a1CaFVseWYoGwXbAgh8Ueg6aud8zbT:identifier-reg-a.trust-infra.swiyu.admin.ch:api:v1:did:7d7ca34a-3760-4c39-988e-6508246a1f44"),
          "trust-reg-a.trust-infra.swiyu-int.admin.ch": EnvironmentTrustConfiguration.trustedDidsByTrustStatementType(
            trustStatementIssuer: "did:webvh:QmQNMXCBYHLsH5zJeE1hC6tn7GpQFfvqJaWPqwpn7pafcy:identifier-reg-a.trust-infra.swiyu-int.admin.ch:api:v1:did:3d20b010-8d39-4cdd-b5cd-a6356b4e1218",
            publicTransparencyStatementIssuer: "did:webvh:Qmez8P5YSanrVef83fNdvf44oSQn38MDd987g9PxEPcvBu:identifier-reg-a.trust-infra.swiyu-int.admin.ch:api:v1:did:e5ed2da0-ee79-4433-a071-d2820f1f6374"),
          "trust-reg.trust-infra.swiyu.admin.ch": EnvironmentTrustConfiguration.trustedDidsByTrustStatementType(
            trustStatementIssuer: "did:webvh:QmaemSxuZiADoV3F5aBxyvemrUgbWURCv67KU222midYSo:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:cc6c0cc8-0743-4cf0-a6b8-c87e30c78d31",
            publicTransparencyStatementIssuer: "did:webvh:QmUtTiwizd74sn8vv2XfsjjrzjaEuPTbgeT2u3MpFCCqHu:identifier-reg.trust-infra.swiyu.admin.ch:api:v1:did:82b5f3c4-ce00-464d-bc45-b28d3a04ee73"),
          "trust-reg.trust-infra.swiyu-int.admin.ch": EnvironmentTrustConfiguration.trustedDidsByTrustStatementType(
            trustStatementIssuer: "did:webvh:QmdVPcfEJgvQAJKEjaTWAhskT1kc59KZQiXNenqHBB7iH5:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:4c131dc4-ced1-454b-bbd4-9401c7512e37",
            publicTransparencyStatementIssuer: "did:webvh:QmNTHuhETA3u2ypoujoaEMaZGKf5HpPwkV6ktfgzu7JzMp:identifier-reg.trust-infra.swiyu-int.admin.ch:api:v1:did:5e5de412-0e7d-4982-a0ed-bd55a0f25a04"),
        ],
        trustEnvironmentDidRegex: #/^did:(?:tdw|webvh):[^:]+:identifier-reg(?:-r|-a)\.trust-infra\.swiyu\.admin\.ch:(?:(?!f7698e93-2381-4024-9657-68cd1e383613).)*$/#,
        demoTrustEnvironmentDidRegex: #/^did:(?:webvh:QmUsJTCE1tnjrqX1XjeSrTfA5RrV2sDg5pCnRUGJcHHByg:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:f7698e93-2381-4024-9657-68cd1e383613|(?:tdw|webvh):[^:]+:identifier-reg(?:-a)?\.trust-infra\.swiyu-int\.admin\.ch:.*)$/#), // issuer03 or INT-ABN
      features: EnvironmentFeatureFlags(
        isEIDRequestFeatureEnabled: true,
        isNonComplianceEnabled: true,
        isVersionEnforcementEnabled: true,
        isDPoPEnabled: true,
        isProximityEnabled: true,
        isBatchIssuanceEnabled: true,
        isActorIdentityValidationEnabled: true,
        isLottieViewerEnabled: true,
        isOTPSkipEnabled: true,
        isOTPDebugToggleEnabled: true),
      baseURLs: EnvironmentBaseURLs(
        versionEnforcement: "https://versioning-r.trust-infra.swiyu.admin.ch/api/versioning?platform=ios&app_id=wallet",
        sidBase: "https://www.sid-intg.admin.ch/sid-web/",
        avBase: "https://av-intg.admin.ch/",
        nonComplianceBase: "https://noncompliance-r.trust-infra.swiyu.admin.ch/non-compliance-service/",
        avSocket: "wss://av-intg.admin.ch/nfc/ws1/validate",
        otpServiceBase: "https://attestations-r.trust-infra.swiyu.admin.ch",
        pushNotification: "https://push-api-r.trust-infra.swiyu.admin.ch"),
      attestation: EnvironmentAttestationConfiguration(
        serviceURL: "https://attestations-r.trust-infra.swiyu.admin.ch/api/attestations",
        trustedDids: [
          "did:tdw:QmbbB72cmrZbvnBF4zh8rPpMv9ePF759i4SCCeoAbZ9AKF:identifier-reg-r.trust-infra.swiyu.admin.ch:api:v1:did:52e1f30d-3272-4ca6-85d8-70fae0611a1e",
        ]),
      networking: EnvironmentNetworkingConfiguration(
        plugins: [
          MaxContentLengthPlugin(),
          AnalyticsPlugin(),
          NetworkLoggerPlugin(),
        ],
        userAgent: "swiyuDebugger"))
  }

  let trust: EnvironmentTrustConfiguration
  let features: EnvironmentFeatureFlags
  let baseURLs: EnvironmentBaseURLs
  let attestation: EnvironmentAttestationConfiguration?
  let networking: EnvironmentNetworkingConfiguration
}
