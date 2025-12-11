import BITActivity
import BITCredential
import BITCredentialShared
import BITL10n
import BITNonCompliance
import Factory
import Foundation
import SwiftUI

// MARK: - ActivityDetailViewModelError

enum ActivityDetailViewModelError: Error {
  case unsupportedCredentialType
}

// MARK: - ActivityDetailViewModel

@MainActor
class ActivityDetailViewModel: ObservableObject {

  // MARK: Lifecycle

  init(_ activity: Activity, credentialId: UUID) {
    self.activity = activity
    self.credentialId = credentialId
    cellViewModel = ActivityCellViewModel(activity: activity)
    state = .result(activity: cellViewModel, credential: nil)
  }

  // MARK: Internal

  enum State {
    case result(activity: ActivityCellViewModel, credential: ActivityCredentialViewModel?)
    case error(Error)
  }

  @Published private(set) var state: State
  @Published var isDeleteConfirmationPresented = false

  @Injected(\.isNonComplianceEnabled) var isNonComplianceEnabled

  let activity: Activity

  var actorImage: Data? {
    activity.actorDisplays.findDisplayWithFallback()?.image
  }

  var actorName: String? {
    activity.actorDisplays.findDisplayWithFallback()?.name
  }

  var actorTitle: String {
    switch activity.type {
    case .issuance: L10n.tkActivityActivityDetailIssuerTitle
    case .presentationAccepted,
         .presentationDeclined: L10n.tkActivityActivityDetailVerifierTitle
    }
  }

  func fetchCredential() async {
    do {
      guard let verifiableCredential = try await getCredentialUseCase(id: credentialId) as? VerifiableCredential else {
        throw ActivityDetailViewModelError.unsupportedCredentialType
      }
      let credential = ActivityCredentialViewModel(credential: verifiableCredential, activity: activity)
      state = .result(activity: cellViewModel, credential: credential)
    } catch {
      state = .error(error)
    }
  }

  func showDeleteActivityConfirmation() {
    isDeleteConfirmationPresented = true
  }

  func deleteActivity() {
    isDeleteConfirmationPresented = false
    try? deleteActivityUseCase(activity.id)
  }

  // MARK: Private

  private let cellViewModel: ActivityCellViewModel
  private let credentialId: UUID

  @Injected(\.getCredentialUseCase) private var getCredentialUseCase
  @Injected(\.deleteActivityUseCase) private var deleteActivityUseCase
}
