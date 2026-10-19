import BITAnyCredentialFormat
import BITAppInfo
import BITCore
import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - SwissProfileStatusEvaluatorProtocol

@Spyable
protocol SwissProfileStatusEvaluatorProtocol: Sendable {
  func callAsFunction(_ credential: VerifiableCredential) async -> SwissProfile.Status?
  func callAsFunction(anyCredential: AnyCredential) async -> SwissProfile.Status?
}

// MARK: - SwissProfileStatusEvaluator

struct SwissProfileStatusEvaluator: SwissProfileStatusEvaluatorProtocol {
  func callAsFunction(_ credential: VerifiableCredential) async -> SwissProfile.Status? {
    guard let item = credential.bundleItems.first else { return nil }
    guard let anyCredential = try? await createAnyCredentialUseCase.execute(from: item.payload, format: credential.format) else { return nil }
    return await callAsFunction(anyCredential: anyCredential)
  }

  func callAsFunction(anyCredential: AnyCredential) async -> SwissProfile.Status? {
    let swissProfiles = try? await swissProfileLifecycleRepository.fetchSwissProfiles(.verifiableCredential)
    guard let swissProfiles, swissProfiles.contains(where: { $0.type == .verifiableCredential }) else { return .current } // no info about profile version so assume it's current
    let version = anyCredential.swissProfileVersion
    return swissProfiles.getStatus(for: version)
  }

  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase
  @Injected(\.swissProfileLifecycleRepository) private var swissProfileLifecycleRepository
}

extension Collection<SwissProfile> {
  fileprivate func getStatus(for version: String?) -> SwissProfile.Status? {
    let vcPrefix = SwissProfile.ProfileType.verifiableCredential.rawValue + ":"
    guard
      let version,
      version.hasPrefix(vcPrefix),
      let profile = first(where: { $0.version == version.dropFirst(vcPrefix.count) })
    else { return nil }
    return profile.status
  }
}
