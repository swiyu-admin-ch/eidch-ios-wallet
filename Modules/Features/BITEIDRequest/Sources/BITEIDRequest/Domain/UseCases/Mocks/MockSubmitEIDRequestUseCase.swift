#if DEBUG
import BITEIDRequestShared
import Factory
import Foundation

// swiftlint:disable implicitly_unwrapped_optional force_unwrapping force_try

public struct MockSubmitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol {

  // MARK: Lifecycle

  public init() {}

  // MARK: Public

  public func execute(scanDocumentOutput: ScanDocumentOutput, hasLegalRepresentant: Bool) async throws -> EIDRequestCase {
    try await eIDRequestCaseRepository.create(eIDRequestCase: EIDRequestCase.Mock.validSamples.randomElement()!)
  }

  // MARK: Private

  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol
}

// swiftlint:enable implicitly_unwrapped_optional force_unwrapping force_try
#endif
