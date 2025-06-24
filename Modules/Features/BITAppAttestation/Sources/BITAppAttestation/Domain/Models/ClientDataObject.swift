struct ClientDataObject: Codable, Equatable {
  let challenge: AttestationChallenge
  let bindingKey: BindingKey

  enum CodingKeys: String, CodingKey {
    case challenge
    case bindingKey = "cnf"
  }
}
