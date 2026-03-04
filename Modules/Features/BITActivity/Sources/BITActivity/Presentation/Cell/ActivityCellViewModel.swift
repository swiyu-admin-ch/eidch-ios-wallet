import BITCore
import BITL10n
import Factory
import SwiftUI

public struct ActivityCellViewModel: Identifiable {

  // MARK: Lifecycle

  public init(activity: Activity) {
    self.activity = activity
  }

  // MARK: Public

  public var id: UUID {
    activity.id
  }

  // MARK: Internal

  let activity: Activity

  var icon: Image {
    switch activity.type {
    case .presentationAccepted: Assets.listIndicatorPresentationAccepted.swiftUIImage
    case .presentationDeclined: Assets.listIndicatorPresentationDeclined.swiftUIImage
    case .issuance: Assets.listIndicatorIssuance.swiftUIImage
    }
  }

  var title: String {
    switch activity.type {
    case .presentationAccepted: L10n.tkActivityPresentationAcceptedTitle
    case .presentationDeclined: L10n.tkActivityPresentationDeclinedTitle
    case .issuance: L10n.tkActivityCredentialAcceptedTitle
    }
  }

  var subtitle: String {
    activity.actorDisplays.findDisplayWithFallback()?.name ?? ""
  }

  var timeStamp: String {
    let date = activity.createdAt.formatted(
      .dateTime
        .locale(currentLocale)
        .year(.defaultDigits)
        .month(.twoDigits)
        .day(.twoDigits))
    let time = activity.createdAt.formatted(
      .dateTime
        .locale(currentLocale)
        .hour(.twoDigits(amPM: .abbreviated))
        .minute(.twoDigits))
    return "\(date) | \(time)"
  }

  var accessibleTimeStamp: String {
    activity.createdAt.formatted(date: .long, time: .shortened)
  }

  // MARK: Private

  private var currentLocale: Locale {
    Locale(identifier: Container.shared.preferredUserLocales().first ?? UserLocale.defaultLocaleIdentifier)
  }
}
