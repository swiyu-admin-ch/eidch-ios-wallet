import Foundation

// MARK: - BatchKeyAttestationResponse

struct BatchKeyAttestationResponse: Codable, Equatable {
  let keyAttestations: [Item]

  struct Item: Codable, Equatable {
    let id: Int
    let response: String

    private enum CodingKeys: String, CodingKey {
      case id
      case response = "keyAttestation"
    }
  }
}

#if DEBUG
extension BatchKeyAttestationResponse {
  struct Mock {
    static let sample = BatchKeyAttestationResponse(keyAttestations: [
      BatchKeyAttestationResponse.Item(id: 1, response: "key-attestation-1"),
      BatchKeyAttestationResponse.Item(id: 2, response: "key-attestation-2"),
    ])

    static let sampleUnordered = BatchKeyAttestationResponse(keyAttestations: [
      BatchKeyAttestationResponse.Item(id: 2, response: "key-attestation-2"),
      BatchKeyAttestationResponse.Item(id: 1, response: "key-attestation-1"),
    ])

    static let sampleSingle = BatchKeyAttestationResponse(keyAttestations: [
      BatchKeyAttestationResponse.Item(id: 1, response: "key-attestation-1"),
    ])

    static func data(from response: BatchKeyAttestationResponse = sample) throws -> Data {
      try JSONEncoder().encode(response)
    }
  }
}

#endif
