import BITEIDRequestShared
import Factory
import Foundation

#if targetEnvironment (simulator)
// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try
public struct MockApplyEIDRequestUseCase: ApplyEIDRequestUseCaseProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func callAsFunction(scanDocumentOutput: ScanDocumentOutput, hasLegalRepresentant: Bool) async throws -> EIDRequestCase {
    try await eIDRequestCaseRepository.create(eIDRequestCase: EIDRequestCase.Mock.validSamples.randomElement()!)
  }

  // MARK: Private

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
#else
public typealias MockApplyEIDRequestUseCase = ApplyEIDRequestUseCase
#endif
