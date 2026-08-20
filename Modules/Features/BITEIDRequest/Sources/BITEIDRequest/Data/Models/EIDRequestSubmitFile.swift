

struct EIDRequestSubmitFile: Codable, Equatable {
  let fileName: String
  let hash: String

  private enum CodingKeys: String, CodingKey {
    case fileName = "filename"
    case hash
  }
}

#if DEBUG
extension EIDRequestSubmitFile {
  struct Mock {
    static let sample = EIDRequestSubmitFile(fileName: "fileName", hash: "hash")
  }
}
#endif
