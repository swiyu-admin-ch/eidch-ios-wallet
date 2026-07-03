import BITCore

// MARK: - VersionEnforcement

public struct VersionEnforcement: Equatable {

  // MARK: Lifecycle

  init(type: VersionEnforcementType, messages: [Message] = []) {
    self.type = type
    self.messages = messages
  }

  // MARK: Internal

  let type: VersionEnforcementType
  let messages: [Message]
}

// MARK: VersionEnforcement.Message

extension VersionEnforcement {

  struct Message: Decodable, DisplayLocalizable, Equatable {
    let title: String
    let body: String
    let locale: UserLocale?
  }
}
