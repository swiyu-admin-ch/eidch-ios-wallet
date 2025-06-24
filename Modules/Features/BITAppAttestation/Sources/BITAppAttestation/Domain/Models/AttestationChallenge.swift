public typealias AttestationChallenge = String

// MARK: - AttestationChallenge.Response

extension AttestationChallenge {
  public struct Response: Decodable, Equatable {
    public let challenge: AttestationChallenge
  }
}
