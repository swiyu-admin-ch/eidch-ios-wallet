import RegexBuilder

// MARK: - AttributeType

/// Enum representing the different types of Capture Base attribute types.
public indirect enum AttributeType: Decodable, Equatable {
  case text
  case numeric
  case boolean
  case dateTime
  case binary
  case reference(digest: String)
  case array(type: AttributeType)

  // MARK: Lifecycle

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let type = try container.decode(String.self)

    self = try Self.parseAttributeType(type)
  }

  // MARK: Public

  public var referenceDigest: String? {
    switch self {
    case .reference(let digest):
      digest
    case .array(let innerType):
      innerType.referenceDigest
    default:
      nil
    }
  }

  // MARK: Private

  private static func parseAttributeType(_ type: String) throws -> AttributeType {
    switch type {
    case "Text": .text
    case "Numeric": .numeric
    case "Boolean": .boolean
    case "DateTime": .dateTime
    case "Binary": .binary
    case _ where type.starts(with: "refs:"): try .reference(digest: type.parseReference())
    case _ where try arrayRegex.wholeMatch(in: type) != nil: try .array(type: parseAttributeType(type.parseArray()))
    default: throw OcaError.invalidJsonObject
    }
  }
}

private let arrayRegex = Regex {
  "Array["
  Capture {
    OneOrMore {
      ChoiceOf {
        .word
        "-"
        ":"
        "="
      }
    }
  }
  "]"
}

extension String {
  fileprivate func parseReference() throws -> String {
    guard let reference = split(separator: ":").last else { throw OcaError.invalidCaptureBaseReferenceAttribute }
    return String(reference)
  }

  fileprivate func parseArray() throws -> String {
    guard let match = try arrayRegex.wholeMatch(in: self) else { throw OcaError.invalidCaptureBaseReferenceAttribute }
    let (_, type) = match.output
    return String(type)
  }
}
