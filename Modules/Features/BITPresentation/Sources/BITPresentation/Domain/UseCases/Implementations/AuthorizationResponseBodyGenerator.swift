import BITAnalytics
import BITAnyCredentialFormat
import BITAppAuth
import BITClaimsPathPointer
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
  func callAsFunction(for compatibleCredential: CompatibleCredential, requestObject: RequestObject, withOrigin: String?) throws -> AuthorizationResponse
}

// MARK: - AuthorizationResponseBodyGenerator

struct AuthorizationResponseBodyGenerator: AuthorizationResponseBodyGeneratorProtocol {

  // MARK: Internal

  func callAsFunction(for compatibleCredential: CompatibleCredential, requestObject: RequestObject, withOrigin: String?) throws -> AuthorizationResponse {
    guard let queryId = compatibleCredential.dcqlQueryId else {
      throw RequestObjectError.invalidQuery
    }

    let credential = compatibleCredential.credential
    let paths = compatibleCredential.presentingPaths

    let vpToken = try createVpToken(credential: credential, requestObject: requestObject, paths: paths, withOrigin: withOrigin)

    return AuthorizationResponse(
      vpToken: [queryId: [vpToken]],
      responseMode: requestObject.responseMode,
      state: requestObject.state)
  }

  // MARK: Private

  @Injected(\.keyManager) private var keyManager: KeyManagerProtocol
  @Injected(\.userSession) private var userSession: Session
  @Injected(\.anyVpTokenGenerator) private var anyVpTokenGenerator: AnyVpTokenGeneratorProtocol
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol
  @Injected(\.analytics) private var analytics: AnalyticsProtocol
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol

  private func createVpToken(credential: VerifiableCredential, requestObject: RequestObject, paths: [ClaimsPathPointer], withOrigin: String?) throws -> VpToken {
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

    return try anyVpTokenGenerator.generate(requestObject: requestObject, credential: anyCredential, keyPair: keyPair, paths: paths, withOrigin: withOrigin)
  }
}
