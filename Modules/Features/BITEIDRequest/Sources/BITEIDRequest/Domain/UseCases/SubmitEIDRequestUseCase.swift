import Factory
import Spyable


@Spyable
protocol SubmitEIDRequestUseCaseProtocol {
  func execute(_ mrz: [String]) async throws -> (requestCase: EIDRequestCase, status: EIDRequestStatus?)
}


struct SubmitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol {

  // MARK: Internal

  func execute(_ mrz: [String]) async throws -> (requestCase: EIDRequestCase, status: EIDRequestStatus?) {
    let hasLegalRepresentant = legalRepresentantRepository.get()
    let payload = EIDRequestPayload(mrz: mrz, hasLegalRepresentant: hasLegalRepresentant)

    let response = try await remoteEIDRequestRepository.submitRequest(with: payload)

    var eIDRequestCase = EIDRequestCase(
      id: response.caseId,
      rawMRZ: payload.mrz,
      documentNumber: response.identityNumber,
      lastName: response.lastName,
      firstName: response.firstName)

    guard let status = try? await remoteEIDRequestRepository.fetchRequestStatus(for: eIDRequestCase.id) else {
      return (eIDRequestCase, nil)
    }

    eIDRequestCase.state = EIDRequestState(status: status)

    let updatedRequestCase = try await localEIDRequestRepository.create(eIDRequestCase: eIDRequestCase)

    return (updatedRequestCase, status)
  }

  // MARK: Private

  @Injected(\.eIDRequestRepository) private var remoteEIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.localEIDRequestRepository) private var localEIDRequestRepository: LocalEIDRequestRepositoryProtocol
  @Injected(\.legalRepresentantRepository) private var legalRepresentantRepository: LegalRepresentantRepositoryProcotol
}
