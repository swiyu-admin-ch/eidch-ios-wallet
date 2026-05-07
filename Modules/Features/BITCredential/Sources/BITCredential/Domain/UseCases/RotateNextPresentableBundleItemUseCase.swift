import BITCredentialShared
import Factory
import Foundation
import Spyable

// MARK: - RotateNextPresentableBundleItemUseCaseProtocol

@Spyable
public protocol RotateNextPresentableBundleItemUseCaseProtocol {
  func callAsFunction(_ credential: VerifiableCredential) async throws
}

// MARK: - RotateNextPresentableBundleItemUseCase

struct RotateNextPresentableBundleItemUseCase: RotateNextPresentableBundleItemUseCaseProtocol {

  // MARK: Internal

  func callAsFunction(_ credential: VerifiableCredential) async throws {
    guard
      let currentIndex = credential.bundleItems.firstIndex(where: { $0.id == credential.nextPresentableBundleItemId })
    else {
      throw CredentialError.noBundleItem
    }

    var credentialCopy = credential
    credentialCopy.bundleItems[currentIndex].presented = true

    guard let nextBundleItem = nextBundleItem(after: currentIndex, in: credentialCopy.bundleItems) else {
      throw CredentialError.noBundleItem
    }

    credentialCopy.nextPresentableBundleItemId = nextBundleItem.id
    _ = try await credentialRepository.update(verifiableCredential: credentialCopy)
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository

  private func nextBundleItem(after currentIndex: Int, in bundleItems: [BundleItem]) -> BundleItem? {
    guard bundleItems.count > 1 else { return bundleItems.randomElement() }

    for offset in 1..<bundleItems.count {
      let nextIndex = (currentIndex + offset) % bundleItems.count
      let bundleItem = bundleItems[nextIndex]
      if !bundleItem.presented {
        return bundleItem
      }
    }

    return bundleItems.randomElement()
  }
}
