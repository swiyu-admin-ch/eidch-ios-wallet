import BITAppAttestation
import Factory
import Foundation
import Spyable


@Spyable
public protocol SubmitEIDRequestUseCaseProtocol {
  func execute(scanDocumentOutput: ScanDocumentOutput, hasLegalRepresentant: Bool) async throws -> EIDRequestCase
}


struct SubmitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol {

  // MARK: Internal

  func execute(scanDocumentOutput: ScanDocumentOutput, hasLegalRepresentant: Bool) async throws -> EIDRequestCase {
    let payload = EIDRequestPayload(mrz: scanDocumentOutput.mrz.values, hasLegalRepresentant: hasLegalRepresentant)
    let response = try await eIDRequestRepository.submitRequest(with: payload)

    var eIDRequestCase = EIDRequestCase(
      id: response.caseId,
      rawMRZ: payload.mrz,
      documentNumber: response.identityNumber,
      selectedDocumentType: scanDocumentOutput.identityType,
      lastName: response.lastName,
      firstName: response.firstName)

    guard let status = try? await eIDRequestRepository.fetchRequestStatus(for: eIDRequestCase.id) else {
      return eIDRequestCase
    }

    eIDRequestCase.state = EIDRequestState(status: status)

    let savedRequestCase = try await eIDRequestCaseRepository.create(eIDRequestCase: eIDRequestCase)
    try await eIDRequestCaseRepository.save(files: scanDocumentOutput.files, forRequestCaseId: savedRequestCase.id)

    return savedRequestCase
  }

  // MARK: Private

  @Injected(\.eIDRequestRepository) private var eIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.eIDRequestCaseRepository) private var eIDRequestCaseRepository: EIDRequestCaseRepositoryProtocol

}
