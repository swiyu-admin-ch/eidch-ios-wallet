import BITAppAttestation
import BITCore
import BITJWT
import BITSwiyuSharedKMP
import Factory
import Foundation
import Spyable

// MARK: - RequestObjectValidationError

enum RequestObjectValidationError: Error {
  case invalidJWSSignatureAlgorithm
  case invalidClientId
  case invalidAudience
  case invalidResponseType
  case invalidVerifierAttestation
  case transactionDataNotSupported
  case invalidState
  case verifierAttestationNotSupported
  case verifierAttestationDidNotTrusted
  case decentralizedIdentifierNotSupported
}

// MARK: - RequestObjectValidatorProtocol

@Spyable
public protocol RequestObjectValidatorProtocol {
  func validate(_ jws: RequestObjectJWS, transport: PresentationTransport) async throws
}

// MARK: - RequestObjectValidator

struct RequestObjectValidator: RequestObjectValidatorProtocol {

  // MARK: Internal

  func validate(_ jws: RequestObjectJWS, transport: PresentationTransport) async throws {
    guard jws.header.algorithm == JWTAlgorithm.ES256 else {
      throw RequestObjectValidationError.invalidJWSSignatureAlgorithm
    }

    let clientIdentifier = jws.payload.clientIdentifier

    switch (clientIdentifier.prefix, transport) {
    case (.decentralizedIdentifier, .network):
      try await verifyWithDid(jws, clientIdentifier: clientIdentifier)
    case (.decentralizedIdentifier, .proximity):
      throw RequestObjectValidationError.decentralizedIdentifierNotSupported
    case (.verifierAttestation, .proximity):
      try await verifyWithAttestation(jws, clientIdentifier: clientIdentifier)
    case (.verifierAttestation, .network):
      throw RequestObjectValidationError.verifierAttestationNotSupported
    }

    try validateAudience(jws)
    try jws.payload.validate()

    if transport == .network {
      try await validateTrustStatements(jws)
    }
  }

  // MARK: Private

  @Injected(\.jwsValidator) private var jwsValidator
  @Injected(\.jwsSignatureValidator) private var jwsSignatureValidator
  @Injected(\.jwsDecoder) private var jwsDecoder
  @Injected(\.trustStatementValidator) private var trustStatementValidator
  @Injected(\.didResolverHelper) private var didResolverHelper
  @Injected(\.attestationServiceTrustedDids) private var trustedAttestationDids: [String]

  private func verifyWithDid(_ jws: RequestObjectJWS, clientIdentifier: ClientIdentifier)
    async throws
  {
    try await jwsValidator.validate(jws)
    let kidDid = try didResolverHelper.getDid(from: jws.header.keyIdentifier)
    guard
      clientIdentifier.clientId.normalizedDid() == kidDid,
      TrustEnvironment(did: clientIdentifier.clientId.normalizedDid()) != .external
    else {
      throw RequestObjectValidationError.invalidClientId
    }
  }

  private func verifyWithAttestation(_ jws: RequestObjectJWS, clientIdentifier: ClientIdentifier)
    async throws
  {
    guard
      let rawAttestation = attestationJWT(fromRawJWS: jws.rawJWS),
      let attestationData = rawAttestation.data(using: .utf8)
    else {
      throw RequestObjectValidationError.invalidVerifierAttestation
    }

    let attestation: VerifierAttestationJWS

    attestation = try jwsDecoder.decode(VerifierAttestationJWT.self, from: attestationData)

    guard
      attestation.header.type == VerifierAttestationJWT.expectedType,
      attestation.payload.subject == clientIdentifier.clientId.normalizedDid()
    else {
      throw RequestObjectValidationError.invalidVerifierAttestation
    }

    try jwsSignatureValidator.validate(jws, with: attestation.payload.cnf.jwk)

    try await jwsValidator.validate(attestation)

    let attestationIssuerDid = try didResolverHelper.getDid(from: attestation.header.keyIdentifier)

    guard trustedAttestationDids.contains(attestationIssuerDid) else {
      throw RequestObjectValidationError.verifierAttestationDidNotTrusted
    }
  }

  private func validateAudience(_ jws: RequestObjectJWS) throws {
    if jws.payload.audience == nil || jws.payload.audience == "https://self-issued.me/v2" { return }
    guard jws.payload.audience == jws.payload.issuer else {
      throw RequestObjectValidationError.invalidAudience
    }
  }

  private func attestationJWT(fromRawJWS rawJWS: String) -> String? {
    guard
      let headerSegment = rawJWS.split(separator: ".", maxSplits: 1).first,
      let header = String(headerSegment).base64EncodedURLSafe.base64Decoded,
      let json = try? header.toJsonObject() as? [String: Any]
    else {
      return nil
    }
    return json["jwt"] as? String
  }

  private func validateTrustStatements(_ jws: RequestObjectJWS) async throws {
    let did = try didResolverHelper.getDid(from: jws.header.keyIdentifier)
    if let vqPS = jws.payload.verificationQueryPublicStatement {
      try await trustStatementValidator.validate(vqPS, for: did)
    }
  }
}

extension RequestObject {

  // MARK: Fileprivate

  fileprivate func validate() throws {
    try validateResponseType()
    try validateTransactionDataIsNil()
    try validateState()
  }

  // MARK: Private

  private func validateResponseType() throws {
    guard responseType == "vp_token" else {
      throw RequestObjectValidationError.invalidResponseType
    }
  }

  private func validateTransactionDataIsNil() throws {
    guard transactionData == nil else {
      throw RequestObjectValidationError.transactionDataNotSupported
    }
  }

  private func validateState() throws {
    guard responseMode != .dcApiJWT else { return }

    guard let credentials = dcqlQuery.credentials else { return }

    let hasQueryWithoutHolderBinding = credentials.contains(where: {
      $0.requireCryptographicHolderBinding == nil
        || $0.requireCryptographicHolderBinding?.boolValue == false
    })

    guard !hasQueryWithoutHolderBinding || state != nil else {
      throw RequestObjectValidationError.invalidState
    }
  }
}
