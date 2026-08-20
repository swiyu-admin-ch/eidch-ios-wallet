import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - AttestationServiceEndpoint

enum AttestationServiceEndpoint {
  case challenge
  case clientAttestation(ClientAttestationRequestBody)
  case keyAttestation(KeyAttestationRequestBody)
  case batchKeyAttestations(BatchKeyAttestationRequestBody)
}

// MARK: - AttestationChallengeEndpoint

public enum AttestationChallengeEndpoint {
  public static var url: URL {
    URL(target: AttestationServiceEndpoint.challenge)
  }
}

// MARK: - AttestationServiceEndpoint + TargetType

extension AttestationServiceEndpoint: TargetType {
  var baseURL: URL {
    Container.shared.attestationServiceUrl()
  }

  var path: String {
    switch self {
    case .challenge:
      "challenge"
    case .clientAttestation:
      "ios/client-attestations"
    case .keyAttestation:
      "ios/key-attestations"
    case .batchKeyAttestations:
      "ios/key-attestations/batch"
    }
  }

  var method: Moya.Method {
    switch self {
    case .challenge:
      .get
    case .batchKeyAttestations,
         .clientAttestation,
         .keyAttestation:
      .post
    }
  }

  var task: Moya.Task {
    switch self {
    case .challenge:
      .requestPlain
    case .batchKeyAttestations(let requestBody as Encodable),
         .clientAttestation(let requestBody as Encodable),
         .keyAttestation(let requestBody as Encodable):
      .requestJSONEncodable(requestBody)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .clientAttestation:
      NetworkHeader.standard.raw
    case .batchKeyAttestations,
         .keyAttestation:
      nil // Handle by ClientAttestationPlugin
    }
  }
}
