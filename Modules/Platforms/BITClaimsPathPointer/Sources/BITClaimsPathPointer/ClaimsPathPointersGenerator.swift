import BITCore
import Foundation
import Spyable

// MARK: - ClaimsPathPointersGeneratorProtocol

@Spyable
protocol ClaimsPathPointersGeneratorProtocol {
  func callAsFunction(for json: JSON) -> [ClaimsPathPointer]
}

// MARK: - ClaimsPathPointersGenerator

struct ClaimsPathPointersGenerator: ClaimsPathPointersGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(for json: JSON) -> [ClaimsPathPointer] {
    resolveClaims(of: json, currentPath: [])
  }

  // MARK: Private

  private func resolveClaims(of json: Any, currentPath: ClaimsPathPointer) -> [ClaimsPathPointer] {
    switch json {
    case let object as JSON:
      object.flatMap { key, value in
        resolveClaims(of: value, currentPath: currentPath + [.string(key)])
      }
    case let array as [Any]:
      array.enumerated().flatMap { index, value in
        resolveClaims(of: value, currentPath: currentPath + [.index(index)])
      }
    default:
      [currentPath]
    }
  }
}
