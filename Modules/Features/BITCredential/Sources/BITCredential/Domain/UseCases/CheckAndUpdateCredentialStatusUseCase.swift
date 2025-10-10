import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import Factory
import Foundation

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
  @Injected(\.verifiableCredentialRepository) private var verifiableCredentialRepository
  @Injected(\.dateBuffer) private var dateBuffer: TimeInterval
}

extension CheckAndUpdateCredentialStatusUseCase {
  private func getStatus(of credential: VerifiableCredential) async throws -> CredentialStatus {
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

  private func updateCredentialStatus(_ credential: VerifiableCredential, to status: CredentialStatus) async throws -> VerifiableCredential {
    var credentialCopy = credential
    credentialCopy.status = status

    return try await verifiableCredentialRepository.update(credentialCopy)
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
