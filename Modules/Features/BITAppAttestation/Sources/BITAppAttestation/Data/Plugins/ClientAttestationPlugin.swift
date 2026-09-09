import Factory
import Foundation
import Moya

// MARK: - ClientAttestationPlugin

public struct ClientAttestationPlugin: PluginType {

  // MARK: Lifecycle

  public init(clientAttestation: String, proofOfPossession: String? = nil) {
    self.clientAttestation = clientAttestation
    self.proofOfPossession = proofOfPossession
  }

  // MARK: Public

  public func prepare(_ request: URLRequest, target: any TargetType) -> URLRequest {
    var request = request

    request.addValue(clientAttestation, forHTTPHeaderField: Self.oAuthClientAttestationHeaderKey)

    if let proofOfPossession {
      request.addValue(proofOfPossession, forHTTPHeaderField: Self.oAuthClientAttestationPoPHeaderKey)
    }

    return request
  }

  public func didReceive(_ result: Result<Response, MoyaError>, target: any TargetType) {
    guard case .success(let response) = result, response.statusCode == 401 else {
      return
    }

    try? clientAttestationRepository.delete()
  }

  // MARK: Private

  private static let oAuthClientAttestationHeaderKey = "OAuth-Client-Attestation"
  private static let oAuthClientAttestationPoPHeaderKey = "OAuth-Client-Attestation-PoP"

  @Injected(\.clientAttestationRepository) private var clientAttestationRepository

  private let clientAttestation: String
  private let proofOfPossession: String?
}
