import BITAnyCredentialFormat
import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - FetchIssuanceTrustInformationUseCaseProtocol

@Spyable
public protocol FetchIssuanceTrustInformationUseCaseProtocol {
  func callAsFunction(for credential: VerifiableCredential) async throws -> TrustInformation
}

// MARK: - FetchIssuanceTrustInformationUseCase

struct FetchIssuanceTrustInformationUseCase: FetchIssuanceTrustInformationUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(for credential: VerifiableCredential) async throws -> TrustInformation {
    let anyCredential = try createAnyCredentialUseCase.execute(from: credential.payload, format: credential.format)
    return await trustInformationService.fetch(for: anyCredential.issuer, type: .issuance, vcSchemaId: anyCredential.vcSchemaId)
  }

  // MARK: Private

  @Injected(\.trustInformationService) private var trustInformationService: TrustInformationServiceProtocol
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol
}
