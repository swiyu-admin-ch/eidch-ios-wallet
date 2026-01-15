// MARK: - NonCompliantActorsResponse

struct NonCompliantActorsResponse: Codable {
  let nonCompliantActors: [NonCompliantActor]

  struct NonCompliantActor: Codable {
    let reason: [String: String]
    let did: String
  }
}

extension NonCompliantActor {
  init(_ response: NonCompliantActorsResponse.NonCompliantActor) {
    reason = response.reason
    did = response.did
  }
}
