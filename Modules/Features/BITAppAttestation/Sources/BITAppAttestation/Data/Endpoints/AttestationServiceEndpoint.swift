import BITNetworking
import Factory
import Foundation
import Moya

// MARK: - AttestationServiceEndpoint

enum AttestationServiceEndpoint {
  case challenge
  case clientAttestation(ClientAttestationRequestBody)
  case keyAttestation(ClientAttestedRequest)
}

// MARK: TargetType

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
    }
  }

  var method: Moya.Method {
    switch self {
    case .challenge:
      .get
    case .clientAttestation,
         .keyAttestation:
      .post
    }
  }

  var task: Moya.Task {
    switch self {
    case .challenge:
      .requestPlain
    case .clientAttestation(let requestBody):
      .requestParameters(
        parameters: requestBody.asDictionary(),
        encoding: JSONEncoding.default)
    case .keyAttestation(let request):
      .requestParameters(
        parameters: request.body.asDictionary(),
        encoding: JSONEncoding.default)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .challenge,
         .clientAttestation:
      NetworkHeader.standard.raw

    case .keyAttestation(let request):
      NetworkHeader.keyAttestation(clientAttestation: request.header.clientAttestation, clientAttestationPop: request.header.clientAttestationPoP).raw
    }
  }
}
