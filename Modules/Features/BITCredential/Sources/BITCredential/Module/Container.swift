import BITCredentialShared
import BITJWT
import BITOpenID
import BITVault
import Factory
import SwiftUI

extension Container {

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
  var credentialDetailViewModel: ParameterFactory<(Credential, CredentialDetailInternalRoutes), CredentialDetailViewModel> {
    self { CredentialDetailViewModel($0, router: $1) }
  }

  @MainActor
  var credentialDetailModule: ParameterFactory<Credential, CredentialDetailModule> {
    self { CredentialDetailModule(credential: $0) }
  }

  var credentiaDetaillWrongDataViewModel: ParameterFactory<CredentialDetailInternalRoutes, CredentialDetailWrongDataViewModel> {
    self { CredentialDetailWrongDataViewModel(router: $0) }
  }

}

// MARK: - Use cases

extension Container {

  public var getCredentialListUseCase: Factory<GetCredentialListUseCaseProtocol> {
    self { GetCredentialListUseCase() }
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
}

// MARK: - Repositories

extension Container {

  public var databaseCredentialRepository: Factory<CredentialRepositoryProtocol> {
    self { RealmCredentialRepository() }
  }

  public var deferredCredentialRepository: Factory<DeferredCredentialRepositoryProtocol> {
    self { DeferredCredentialRepository() }
  }
}
