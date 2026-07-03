import Testing
@testable import BITPushNotification

struct NotificationLocalizationServiceTests {

  // MARK: Internal

  @Test(arguments: [
    (languageCodes: ["de-CH", "en"], expectedTitle: "Deutsch Titel", expectedBody: "Deutsch body"),
    (languageCodes: ["fr", "en"], expectedTitle: "Francais titre", expectedBody: "Francais corps"),
    (languageCodes: ["it", "en"], expectedTitle: "English title", expectedBody: "English body"),
  ])
  func localize_returnsExpectedContent(languageCodes: [String], expectedTitle: String, expectedBody: String) {
    let content = service.localize(from: data, considering: languageCodes)

    #expect(content?.title == expectedTitle)
    #expect(content?.body == expectedBody)
  }

  @Test
  func localize_onlyTitleMatches_returnsTitleContent() {
    let content = service.localize(
      from: [
        "title#de-CH": "Deutsch Titel",
        "body#en": "English body",
      ],
      considering: ["de-CH"])

    #expect(content?.title == "Deutsch Titel")
    #expect(content?.body == nil)
  }

  @Test
  func localize_incorrectData_returnsNil() {
    let content = service.localize(
      from: [
        "notification_type": "NEW_MESSAGE",
        "title_extra#de": "Wrong title",
        "body_extra#de": "Wrong body",
      ],
      considering: ["de", "en"])

    #expect(content == nil)
  }

  // MARK: Private

  private let service = NotificationLocalizationService()

  private let data: [String: Any] = [
    "notification_type": "NEW_MESSAGE",
    "title#en": "English title",
    "title#de-CH": "Deutsch Titel",
    "title#fr-FR": "Francais titre",
    "body#en": "English body",
    "body#de-CH": "Deutsch body",
    "body#fr-FR": "Francais corps",
  ]
}
