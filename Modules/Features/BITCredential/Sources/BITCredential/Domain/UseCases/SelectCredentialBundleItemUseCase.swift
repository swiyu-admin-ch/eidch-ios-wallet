import BITCredentialShared
import Spyable

// MARK: - SelectCredentialBundleItemUseCaseProtocol

@Spyable
public protocol SelectCredentialBundleItemUseCaseProtocol {
  func callAsFunction(_ credential: VerifiableCredential) throws -> BundleItem
}

// MARK: - SelectCredentialBundleItemUseCase

struct SelectCredentialBundleItemUseCase: SelectCredentialBundleItemUseCaseProtocol {

  func callAsFunction(_ credential: VerifiableCredential) throws -> BundleItem {
    guard
      let bundleItem = credential.bundleItems.first(where: { $0.id == credential.nextPresentableBundleItemId })
    else {
      throw CredentialError.noBundleItem
    }
    return bundleItem
  }
}
