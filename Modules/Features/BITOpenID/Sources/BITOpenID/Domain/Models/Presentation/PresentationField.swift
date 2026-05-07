import BITClaimsPathPointer
import BITCore
import Foundation

// MARK: - PresentationField

public struct PresentationField: Equatable {

  // MARK: Lifecycle

  public init(jsonPath: String, value: CodableValue) {
    self.jsonPath = jsonPath
    pathPointer = nil
    self.value = value
  }

  public init(pathPointer: ClaimsPathPointer, value: CodableValue) {
    jsonPath = nil
    self.pathPointer = pathPointer
    self.value = value
  }

  // MARK: Public

  public let jsonPath: String?
  public let pathPointer: ClaimsPathPointer?

  public let value: CodableValue

  public var key: String {
    #warning("PresentationField.jsonPath will be debrecated")
    var key = ""
    if let jsonPath {
      guard let lastPart = jsonPath.split(separator: ".").last else { return jsonPath }
      key = String(lastPart)
    } else if let pathPointer {
      guard case .string(let lastKey) = pathPointer.last else { return pathPointer.stringValue }
      key = lastKey
    }
    return key
  }
}
