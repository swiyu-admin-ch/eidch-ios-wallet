public struct KeyAttestationRequestBody: Codable, Equatable {

  public init(bindingKey: BindingKey) {
    self.bindingKey = bindingKey
  }

  let bindingKey: BindingKey

  enum CodingKeys: String, CodingKey {
    case bindingKey = "cnf"
  }
}
