import BITAnyCredentialFormat
import BITCredentialShared
import BITOpenID
import BITSdJWT
import Factory
import Foundation
import Spyable

// MARK: - CredentialStatusValidatorProtocol

@Spyable
protocol CredentialStatusValidatorProtocol: Sendable {
  func callAsFunction(_ credential: VerifiableCredential) async throws -> CredentialStatus
}

// MARK: - CredentialStatusValidator

struct CredentialStatusValidator: CredentialStatusValidatorProtocol {

  // MARK: Internal

  func callAsFunction(_ credential: VerifiableCredential) async throws -> CredentialStatus {
    let bundleItem = try selectCredentialBundleItemUseCase(credential)
    let anyCredential = try await createAnyCredentialUseCase.execute(from: bundleItem.payload, format: credential.format)
    let dateStatus = checkDateValidity(anyCredential: anyCredential)
    if dateStatus == .expired {
      return .expired
    }

    let validatorStatus = await getValidatorStatus(anyCredential: anyCredential)
    if validatorStatus == .revoked {
      return .revoked
    }

    if dateStatus == .businessExpired {
      return .businessExpired
    }

    if dateStatus == .notYetValid {
      return .notYetValid
    }

    if validatorStatus != .unknown {
      return CredentialStatus(validatorStatus)
    }
    return .unknown
  }

  // MARK: Private

  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase
  @Injected(\.statusValidators) private var validators: [AnyStatusType: any AnyStatusCheckValidatorProtocol]
  @Injected(\.dateBuffer) private var dateBuffer: TimeInterval
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase

  private func getValidatorStatus(anyCredential: AnyCredential) async -> VcStatus {
    guard
      let anyStatus = anyCredential.status,
      let validator = validators[anyStatus.type]
    else { return .unknown }
    return await validator.validate(anyStatus, issuer: anyCredential.issuer)
  }

  private func checkDateValidity(anyCredential: AnyCredential) -> CredentialStatus {
    let now = Container.shared.currentDate()
    if let validFrom = anyCredential.validFrom, validFrom > now.addingTimeInterval(dateBuffer) {
      return .notYetValid
    }

    if let validUntil = anyCredential.validUntil, validUntil < now {
      return .expired
    }

    if let businessExpiry = (anyCredential as? VcSdJWS)?.businessExpiryDate, businessExpiry < now {
      return .businessExpired
    }

    return .valid
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
