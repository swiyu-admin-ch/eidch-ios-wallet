import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import Factory
import Foundation
import Spyable

// MARK: - CheckAndUpdateCredentialStatusUseCaseProtocol

@Spyable
protocol CheckAndUpdateCredentialStatusUseCaseProtocol {
  @discardableResult
  func execute(_ credentials: [VerifiableCredential]) async throws -> [VerifiableCredential]
  func execute(for credential: VerifiableCredential) async throws -> VerifiableCredential
}

// MARK: - CheckAndUpdateCredentialStatusUseCase

struct CheckAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol {

  // MARK: Internal

  func execute(_ credentials: [VerifiableCredential]) async throws -> [VerifiableCredential] {
    try await withThrowingTaskGroup(of: VerifiableCredential.self, returning: [VerifiableCredential].self) { taskGroup in

      for credential in credentials {
        taskGroup.addTask {
          try await execute(for: credential)
        }
      }

      return try await taskGroup.reduce(into: [VerifiableCredential]()) { updatedCredentials, credential in
        updatedCredentials.append(credential)
      }
    }
  }

  func execute(for credential: VerifiableCredential) async throws -> VerifiableCredential {
    let status = try await getStatus(of: credential)
    if status != .unknown {
      return try await updateCredentialStatus(credential, to: status)
    }
    return credential
  }

  // MARK: Private

  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol
  @Injected(\.statusValidators) private var validators: [AnyStatusType: any AnyStatusCheckValidatorProtocol]
  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.dateBuffer) private var dateBuffer: TimeInterval
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol
}

extension CheckAndUpdateCredentialStatusUseCase {
  private func getStatus(of credential: VerifiableCredential) async throws -> CredentialStatus {
    let bundleItem = try selectCredentialBundleItemUseCase(credential)
    let anyCredential = try createAnyCredentialUseCase.execute(from: bundleItem.payload, format: credential.format)
    let dateStatus = checkDateValidity(anyCredential: anyCredential)
    if dateStatus == .expired {
      return .expired
    }

    let validatorStatus = await getValidatorStatus(anyCredential: anyCredential)
    if validatorStatus == .revoked {
      return .revoked
    }

    if dateStatus == .notYetValid {
      return .notYetValid
    }

    if validatorStatus != .unknown {
      return CredentialStatus(validatorStatus)
    }
    return .unknown
  }

  private func getValidatorStatus(anyCredential: AnyCredential) async -> VcStatus {
    guard
      let anyStatus = anyCredential.status,
      let validator = validators[anyStatus.type]
    else { return .unknown }
    return await validator.validate(anyStatus, issuer: anyCredential.issuer)
  }

  private func checkDateValidity(anyCredential: AnyCredential) -> CredentialStatus {
    let now = Date()
    if let validFrom = anyCredential.validFrom, validFrom > now.addingTimeInterval(dateBuffer) {
      return .notYetValid
    }
    if let validUntil = anyCredential.validUntil, validUntil < now {
      return .expired
    }
    return .valid
  }

  private func updateCredentialStatus(_ credential: VerifiableCredential, to status: CredentialStatus) async throws -> VerifiableCredential {
    var credentialCopy = credential
    let bundleItem = try selectCredentialBundleItemUseCase(credentialCopy)
    guard
      let index = credentialCopy.bundleItems.firstIndex(of: bundleItem) else
    {
      return credentialCopy
    }
    credentialCopy.bundleItems[index].status = status

    return try await credentialRepository.update(verifiableCredential: credentialCopy)
  }

}

extension CredentialStatus {

  init(_ vcStatus: VcStatus) {
    self = switch vcStatus {
    case .valid:
      .valid
    case .revoked:
      .revoked
    case .suspended:
      .suspended
    case .unsupported:
      .unsupported
    case .unknown:
      .unknown
    }
  }
}
