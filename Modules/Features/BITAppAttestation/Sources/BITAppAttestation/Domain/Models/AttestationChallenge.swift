public typealias AttestationChallenge = String

// MARK: - AttestationChallenge.Response

extension AttestationChallenge {
  public struct Response: Decodable, Equatable, Sendable {
    public let challenge: AttestationChallenge
  }
}
