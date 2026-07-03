// MARK: - PushIdRegistrationBody

struct PushIdRegistrationBody: Codable {
  let pushId: String
}

#if DEBUG
extension PushIdRegistrationBody {
  struct Mock {
    static let sample = PushIdRegistrationBody(pushId: "pushId")
  }
}
#endif
