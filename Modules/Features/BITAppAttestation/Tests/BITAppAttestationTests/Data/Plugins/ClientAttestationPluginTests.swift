import Factory
import FactoryTesting
import Foundation
import Moya
import Testing
@testable import BITAppAttestation
@testable import BITTestingCore

@Suite(.container)
struct ClientAttestationPluginTests {

  // MARK: Lifecycle

  init() {
    let clientAttestationRepository = ClientAttestationRepositoryProtocolSpy()
    Container.shared.clientAttestationRepository.register { clientAttestationRepository }

    self.clientAttestationRepository = clientAttestationRepository
    plugin = ClientAttestationPlugin(clientAttestation: "clientAttestation")
  }

  // MARK: Internal

  @Test
  func didReceive_OKResponse_noClientAttestationDeletion() {
    plugin.didReceive(.success(Response(statusCode: 200, data: Data())), target: AttestationServiceEndpoint.challenge)

    #expect(clientAttestationRepository.deleteCallsCount == 0)
  }

  @Test
  func didReceive_unauthorizedResponse_deletesClientAttestation() {
    plugin.didReceive(.success(Response(statusCode: 401, data: Data())), target: AttestationServiceEndpoint.challenge)

    #expect(clientAttestationRepository.deleteCallsCount == 1)
  }

  @Test
  func didReceive_networkError_noClientAttestationDeletion() {
    plugin.didReceive(.failure(.underlying(TestingError.error, nil)), target: AttestationServiceEndpoint.challenge)

    #expect(clientAttestationRepository.deleteCallsCount == 0)
  }

  // MARK: Private

  private let plugin: ClientAttestationPlugin
  private let clientAttestationRepository: ClientAttestationRepositoryProtocolSpy
}
