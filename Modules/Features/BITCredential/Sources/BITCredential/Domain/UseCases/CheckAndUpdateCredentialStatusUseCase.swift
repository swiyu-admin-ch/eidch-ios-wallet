import BITAnyCredentialFormat
import BITCore
import BITCredentialShared
import BITOpenID
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - CheckAndUpdateCredentialStatusUseCaseProtocol

@Spyable
protocol CheckAndUpdateCredentialStatusUseCaseProtocol: Sendable {
  @discardableResult
  func callAsFunction(_ credentials: [VerifiableCredential]) async throws -> [VerifiableCredential]
  func callAsFunction(for credential: VerifiableCredential) async throws -> VerifiableCredential
}

// MARK: - CheckAndUpdateCredentialStatusUseCase

struct CheckAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ credentials: [VerifiableCredential]) async throws -> [VerifiableCredential] {
    let results = await credentials.concurrentMapLimited(maxConcurrentTasks: maxConcurrentStatusChecks) {
      try await callAsFunction(for: $0)
    }
    return zip(credentials, results).map { credential, result in
      switch result {
      case .success(let updatedCredential):
        updatedCredential
      case .failure:
        credential
      }
    }
  }

  func callAsFunction(for credential: VerifiableCredential) async throws -> VerifiableCredential {
    let status = try await credentialStatusValidator(credential)
    if status != .unknown && status != credential.status {
      return try await updateCredentialStatus(credential, to: status)
    }
    return credential
  }

  // MARK: Private

  private let maxConcurrentStatusChecks = 10

  @Injected(\.credentialStatusValidator) private var credentialStatusValidator
  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol

  private func updateCredentialStatus(_ credential: VerifiableCredential, to status: CredentialStatus) async throws -> VerifiableCredential {
    var credentialCopy = credential
    let bundleItem = try selectCredentialBundleItemUseCase(credentialCopy)
    guard
      let index = credentialCopy.bundleItems.firstIndex(of: bundleItem) else
    {
      return credentialCopy
    }

    guard credentialCopy.bundleItems[index].status != status else {
      return credentialCopy
    }

    credentialCopy.bundleItems[index].status = status

    return try await credentialRepository.update(verifiableCredential: credentialCopy)
  }
}
