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
  var credentialDetailViewModel: ParameterFactory<VerifiableCredential, CredentialDetailViewModel> {
    self { CredentialDetailViewModel($0) }
  }

  @MainActor
  var credentialDetailModule: ParameterFactory<VerifiableCredential, CredentialDetailModule> {
    self { CredentialDetailModule(credential: $0) }
  }
}

// MARK: - Use cases

extension Container {

  public var getCredentialListUseCase: Factory<GetCredentialListUseCaseProtocol> {
    self { GetCredentialListUseCase() }
  }

  public var getCredentialUseCase: Factory<GetCredentialUseCaseProtocol> {
    self { GetCredentialUseCase() }
  }

  public var checkAndUpdateCredentialStatusUseCase: Factory<CheckAndUpdateCredentialStatusUseCaseProtocol> {
    self { CheckAndUpdateCredentialStatusUseCase() }
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

  public var refreshDeferredCredentialUseCase: Factory<RefreshDeferredCredentialUseCaseProtocol> {
    self { RefreshDeferredCredentialUseCase() }
  }
}

// MARK: - Repositories

extension Container {

  public var credentialRepository: Factory<CredentialRepositoryProcotol> {
    self { CredentialRepository() }
  }

}
