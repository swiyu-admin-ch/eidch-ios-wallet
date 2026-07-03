import BITSdJWT
import BITSwiyuSharedKMP
import Factory
import Spyable

// MARK: - SdJwtBatchCredentialConsistencyValidatorProtocol

@Spyable
protocol SdJwtBatchCredentialConsistencyValidatorProtocol {
  func validate(_ credentials: [VcSdJWS]) throws
}

// MARK: - SdJwtBatchCredentialConsistencyValidator

struct SdJwtBatchCredentialConsistencyValidator: SdJwtBatchCredentialConsistencyValidatorProtocol {

  // MARK: Internal

  func validate(_ credentials: [VcSdJWS]) throws {
    guard let first = credentials.first else { return }

    guard
      credentials.dropFirst().allSatisfy({
        let result = consistencyChecker.checkConsistency(left: first.raw, right: $0.raw)
        return result == .ok
      }) else
    {
      throw FetchAnyVerifiableCredentialError.validationFailed
    }
  }

  // MARK: Private

  @Injected(\.sdJwtCredentialConsistencyChecker) private var consistencyChecker
}
