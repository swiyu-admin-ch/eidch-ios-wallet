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

  // MARK: Private

  private static let oAuthClientAttestationHeaderKey = "OAuth-Client-Attestation"
  private static let oAuthClientAttestationPoPHeaderKey = "OAuth-Client-Attestation-PoP"

  private let clientAttestation: String
  private let proofOfPossession: String?
}
