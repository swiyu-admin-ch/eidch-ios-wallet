import Factory
import Foundation
import Spyable

// MARK: - OcaCaptureBaseDigestsValidatorProtocol

@Spyable
public protocol OcaCaptureBaseDigestsValidatorProtocol {
  func validate(_ rawOcaData: Data) -> Bool
}

// MARK: - OcaCaptureBaseDigestsValidator

public struct OcaCaptureBaseDigestsValidator: OcaCaptureBaseDigestsValidatorProtocol {

  // MARK: Public

  public func validate(_ rawOcaData: Data) -> Bool {
    guard
      let ocaData = try? JSONSerialization.jsonObject(with: rawOcaData) as? [String: Any],
      let captureBases = ocaData["capture_bases"] as? [[String: Any]]
    else {
      return false
    }
    for captureBase in captureBases {
      guard
        let baseData = try? JSONSerialization.data(withJSONObject: captureBase),
        cesrHashValidator.validate(data: baseData)
      else {
        return false
      }
    }
    return true
  }

  // MARK: Private

  @Injected(\.ocaCESRHashValidator) private var cesrHashValidator: OcaCESRHashValidatorProtocol
}
