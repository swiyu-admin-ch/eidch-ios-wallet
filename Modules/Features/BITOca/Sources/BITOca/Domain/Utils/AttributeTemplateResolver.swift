import BITClaimsPathPointer
import RegexBuilder
import Spyable

// MARK: - AttributeTemplateResolverProtocol

@Spyable
public protocol AttributeTemplateResolverProtocol: Sendable {
  func callAsFunction(_ attribute: String, digest: String, overlays: [any Overlay]) -> String
}

// MARK: - AttributeTemplateResolver

struct AttributeTemplateResolver: AttributeTemplateResolverProtocol {

  // MARK: Internal

  func callAsFunction(_ attribute: String, digest: String, overlays: [any Overlay]) -> String {
    let dataSourceOverlays = getDataSourceOverlays(overlays)
    return attribute.replacing(Self.templateRegex) { match in
      resolveAttributePath(
        match[Self.keyReference],
        digest: match[Self.digestReference] ?? digest,
        rawIndex: match[Self.indexReference],
        join: match[Self.joinReference],
        dataSourceOverlays: dataSourceOverlays)
    }
  }

  // MARK: Private

  private nonisolated(unsafe) static let digestReference = Reference(String?.self)
  private nonisolated(unsafe) static let keyReference = Reference(String?.self)
  private nonisolated(unsafe) static let indexReference = Reference(String?.self)
  private nonisolated(unsafe) static let joinReference = Reference(String?.self)
  private nonisolated(unsafe) static let quoteReference = Reference(Substring.self)

  private nonisolated(unsafe) static let digestReferenceRegex = Regex {
    "refs:"
    Capture(as: digestReference) {
      OneOrMore(CharacterClass(.anyOf(":").inverted))
    } transform: { String($0) }
    ":"
  }

  private nonisolated(unsafe) static let nameRegex = Capture(as: keyReference) {
    ZeroOrMore {
      NegativeLookahead {
        ChoiceOf {
          "{{"
          "["
          ".join("
          "}}"
        }
      }
      CharacterClass.any
    }
  } transform: { String($0) }

  private nonisolated(unsafe) static let indexRegex = Regex {
    "["
    ChoiceOf {
      Capture(as: indexReference) {
        OneOrMore(.digit)
      } transform: { String($0) }
      "null"
    }
    "]"
  }

  private nonisolated(unsafe) static let joinRegex = Capture(as: joinReference) {
    ".join("
    Capture(as: quoteReference) {
      ChoiceOf {
        "'"
        "\""
      }
    }
    Repeat(0...10) {
      NegativeLookahead { quoteReference }
      CharacterClass.any
    }
    quoteReference
    ")"
  } transform: { String($0) }

  private nonisolated(unsafe) static let validTemplateRegex = Regex {
    Optionally {
      digestReferenceRegex
    }
    nameRegex
    Optionally {
      indexRegex
    }
    Optionally {
      joinRegex
    }
  }

  private nonisolated(unsafe) static let templateRegex = Regex {
    "{{"
    ChoiceOf {
      validTemplateRegex
      ZeroOrMore(.any)
    }
    "}}"
  }

  private func getDataSourceOverlays(_ overlays: [any Overlay]) -> [any DataSourceOverlay] {
    var dataSourceOverlays: [any DataSourceOverlay] = overlays
      .compactMap { $0 as? DataSourceOverlay2x0 }
    if dataSourceOverlays.isEmpty {
      dataSourceOverlays = overlays
        .compactMap { $0 as? DataSourceOverlay1x0 }
    }
    return dataSourceOverlays
  }

  private func resolveAttributePath(_ key: String?, digest: String, rawIndex: String?, join: String?, dataSourceOverlays: [any DataSourceOverlay]) -> String {
    guard var path = getPath(for: key, digest: digest, dataSourceOverlays: dataSourceOverlays) else { return "" }
    if let stringIndex = rawIndex {
      guard
        let index = Int(stringIndex),
        path.count(where: { $0 == .null }) == 1
      else { return "" }
      path = path.map { $0 == .null ? .index(index) : $0 }
    }
    return "{{" + path.stringValue + (join ?? "") + "}}"
  }

  private func getPath(for attribute: String?, digest: String, dataSourceOverlays: [any DataSourceOverlay]) -> ClaimsPathPointer? {
    guard
      let attribute,
      let dataSourceOverlay = dataSourceOverlays.first(where: { $0.captureBaseDigest == digest }),
      let path = dataSourceOverlay.attributeSources[attribute]
    else { return nil }
    return path
  }
}
