public enum AttestationType: String {
  case client
  case key

  var keychainIdentifier: String {
    switch self {
    case .client: "ch.admin.foitt.swiyu.attestation.client"
    case .key: "ch.admin.foitt.swiyu.attestation.key"
    }
  }
}
