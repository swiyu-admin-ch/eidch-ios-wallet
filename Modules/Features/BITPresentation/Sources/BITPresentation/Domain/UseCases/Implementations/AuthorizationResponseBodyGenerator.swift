import BITAnalytics
import BITAnyCredentialFormat
import BITAppAuth
import BITCredential
import BITCredentialShared
import BITCrypto
import BITOpenID
import BITVault
import Factory
import Foundation
import Spyable

// MARK: - AuthorizationResponseBodyGeneratorError

enum AuthorizationResponseBodyGeneratorError: Error {
  case payloadEncryptionFailed
}

// MARK: - AuthorizationResponseBodyGeneratorProtocol

@Spyable
public protocol AuthorizationResponseBodyGeneratorProtocol {
  func callAsFunction(
    for compatibleCredential: CompatibleCredential,
    requestObject: RequestObject,
    inputDescriptor: InputDescriptor?)
    throws -> AuthorizationResponseBody
}

// MARK: - AuthorizationResponseBodyGenerator

struct AuthorizationResponseBodyGenerator: AuthorizationResponseBodyGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(
    for compatibleCredential: CompatibleCredential,
    requestObject: RequestObject,
    inputDescriptor: InputDescriptor?)
    throws -> AuthorizationResponseBody
  {
    if let inputDescriptor {
      let payload = try generateDif(for: compatibleCredential, requestObject: requestObject, inputDescriptor: inputDescriptor)
      return try buildResponseBody(for: payload, requestObject: requestObject, responseType: .dif)
    }
    if (try? requestObject.dcqlQuery) != nil {
      let payload = try generateDcql(for: compatibleCredential, requestObject: requestObject)
      return try buildResponseBody(for: payload, requestObject: requestObject, responseType: .dcql)
    }
    throw RequestObjectError.invalidPayload()
  }

  // MARK: Private

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.anyVpTokenGenerator) private var anyVpTokenGenerator: AnyVpTokenGeneratorProtocol
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol
  @Injected(\.anyDescriptorMapGenerator) private var anyDescriptorMapGenerator: AnyDescriptorMapGeneratorProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.jweEncrypter) private var jweEncrypter: JWEEncrypterProtocol
  @Injected(\.isPayloadEncryptionEnabled) private var isPayloadEncryptionEnabled
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol

  private func generateDif(
    for compatibleCredential: CompatibleCredential,
    requestObject: RequestObject,
    inputDescriptor: InputDescriptor)
    throws -> AuthorizationResponse
  {
    let credential = compatibleCredential.credential
    let fields = compatibleCredential.requestedFields.map(\.key)

    let vpToken = try createVpToken(credential: credential, requestObject: requestObject, fields: fields)
    let descriptorMaps = try anyDescriptorMapGenerator.generate(using: inputDescriptor, vcFormat: credential.format)
    guard
      let definitionId = requestObject.presentationDefinition?.id,
      !definitionId.isEmpty
    else {
      throw RequestObjectError.invalidPayload()
    }
    let presentationSubmission = AuthorizationResponse.PresentationSubmission(
      id: UUID().uuidString,
      definitionId: definitionId,
      descriptorMap: descriptorMaps)
    return AuthorizationResponse(vpToken: vpToken, presentationSubmission: presentationSubmission)
  }

  private func generateDcql(
    for compatibleCredential: CompatibleCredential,
    requestObject: RequestObject)
    throws -> AuthorizationResponse
  {
    guard
      let dcqlQueryId = compatibleCredential.dcqlQueryId
    else {
      throw RequestObjectError.invalidDcqlQuery
    }

    let credential = compatibleCredential.credential
    let fields = compatibleCredential.requestedFields.map(\.key)

    let vpToken = try createVpToken(credential: credential, requestObject: requestObject, fields: fields)

    return AuthorizationResponse(
      vpTokenByCredentialQueryId: [dcqlQueryId: [vpToken]],
      responseMode: requestObject.responseMode)
  }

  private func createVpToken(credential: VerifiableCredential, requestObject: RequestObject, fields: [String]) throws -> VpToken {
    guard
      userSession.isLoggedIn,
      let context = userSession.context
    else {
      userSession.endSession()
      throw UserSessionError.notLoggedIn
    }

    let bundleItem = try selectCredentialBundleItemUseCase(credential)

    let anyCredential = try createAnyCredentialUseCase.execute(from: bundleItem.payload, format: credential.format)
    let query = try QueryBuilder()
      .setContext(context)
      .build()
    var keyPair: VaultKeyPair? = nil
    if
      let identifier = bundleItem.keyBinding?.id,
      let algorithm = bundleItem.keyBinding?.algorithm,
      let vaultAlgorithm = VaultAlgorithm(rawValue: algorithm)
    {
      do {
        keyPair = try keyManager.getKeyPair(withIdentifier: identifier.uuidString, algorithm: vaultAlgorithm, query: query)
      } catch {
        analytics.log(error)
        throw error
      }
    }

    return try anyVpTokenGenerator.generate(requestObject: requestObject, credential: anyCredential, keyPair: keyPair, fields: fields)
  }

  private func buildResponseBody(
    for payload: DictionarySerializable,
    requestObject: RequestObject,
    responseType: AuthorizationResponseType) throws
    -> AuthorizationResponseBody
  {
    guard requestObject.responseMode == .directPostJWT && isPayloadEncryptionEnabled else {
      return .json(payload, responseType)
    }

    guard let jwk = requestObject.clientMetadata?.jwks?.keys.first else {
      throw AuthorizationResponseBodyGeneratorError.payloadEncryptionFailed
    }

    let data = try JSONSerialization.data(withJSONObject: payload.asDictionary())
    let jwe = try jweEncrypter.encrypt(
      data: data,
      publicKey: jwk,
      encryptionAlgorithm: .A128GCM,
      compressionAlgorithm: nil)

    return .jwe(jwe, responseType)
  }
}
