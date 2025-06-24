import BITAppAttestation
import Factory
import Foundation
import Spyable


@Spyable
protocol SubmitEIDRequestUseCaseProtocol {
  func execute(mrz: [String], hasLegalRepresentant: Bool) async throws -> EIDRequestCase
}


struct SubmitEIDRequestUseCase: SubmitEIDRequestUseCaseProtocol {

  // MARK: Internal

  func execute(mrz: [String], hasLegalRepresentant: Bool) async throws -> EIDRequestCase {
    let payload = EIDRequestPayload(mrz: mrz, hasLegalRepresentant: hasLegalRepresentant)

    let challenge = try await remoteEIDRequestRepository.fetchChallenge()
    let request = try await generateClientAttestedRequestUseCase.execute(for: payload, challenge: challenge, audience: sidUrl.absoluteString)
    let response = try await remoteEIDRequestRepository.submitRequest(request)

    var eIDRequestCase = EIDRequestCase(
      id: response.caseId,
      rawMRZ: payload.mrz,
      documentNumber: response.identityNumber,
      lastName: response.lastName,
      firstName: response.firstName)

    guard let status = try? await remoteEIDRequestRepository.fetchRequestStatus(for: eIDRequestCase.id) else {
      return eIDRequestCase
    }

    eIDRequestCase.state = EIDRequestState(status: status)

    return try await localEIDRequestRepository.create(eIDRequestCase: eIDRequestCase)
  }

  // MARK: Private

  @Injected(\.sidUrl) private var sidUrl: URL
  @Injected(\.eIDRequestRepository) private var remoteEIDRequestRepository: EIDRequestRepositoryProtocol
  @Injected(\.localEIDRequestRepository) private var localEIDRequestRepository: LocalEIDRequestRepositoryProtocol
  @Injected(\.generateClientAttestedRequestUseCase) private var generateClientAttestedRequestUseCase: GenerateClientAttestedRequestUseCaseProtocol
}
