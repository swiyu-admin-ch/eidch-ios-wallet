import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import Factory
import Foundation

// MARK: - CheckAndUpdateCredentialStatusUseCase

public struct CheckAndUpdateCredentialStatusUseCase: CheckAndUpdateCredentialStatusUseCaseProtocol {

  // MARK: Public

  public func execute(_ credentials: [Credential]) async throws -> [Credential] {
    try await withThrowingTaskGroup(of: Credential.self, returning: [Credential].self) { taskGroup in

      for credential in credentials {
        taskGroup.addTask {
          try await execute(for: credential)
        }
      }

      return try await taskGroup.reduce(into: [Credential]()) { updatedCredentials, credential in
        updatedCredentials.append(credential)
      }
    }
  }

  public func execute(for credential: Credential) async throws -> Credential {
    let status = try await getStatus(of: credential)
    if status != .unknown {
      return try await updateCredentialStatus(credential, to: status)
    }
    return credential
  }

  // MARK: Private

  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol
  @Injected(\.statusValidators) private var validators: [AnyStatusType: any AnyStatusCheckValidatorProtocol]
  @Injected(\.databaseCredentialRepository) private var localRepository: CredentialRepositoryProtocol
  @Injected(\.dateBuffer) private var dateBuffer: TimeInterval
}

extension CheckAndUpdateCredentialStatusUseCase {
  private func getStatus(of credential: Credential) async throws -> CredentialStatus {
    let anyCredential = try createAnyCredentialUseCase.execute(from: credential.payload, format: credential.format)
    let dateStatus = checkDateValidity(anyCredential: anyCredential)
    guard dateStatus == .valid else {
      return dateStatus
    }
    guard
      let anyStatus = anyCredential.status,
      let validator = validators[anyStatus.type]
    else { return .unknown }
    let status = await validator.validate(anyStatus, issuer: anyCredential.issuer)
    if status != .unknown {
      return CredentialStatus(status)
    }
    return .unknown
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

  private func updateCredentialStatus(_ credential: Credential, to status: CredentialStatus) async throws -> Credential {
    var credentialCopy = credential
    credentialCopy.status = status

    return try await localRepository.update(credentialCopy)
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
