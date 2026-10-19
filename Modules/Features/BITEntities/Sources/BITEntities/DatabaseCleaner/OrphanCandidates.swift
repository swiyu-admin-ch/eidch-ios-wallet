import Foundation

// MARK: - OrphanCandidates

/// The content-hashed rows mutation may leave without an owner.
/// Wee basically capture it before the write: afterwards the entity no longer points at the rows it just released.
public struct OrphanCandidates {

  // MARK: Lifecycle

  public init(_ credential: CredentialEntity) {
    let activities = Array(credential.activities)
    let renderings = [credential.credentialRendering] + activities.map(\.credentialRendering)

    renderingHashes = Set(renderings.compactMap { $0?.contentHash })
    rawCredentialDataHashes = Set(([credential.rawCredentialData] + activities.map(\.rawCredentialData)).compactMap { $0?.contentHash })
    imageHashes = renderings.compactMap { $0 }.displayImages()
      .union(activities.actorImages())
  }

  public init(_ activity: CredentialActivityEntity) {
    renderingHashes = Set([activity.credentialRendering?.contentHash].compactMap { $0 })
    rawCredentialDataHashes = Set([activity.rawCredentialData?.contentHash].compactMap { $0 })
    imageHashes = (activity.credentialRendering?.displayImages ?? []).union(activity.actorImages)
  }

  // MARK: Internal

  let renderingHashes: Set<String>
  let rawCredentialDataHashes: Set<String>
  let imageHashes: Set<String>

  var isEmpty: Bool {
    renderingHashes.isEmpty && rawCredentialDataHashes.isEmpty && imageHashes.isEmpty
  }
}
