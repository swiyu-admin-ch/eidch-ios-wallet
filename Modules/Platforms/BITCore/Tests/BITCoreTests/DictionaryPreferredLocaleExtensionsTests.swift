import Testing
@testable import BITCore

struct DictionaryPreferredLocaleExtensionsTests {

  @Test
  func findValue_exactMatch_returnsMatch() {
    let dictionary = ["en-US": "Test en-US", "en": "Test en", "": "Test"]

    let result = dictionary.findValue(considering: ["en-US"], fallback: nil)

    #expect(result == "Test en-US")
  }

  @Test
  func findValue_multipleExactMatches_respectsOrder() {
    let dictionary = ["en-US": "Test en-US", "de-DE": "Test de-DE", "": "Test"]

    let result = dictionary.findValue(considering: ["de-DE", "en-US"], fallback: nil)

    #expect(result == "Test de-DE")
  }

  @Test
  func findValue_languageMatch_returnsMatch() {
    let dictionary = ["en": "Test en", "fr": "Test fr", "": "Test"]

    let result = dictionary.findValue(considering: ["en-GB"], fallback: nil)

    #expect(result == "Test en")
  }

  @Test
  func findValue_multipleLanguageMatches_respectsOrder() {
    let dictionary = ["en": "Test en", "de": "Test de", "": "Test"]

    let result = dictionary.findValue(considering: ["de-CH", "en-GB"], fallback: nil)

    #expect(result == "Test de")
  }

  @Test
  func findValue_languageMatchReverse_returnsMatch() {
    let dictionary = ["en-GB": "Test en-GB", "fr": "Test fr", "": "Test"]

    let result = dictionary.findValue(considering: ["en"], fallback: nil)

    #expect(result == "Test en-GB")
  }

  @Test
  func findValue_languagePriority_respectsOrder() {
    let dictionary = ["en": "Test en", "de-CH": "Test de-CH"]

    let result = dictionary.findValue(considering: ["de", "en"], fallback: nil)

    #expect(result == "Test de-CH")
  }

  @Test
  func findValue_regionalMatch_returnsFallback() {
    let dictionary = ["en-US": "Test en-US", "fr-FR": "Test fr-FR", "": "Test"]

    let result = dictionary.findValue(considering: ["en-GB"], fallback: nil)

    #expect(result == "Test")
  }

  @Test
  func findValue_reverseMultipleRegionalVariants_returnsFirstMatch() {
    let dictionary = ["en-GB": "Test en-GB", "en-US": "Test en-US", "": "Test"]

    let result = dictionary.findValue(considering: ["en"], fallback: nil)

    #expect(result == "Test en-GB" || result == "Test en-US")
  }

  @Test
  func findValue_exactMatchAndLanguageMatch_returnsExactMatch() {
    let dictionary = ["en": "Test en", "en-GB": "Test en-GB", "": "Test"]

    let result = dictionary.findValue(considering: ["en-GB"], fallback: nil)

    #expect(result == "Test en-GB")
  }

  @Test
  func findValue_multipleLocales_returnsBetterMatch() {
    let dictionary = ["fr": "Test fr", "de": "Test de", "": "Test"]

    let result = dictionary.findValue(considering: ["it-IT", "de-DE"], fallback: nil)

    #expect(result == "Test de")
  }

  @Test
  func findValue_emptyLocale_usesEmptyFallback() {
    let dictionary = ["en": "Test en", "": "Test"]

    let result = dictionary.findValue(considering: [""], fallback: "Fallback")

    #expect(result == "Test")
  }

  @Test
  func findValue_withEmptyFallback_returnsEmptyFallback() {
    let dictionary = ["fr": "Test fr", "": "Test"]

    let result = dictionary.findValue(considering: ["it-IT"], fallback: "Fallback")

    #expect(result == "Test")
  }

  @Test
  func findValue_withFallback_returnsFallback() {
    let dictionary = ["fr": "Test fr"]

    let result = dictionary.findValue(considering: ["it-IT"], fallback: "Fallback")

    #expect(result == "Fallback")
  }

  @Test
  func findValue_noFallback_returnsNil() {
    let dictionary = ["fr": "Test fr"]

    let result = dictionary.findValue(considering: ["it-IT"], fallback: nil)

    #expect(result == nil)
  }

  @Test
  func findValue_notMatchingPrefix_returnsMatch() {
    let dictionary = ["enoch": "Wrong", "en": "Test en"]

    let result = dictionary.findValue(considering: ["en-US"], fallback: nil)

    #expect(result == "Test en")
  }

  @Test
  func findValue_emptyDictionary_returnsFallback() {
    let dictionary = [String: String]()

    let result = dictionary.findValue(considering: ["en-US"], fallback: "Fallback")

    #expect(result == "Fallback")
  }
}
