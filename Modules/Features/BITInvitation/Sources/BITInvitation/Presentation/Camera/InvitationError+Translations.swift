import BITL10n
import Foundation
import SwiftUI

extension InvitationError {

  var icon: Image {
    switch self {
    case .noConnection: Assets.noWifi.swiftUIImage
    case .expiredInvitation,
         .validationFailed: Assets.credential.swiftUIImage
    case .invalidPresentationRequest,
         .unknownIssuer: Assets.questionmarkSquare.swiftUIImage
    case .invalidQRCode: Assets.qrcode.swiftUIImage
    }
  }

  var primaryText: String {
    switch self {
    case .noConnection: L10n.tkErrorConnectionproblemTitle
    case .expiredInvitation: L10n.tkErrorNotusableTitle
    case .unknownIssuer: L10n.tkErrorNotregisteredTitle
    case .validationFailed: L10n.tkErrorInvitationcredentialTitle
    case .invalidQRCode: L10n.tkErrorInvitationcredentialTitle
    case .invalidPresentationRequest: L10n.tkErrorInvalidrequestTitle
    }
  }

  var secondaryText: String {
    switch self {
    case .noConnection: L10n.tkErrorConnectionproblemBody
    case .expiredInvitation: L10n.tkErrorNotusableBody
    case .unknownIssuer: L10n.tkErrorNotregisteredBody
    case .validationFailed: L10n.tkErrorInvitationcredentialBody
    case .invalidQRCode: L10n.tkErrorInvitationcredentialBody
    case .invalidPresentationRequest: L10n.tkErrorInvalidrequestBody
    }
  }
}
