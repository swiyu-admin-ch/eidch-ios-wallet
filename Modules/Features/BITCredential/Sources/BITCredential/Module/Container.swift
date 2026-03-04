import BITCredentialShared
import BITJWT
import BITOpenID
import BITVault
import Factory
import SwiftUI

extension Container {

  // MARK: Public

  public var trustInformationService: Factory<TrustInformationServiceProtocol> {
    self { TrustInformationService() }
  }

  // MARK: Internal

  var fetchDeferredCredentialService: Factory<FetchDeferredCredentialServiceProtocol> {
    self { FetchDeferredCredentialService() }
  }

  var holderBindingContextGenerator: Factory<HolderBindingContextGeneratorProtocol> {
    self { HolderBindingContextGenerator() }
  }

  var overlayAttributeDateParser: Factory<OverlayAttributeDateParserProtocol> {
    self { OverlayAttributeDateParser() }
  }

  var credentialGenerator: Factory<CredentialGeneratorProtocol> {
    self { CredentialGenerator() }
  }

  var metadataCredentialGenerator: Factory<MetadataCredentialGeneratorProtocol> {
    self { MetadataCredentialGenerator() }
  }

  var ocaCredentialGenerator: Factory<OcaCredentialGeneratorProtocol> {
    self { OcaCredentialGenerator() }
  }

  var ocaClaimGenerator: Factory<OcaClaimGeneratorProtocol> {
    self { OcaClaimGenerator() }
  }

  var credentialKeyRepository: Factory<CredentialKeyRepositoryProtocol> {
    self { CredentialKeyRepository() }
  }
}

// MARK: - Credential detail

extension Container {

  var credentialDetailRouter: Factory<CredentialDetailRouter> {
    self { CredentialDetailRouter() }
  }

  @MainActor
  var credentialDetailViewModel: ParameterFactory<(CredentialProtocol, CredentialDetailDelegate?), CredentialDetailViewModel> {
    self { CredentialDetailViewModel($0, delegate: $1) }
  }

  @MainActor
  var credentialDetailModule: ParameterFactory<(CredentialProtocol, CredentialDetailDelegate?), CredentialDetailModule> {
    self { CredentialDetailModule(credential: $0, delegate: $1) }
  }
}

// MARK: - Use cases

extension Container {

  // MARK: Public

  public var getCredentialListUseCase: Factory<GetCredentialListUseCaseProtocol> {
    self { GetCredentialListUseCase() }
  }

  public var getCredentialUseCase: Factory<GetCredentialUseCaseProtocol> {
    self { GetCredentialUseCase() }
  }

  public var deleteCredentialUseCase: Factory<DeleteCredentialUseCaseProtocol> {
    self { DeleteCredentialUseCase() }
  }

  public var fetchCredentialUseCase: Factory<FetchCredentialUseCaseProtocol> {
    self { FetchCredentialUseCase() }
  }

  public var getCredentialDisplayUseCase: Factory<GetCredentialDisplayUseCaseProtocol> {
    self { GetCredentialDisplayUseCase() }
  }

  public var saveDeferredCredentialUseCase: Factory<SaveDeferredCredentialUseCaseProtocol> {
    self { SaveDeferredCredentialUseCase() }
  }

  public var refreshCredentialsUseCase: Factory<RefreshCredentialsUseCaseProtocol> {
    self { RefreshCredentialsUseCase() }
  }

  public var fetchIssuanceTrustInformationUseCase: Factory<FetchIssuanceTrustInformationUseCaseProtocol> {
    self { FetchIssuanceTrustInformationUseCase() }
  }

  public var acceptCredentialUseCase: Factory<AcceptCredentialUseCaseProtocol> {
    self { AcceptCredentialUseCase() }
  }

  // MARK: Internal

  var checkAndUpdateCredentialStatusUseCase: Factory<CheckAndUpdateCredentialStatusUseCaseProtocol> {
    self { CheckAndUpdateCredentialStatusUseCase() }
  }

  var refreshDeferredCredentialUseCase: Factory<RefreshDeferredCredentialUseCaseProtocol> {
    self { RefreshDeferredCredentialUseCase() }
  }

}

// MARK: - Repositories

extension Container {

  public var credentialRepository: Factory<CredentialRepositoryProcotol> {
    self { CredentialRepository() }
  }

}
