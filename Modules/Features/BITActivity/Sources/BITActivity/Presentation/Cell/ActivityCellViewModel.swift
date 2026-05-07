import BITCore
import BITL10n
import Factory
import SwiftUI

public struct ActivityCellViewModel: Identifiable, Equatable {

  // MARK: Lifecycle

  public init(detail: ActivityDetail) {
    id = detail.id
    type = detail.type
    createdAt = detail.createdAt
    actorDisplay = detail.actorDisplay
  }

  public init(listItem: ActivityListItem) {
    id = listItem.id
    type = listItem.type
    createdAt = listItem.createdAt
    actorDisplay = listItem.actorDisplay
  }

  // MARK: Public

  public let id: UUID
  public let type: ActivityType

  // MARK: Internal

  var icon: Image {
    switch type {
    case .presentationAccepted: Assets.listIndicatorPresentationAccepted.swiftUIImage
    case .presentationDeclined: Assets.listIndicatorPresentationDeclined.swiftUIImage
    case .issuance: Assets.listIndicatorIssuance.swiftUIImage
    }
  }

  var title: String {
    switch type {
    case .presentationAccepted: L10n.tkActivityPresentationAcceptedTitle
    case .presentationDeclined: L10n.tkActivityPresentationDeclinedTitle
    case .issuance: L10n.tkActivityCredentialAcceptedTitle
    }
  }

  var subtitle: String {
    actorDisplay?.name ?? ""
  }

  var timeStamp: String {
    let date = createdAt.formatted(
      .dateTime
        .locale(currentLocale)
        .year(.defaultDigits)
        .month(.twoDigits)
        .day(.twoDigits))
    let time = createdAt.formatted(
      .dateTime
        .locale(currentLocale)
        .hour(.twoDigits(amPM: .abbreviated))
        .minute(.twoDigits))
    return "\(date) | \(time)"
  }

  var accessibleTimeStamp: String {
    createdAt.formatted(date: .long, time: .shortened)
  }

  // MARK: Private

  private let createdAt: Date
  private let actorDisplay: ActivityActorDisplay?

  private var currentLocale: Locale {
    Locale(identifier: Container.shared.preferredUserLocales().first ?? UserLocale.defaultLocaleIdentifier)
  }
}
