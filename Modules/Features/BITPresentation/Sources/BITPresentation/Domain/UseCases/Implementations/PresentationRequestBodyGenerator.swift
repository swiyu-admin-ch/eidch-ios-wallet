import BITAnalytics
import BITAnyCredentialFormat
import BITAppAuth
import BITCredentialShared
import BITCrypto
import BITLocalAuthentication
import BITOpenID
import BITVault
import Factory
import Foundation

// MARK: - PresentationRequestBodyGenerator

public struct PresentationRequestBodyGenerator: PresentationRequestBodyGeneratorProtocol {

  // MARK: Public

  public func generate(for compatibleCredential: CompatibleCredential, requestObject: RequestObject, inputDescriptor: InputDescriptor) throws -> PresentationRequestBody {
    let credential = compatibleCredential.credential
    let fields = compatibleCredential.requestedFields.map(\.key)

    let vpToken = try createVpToken(credential: credential, requestObject: requestObject, fields: fields)
    let descriptorMaps = try anyDescriptorMapGenerator.generate(using: inputDescriptor, vcFormat: credential.format)
    let presentationSubmission = PresentationRequestBody.PresentationSubmission(
      id: UUID().uuidString,
      definitionId: requestObject.presentationDefinition.id,
      descriptorMap: descriptorMaps)
    return PresentationRequestBody(vpToken: vpToken, presentationSubmission: presentationSubmission)
  }

  // MARK: Private

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.anyVpTokenGenerator) private var anyVpTokenGenerator: AnyVpTokenGeneratorProtocol
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol
  @Injected(\.anyDescriptorMapGenerator) private var anyDescriptorMapGenerator: AnyDescriptorMapGeneratorProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol

  private func createVpToken(credential: Credential, requestObject: RequestObject, fields: [String]) throws -> VpToken {
    guard
      userSession.isLoggedIn,
      let context = userSession.context
    else {
      throw UserSessionError.notLoggedIn
    }

    let anyCredential = try createAnyCredentialUseCase.execute(from: credential.payload, format: credential.format)
    let query = try QueryBuilder()
      .setContext(context)
      .build()
    var keyPair: VaultKeyPair? = nil
    if let identifier = credential.keyBinding?.id, let algorithm = credential.keyBinding?.algorithm, let vaultAlgorithm = VaultAlgorithm(rawValue: algorithm) {
      do {
        keyPair = try keyManager.getKeyPair(withIdentifier: identifier.uuidString, algorithm: vaultAlgorithm, query: query)
      } catch {
        analytics.log(error)
        throw error
      }
    }

    return try anyVpTokenGenerator.generate(requestObject: requestObject, credential: anyCredential, keyPair: keyPair, fields: fields)
  }

}
