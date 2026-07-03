import BITCore

struct LocalizedNotificationPayload: Decodable {

  // MARK: Lifecycle

  init(from decoder: Decoder) throws {
    let dynamicContainer = try decoder.container(keyedBy: DynamicCodingKey.self)
    title = try LocalizedDisplay<String>(from: dynamicContainer, withBaseKey: Self.titleKey)
    body = try LocalizedDisplay<String>(from: dynamicContainer, withBaseKey: Self.bodyKey)
  }

  // MARK: Internal

  let title: LocalizedDisplay<String>?
  let body: LocalizedDisplay<String>?

  // MARK: Private

  private static let titleKey = "title"
  private static let bodyKey = "body"

}
