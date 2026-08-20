import BITAppAttestation
import BITEIDRequestShared
import Factory
import Foundation
import Spyable


@Spyable
protocol ApplyEIDRequestUseCaseProtocol {
  func callAsFunction(scanDocumentOutput: ScanDocumentOutput, hasLegalRepresentant: Bool) async throws -> EIDRequestCase
}


public struct ApplyEIDRequestUseCase: ApplyEIDRequestUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(scanDocumentOutput: ScanDocumentOutput, hasLegalRepresentant: Bool) async throws -> EIDRequestCase {
    let payload = EIDRequestPayload(mrz: scanDocumentOutput.mrz.values, hasLegalRepresentant: hasLegalRepresentant)
    let response = try await sidRepository.apply(with: payload)

    var eIDRequestCase = EIDRequestCase(
      id: response.caseId,
      rawMRZ: payload.mrz,
      documentNumber: response.identityNumber,
      selectedDocumentType: scanDocumentOutput.identityType,
      lastName: response.lastName,
      firstName: response.firstName)

    guard let status = try? await sidRepository.fetchRequestStatus(for: eIDRequestCase.id) else {
      return eIDRequestCase
    }

    eIDRequestCase.state = EIDRequestState(status: status)

    let savedRequestCase = try await eIDRequestCaseRepository.create(eIDRequestCase: eIDRequestCase)
    try await eIDRequestCaseRepository.save(files: scanDocumentOutput.files, forRequestCaseId: savedRequestCase.id)

    return savedRequestCase
  }

  // MARK: Private

  @Injected(\.sidRepository) private var sidRepository: SIDRepositoryProtocol
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol

}
