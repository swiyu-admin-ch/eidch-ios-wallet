import BITAppAttestation
import BITAppAuth
import BITAppInfo
import BITCore
import BITEIDRequest
import BITLocalAuthentication
import BITNetworking
import BITNonCompliance
import BITOpenID
import BITSettings
import Factory
import Foundation
import Moya

// MARK: - AppDelegate + EnvironmentAutoRegistering

extension AppDelegate: EnvironmentAutoRegistering {
}

// MARK: - EnvironmentAutoRegistering

protocol EnvironmentAutoRegistering {
  func registerEnvironmentValues()
}

extension EnvironmentAutoRegistering {

  // MARK: Internal

  func registerEnvironmentValues() {
    guard let config = EnvironmentConfig.current else { return }
    registerTrustConfiguration(config.trust)
    registerFeatureFlags(config.features)
    registerBaseURLs(config.baseURLs)
    registerNetworking(config.networking)
    registerAttestationConfiguration(config.attestation)
  }

  // MARK: Private

  private func registerTrustConfiguration(_ config: EnvironmentTrustConfiguration) {
    Container.shared.trustRegistryMapping.register { config.registryMapping }
    Container.shared.trustRegistryTrustedDidsV1.register { config.trustedDidsV1 }
    Container.shared.trustRegistryTrustedDids.register { config.trustedDids }
    Container.shared.trustEnvironmentDidRegex.register { config.trustEnvironmentDidRegex }
    Container.shared.demoTrustEnvironmentDidRegex.register { config.demoTrustEnvironmentDidRegex }
  }

  private func registerFeatureFlags(_ flags: EnvironmentFeatureFlags) {
    Container.shared.isEIDRequestFeatureEnabled.register { flags.isEIDRequestFeatureEnabled }
    Container.shared.isNonComplianceEnabled.register { flags.isNonComplianceEnabled }
    Container.shared.isDPoPEnabled.register { flags.isDPoPEnabled }
    Container.shared.isProximityEnabled.register { flags.isProximityEnabled }
    Container.shared.isBatchIssuanceEnabled.register { flags.isBatchIssuanceEnabled }
    Container.shared.isOTPSkipEnabled.register { flags.isOTPSkipEnabled }
    Container.shared.isOTPDebugToggleEnabled.register { flags.isOTPDebugToggleEnabled }
    Container.shared.isLottieViewerEnabled.register { flags.isLottieViewerEnabled }
  }

  private func registerBaseURLs(_ urls: EnvironmentBaseURLs) {
    registerURL(urls.versionEnforcement) { url in
      Container.shared.versionEnforcementUrl.register { url }
    }
    registerURL(urls.sidBase) { url in
      Container.shared.sidBaseUrl.register { url }
    }
    registerURL(urls.avBase) { url in
      Container.shared.avBaseUrl.register { url }
    }
    registerURL(urls.nonComplianceBase) { url in
      Container.shared.nonComplianceBaseURL.register { url }
    }
    registerURL(urls.avSocket) { url in
      Container.shared.avSocketUrl.register { url }
    }
    registerURL(urls.otpServiceBase) { url in
      Container.shared.otpServiceBaseUrl.register { url }
    }
    registerURL(urls.pushNotification) { url in
      Container.shared.pushNotificationUrl.register { url }
    }
  }

  private func registerNetworking(_ config: EnvironmentNetworkingConfiguration) {
    NetworkContainer.shared.plugins.register { config.plugins }
  }

  private func registerAttestationConfiguration(_ config: EnvironmentAttestationConfiguration) {
    registerURL(config.serviceURL) { url in
      Container.shared.attestationServiceUrl.register { url }
    }
    Container.shared.attestationServiceTrustedDids.register { config.trustedDids }
  }

  private func registerURL(_ value: String, register: (URL) -> Void) {
    guard let url = URL(string: value) else { return }
    register(url)
  }
}
