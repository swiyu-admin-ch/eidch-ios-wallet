// MARK: - VcSdJwtTokenStatus

/// https://www.ietf.org/archive/id/draft-ietf-oauth-status-list-03.html
public struct VcSdJwtTokenStatus: Codable, Equatable {
  public let statusList: StatusList

  enum CodingKeys: String, CodingKey {
    case statusList = "status_list"
  }
}

// MARK: VcSdJwtTokenStatus.StatusList

extension VcSdJwtTokenStatus {

  public struct StatusList: Codable, Equatable {
    public let index: Int
    public let uri: String

    enum CodingKeys: String, CodingKey {
      case index = "idx"
      case uri
    }
  }
}
