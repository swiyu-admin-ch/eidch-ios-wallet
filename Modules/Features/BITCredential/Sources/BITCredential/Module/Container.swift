import BITCredentialShared
import BITJWT
import BITOpenID
import BITVault
import Factory
import Foundation
import NavigatorUI

extension Container {

  // MARK: Public

  public var trustInformationService: Factory<TrustInformationServiceProtocol> {
    self { TrustInformationService() }
  }

  public var selectCredentialBundleItemUseCase: Factory<SelectCredentialBundleItemUseCaseProtocol> {
    self { SelectCredentialBundleItemUseCase() }
  }

  public var rotateNextPresentableBundleItemUseCase: Factory<RotateNextPresentableBundleItemUseCaseProtocol> {
    self { RotateNextPresentableBundleItemUseCase() }
  }

  // MARK: Internal

  var fetchDeferredCredentialService: Factory<FetchDeferredCredentialServiceProtocol> {
    self { FetchDeferredCredentialService() }
  }

  var holderBindingsGenerator: Factory<HolderBindingsGeneratorProtocol> {
    self { HolderBindingsGenerator() }
  }

  var overlayAttributeDateParser: Factory<OverlayAttributeDateParserProtocol> {
    self { OverlayAttributeDateParser() }
  }

  var credentialGenerator: Factory<CredentialGeneratorProtocol> {
    self { CredentialGenerator() }
  }

  var keyBindingGenerator: Factory<KeyBindingGeneratorProtocol> {
    self { KeyBindingGenerator() }
  }

  var metadataCredentialGenerator: Factory<MetadataCredentialGeneratorProtocol> {
    self { MetadataCredentialGenerator() }
  }

  var ocaCredentialGenerator: Factory<OcaCredentialGeneratorProtocol> {
    self { OcaCredentialGenerator() }
  }

  var ocaClusterGenerator: Factory<OcaClusterGeneratorProtocol> {
    self { OcaClusterGenerator() }
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

  @MainActor
  var credentialDetailViewModel: ParameterFactory<UUID, CredentialDetailViewModel> {
    self { @MainActor in CredentialDetailViewModel($0, getActivityHistoryEnabledSubject: self.getActivityHistoryEnabledSubjectUseCase()) }
  }

  @MainActor
  var credentialDetailUpdateViewModel: ParameterFactory<CredentialProtocol, CredentialDetailUpdateViewModel> {
    self { @MainActor in CredentialDetailUpdateViewModel(credential: $0) }
  }

  @MainActor
  var credentialDetailUpdateInfoViewModel: ParameterFactory<CredentialIssuerDisplay?, CredentialDetailUpdateViewModel> {
    self { @MainActor in CredentialDetailUpdateViewModel(issuerDisplay: $0) }
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

  public var refreshCredentialUseCase: Factory<RefreshVerifiableCredentialUseCaseProtocol> {
    self { RefreshVerifiableCredentialUseCase() }
  }

  public var fetchIssuanceTrustInformationUseCase: Factory<FetchIssuanceTrustInformationUseCaseProtocol> {
    self { FetchIssuanceTrustInformationUseCase() }
  }

  public var acceptCredentialUseCase: Factory<AcceptCredentialUseCaseProtocol> {
    self { AcceptCredentialUseCase() }
  }

  // MARK: Internal

  var getCredentialIssuanceSummaryUseCase: Factory<GetCredentialIssuanceSummaryUseCaseProtocol> {
    self { GetCredentialIssuanceSummaryUseCase() }
  }

  var valueTypeResolver: Factory<ValueTypeResolverProtocol> {
    self { ValueTypeResolver() }
  }

  var checkAndUpdateCredentialStatusUseCase: Factory<CheckAndUpdateCredentialStatusUseCaseProtocol> {
    self { CheckAndUpdateCredentialStatusUseCase() }
  }

  var refreshDeferredCredentialUseCase: Factory<RefreshDeferredCredentialUseCaseProtocol> {
    self { RefreshDeferredCredentialUseCase() }
  }

  var refreshVerifiableCredentialsUseCase: Factory<RefreshVerifiableCredentialsUseCaseProtocol> {
    self { RefreshVerifiableCredentialsUseCase() }
  }

  var maxConcurrentVerifiableCredentialRefreshes: Factory<Int> {
    self { 3 }
  }

  var getCredentialRefreshThresholdUseCase: Factory<GetCredentialRefreshThresholdUseCaseProtocol> {
    self { GetCredentialRefreshThresholdUseCase() }
  }

  var mapCredentialsToKeyBindingsUseCase: Factory<MapCredentialsToKeyBindingsUseCaseProtocol> {
    self { MapCredentialsToKeyBindingsUseCase() }
  }

}

// MARK: - Repositories

extension Container {

  public var credentialRepository: Factory<CredentialRepositoryProcotol> {
    self { CredentialRepository() }
  }

}
