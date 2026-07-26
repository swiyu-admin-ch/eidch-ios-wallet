import BITCore
import BITJWT
import BITSwiyuSharedKMP
import Factory
import Spyable

// MARK: - RequestObjectValidationError

enum RequestObjectValidationError: Error {
  case invalidJWSSignatureAlgorithm
  case invalidClientId
  case invalidAudience
  case invalidResponseType
  case transactionDataNotSupported
  case invalidState
}

// MARK: - RequestObjectValidatorProtocol

@Spyable
public protocol RequestObjectValidatorProtocol {
  func validate(_ jws: RequestObjectJWS) async throws
}

// MARK: - RequestObjectValidator

struct RequestObjectValidator: RequestObjectValidatorProtocol {

  // MARK: Internal

  func validate(_ jws: RequestObjectJWS) async throws {
    guard jws.header.algorithm == JWTAlgorithm.ES256 else {
      throw RequestObjectValidationError.invalidJWSSignatureAlgorithm
    }
    try await jwsValidator.validate(jws)
    try validateClientId(jws)
    try validateAudience(jws)
    try jws.payload.validate()
    try requestObjectEncryptionValidator.validate(jws.payload)
  }

  // MARK: Private

  @Injected(\.requestObjectEncryptionValidator) private var requestObjectEncryptionValidator
  @Injected(\.jwsValidator) private var jwsValidator
  @Injected(\.didResolverHelper) private var didResolverHelper

  private func validateClientId(_ jws: RequestObjectJWS) throws {
    let did = try didResolverHelper.getDid(from: jws.header.keyIdentifier)
    guard jws.payload.clientId.normalizedDid() == did else {
      throw RequestObjectValidationError.invalidClientId
    }
  }

  private func validateAudience(_ jws: RequestObjectJWS) throws {
    if jws.payload.audience == nil || jws.payload.audience == "https://self-issued.me/v2" { return }
    guard jws.payload.audience == jws.payload.issuer else {
      throw RequestObjectValidationError.invalidAudience
    }
  }
}

extension RequestObject {

  // MARK: Fileprivate

  fileprivate func validate() throws {
    try validateResponseType()
    try validateClientId()
    try validateTransactionDataIsNil()
    try validateState()
  }

  // MARK: Private

  private static let regex = "^did:[a-z0-9]+:[a-zA-Z0-9.\\-_:]+$"

  private func validateResponseType() throws {
    guard responseType == "vp_token" else {
      throw RequestObjectValidationError.invalidResponseType
    }
  }

  private func validateClientId() throws {
    guard let regex = try? Regex(Self.regex) else {
      throw RequestObjectValidationError.invalidClientId
    }
    guard !clientId.normalizedDid().matches(of: regex).isEmpty else {
      throw RequestObjectValidationError.invalidClientId
    }
  }

  private func validateTransactionDataIsNil() throws {
    guard transactionData == nil else {
      throw RequestObjectValidationError.transactionDataNotSupported
    }
  }

  private func validateState() throws {
    guard responseMode != .dcApiJWT else { return }

    guard let credentials = dcqlQuery?.credentials else { return }

    let hasQueryWithoutHolderBinding = credentials.contains(where: {
      $0.requireCryptographicHolderBinding == nil || $0.requireCryptographicHolderBinding?.boolValue == false
    })

    guard !hasQueryWithoutHolderBinding || state != nil else {
      throw RequestObjectValidationError.invalidState
    }
  }
}
