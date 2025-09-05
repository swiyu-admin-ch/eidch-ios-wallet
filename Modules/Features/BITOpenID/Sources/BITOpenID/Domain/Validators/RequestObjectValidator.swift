import BITCore
import BITJWT
import Factory
import Spyable

// MARK: - RequestObjectValidatorProtocol

@Spyable
public protocol RequestObjectValidatorProtocol {
  func validate(_ requestObject: RequestObject) -> Bool
}

// MARK: - RequestObjectValidator

struct RequestObjectValidator: RequestObjectValidatorProtocol {

  // MARK: Internal

  func validate(_ requestObject: RequestObject) -> Bool {
    requestObject.isValid
  }
}

extension RequestObject {

  // MARK: Fileprivate

  fileprivate var isValid: Bool {
    isResponseValid() &&
      isClientInformationValid() &&
      isClientIdValid() &&
      areInputDescriptorsValid() &&
      isConstraintsPathValid()
  }

  // MARK: Private

  private static let didKey = "did"
  private static let vpTokenKey = "vp_token"
  private static let directPostKey = "direct_post"
  private static let regex = "^did:[a-z0-9]+:[a-zA-Z0-9.\\-_:]+$"
  private static let constraintPathRegex = #".*\[\s*\?.*"#

  private func isResponseValid() -> Bool {
    responseType == Self.vpTokenKey &&
      responseMode == Self.directPostKey
  }

  private func isClientInformationValid() -> Bool {
    clientIdScheme == Self.didKey
  }

  private func isClientIdValid() -> Bool {
    guard let regex = try? Regex(Self.regex) else { return false }
    return !clientId.matches(of: regex).isEmpty
  }

  private func areInputDescriptorsValid() -> Bool {
    let descriptors = presentationDefinition.inputDescriptors
    return descriptors.allSatisfy { descriptor in
      !descriptor.constraints.fields.isEmpty
    }
  }

  private func isConstraintsPathValid() -> Bool {
    guard let regex = try? Regex(Self.constraintPathRegex) else {
      return false
    }

    return presentationDefinition.inputDescriptors.allSatisfy { descriptor in
      descriptor.constraints.fields.allSatisfy { field in
        field.path.allSatisfy { path in
          !path.contains(regex)
        }
      }
    }
  }
}
