import BITSwiyuSharedKMP
import Spyable

typealias SdJwtCredentialConsistencyResult = SdJwtCredentialConsistencyChecker.ConsistencyResult

// MARK: - SdJwtCredentialConsistencyCheckerProtocol

@Spyable
protocol SdJwtCredentialConsistencyCheckerProtocol {
  func checkConsistency(left: String, right: String) -> SdJwtCredentialConsistencyResult
}

// MARK: - SdJwtCredentialConsistencyChecker + SdJwtCredentialConsistencyCheckerProtocol

extension SdJwtCredentialConsistencyChecker: SdJwtCredentialConsistencyCheckerProtocol { }
