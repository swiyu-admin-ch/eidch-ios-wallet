struct BatchKeyAttestationRequestBody: Codable, Equatable {

  init(_ keyAttestationBody: [KeyAttestationRequestBody]) {
    keys = keyAttestationBody.enumerated().map { index, body in
      BatchKeyAttestationRequestBody.Item(id: index + 1, bindingKey: body.bindingKey)
    }
  }

  struct Item: Codable, Equatable {
    let id: Int
    let bindingKey: BindingKey

    private enum CodingKeys: String, CodingKey {
      case id
      case bindingKey = "cnf"
    }
  }

  let keys: [Item]
}
