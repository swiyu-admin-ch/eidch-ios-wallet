import BITCore
import BITJWT
import Factory

// MARK: - ValidateRequestObjectUseCase

struct ValidateRequestObjectUseCase: ValidateRequestObjectUseCaseProtocol {

  // MARK: Internal

  func execute(_ requestObject: RequestObject) async -> Bool {
    guard requestObject.isValid else { return false }
    guard let jwtRequestObject = requestObject as? JWTRequestObject else {
      return true
    }
    return await validateJWS(of: jwtRequestObject.jws)
  }

  // MARK: Private

  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator: JWSSignatureValidatorProtocol

  private func validateJWS(of jwsRequestObject: JWS<RequestObject>) async -> Bool {
    guard jwsRequestObject.header.algorithm == JWTAlgorithm.ES256 else { return false }
    return (try? await jwsSignatureValidator.validate(jwsRequestObject, did: jwsRequestObject.payload.clientId)) ?? false
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
