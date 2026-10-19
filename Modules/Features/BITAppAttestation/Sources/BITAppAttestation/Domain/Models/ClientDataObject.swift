struct ClientDataObject: Codable, Equatable, Sendable {
  let challenge: AttestationChallenge
  let bindingKey: BindingKey

  enum CodingKeys: String, CodingKey {
    case challenge
    case bindingKey = "cnf"
  }
}
