import Foundation
import RegexBuilder

extension String {

  // MARK: Internal

  func migrateJsonPathTemplatesToClaimsPathPointerTemplates() -> String {
    replacing(Self.jsonPathTemplateRegex) { match in
      let key = match[Self.keyReference]
      return "{{[\"\(key)\"]}}"
    }
  }

  // MARK: Private

  private static let keyReference = Reference(String.self)

  private static let jsonPathTemplateRegex = Regex {
    "{{"
    "$."
    Capture(as: keyReference) {
      OneOrMore {
        CharacterClass(.word)
      }
    } transform: { String($0) }
    "}}"
  }
}
