import BITCredential
import BITCredentialShared
import BITOpenID
import Factory
import Spyable

// MARK: - GetCompatibleCredentialsUseCaseProtocol

@Spyable
public protocol GetCompatibleCredentialsUseCaseProtocol {
  func execute(using requestObject: RequestObject) async throws -> [CompatibleCredential]
}

// MARK: - GetCompatibleCredentialsUseCase

struct GetCompatibleCredentialsUseCase: GetCompatibleCredentialsUseCaseProtocol {

  // MARK: Internal

  func execute(using requestObject: RequestObject) async throws -> [CompatibleCredential] {
    guard let dcqlQuery = requestObject.dcqlQuery else {
      throw RequestObjectError.missingQuery
    }

    let allAcceptedCredentials = try await credentialRepository.getAllAcceptedVerifiableCredentials()
    let credentials = filterStatus(of: allAcceptedCredentials)
    guard !credentials.isEmpty else {
      return []
    }

    let compatibleCredentials = try await dcqlCredentialMatcher.match(credentials: credentials, with: dcqlQuery)

    guard !compatibleCredentials.isEmpty else {
      return []
    }

    return compatibleCredentials
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.dcqlCredentialMatcher) private var dcqlCredentialMatcher
  @Injected(\.selectCredentialBundleItemUseCase) private var selectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol

  private func filterStatus(of credentials: [VerifiableCredential]) -> [VerifiableCredential] {
    credentials.filter { credential in
      do {
        let selectedBundleItem = try selectCredentialBundleItemUseCase(credential)
        switch selectedBundleItem.status {
        case .businessExpired,
             .suspended,
             .unknown,
             .unsupported,
             .valid:
          return true
        case .expired,
             .notYetValid,
             .revoked:
          return false
        }
      } catch {
        return false
      }
    }
  }

}
