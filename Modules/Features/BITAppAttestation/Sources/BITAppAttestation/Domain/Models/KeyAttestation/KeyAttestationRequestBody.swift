struct KeyAttestationRequestBody: Codable, Equatable {
  let bindingKey: BindingKey

  enum CodingKeys: String, CodingKey {
    case bindingKey = "cnf"
  }
}
