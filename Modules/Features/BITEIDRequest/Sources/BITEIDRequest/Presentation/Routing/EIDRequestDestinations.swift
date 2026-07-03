import BITAVWrapper
import BITEIDRequestShared
import BITL10n
import BITTheming
import Foundation
import NavigatorUI
import SwiftUI


public enum EIDRequestDestinations: NavigationDestination {
  case introduction
  case dataPrivacyView

  case setupSDK

  case legalRepresentant
  case legalRepresentantConsent(caseId: String)
  case legalRepresentantQRCode(caseId: String)
  case legalRepresentantVerification(caseId: String)
  case legalRepresentantConsentState(state: RequestCaseViewState)
  case queueInformation(_ onlineSessionStateDate: Date)

  case setupSDKError(error: ErrorWrapper, Callback<Void>)

  case error(ErrorDataset)

  case documentSelection
  case mrzMockData

  // Document scan
  case scanDocumentInformation(isBackEnabled: Bool)
  case scanDocument
  case scanDocumentSubmit(_ output: ScanDocumentOutput)
  case scanDocumentSecondPageInstructions(_ callback: Callback<Void>)
  case scanDocumentImageOverview(image: ScanResultEntryImage)

  // Wallet pairing
  case walletPairing
  case walletPairingList(caseId: String)
  case walletPairingOffer(_ completionHandler: Callback<Void>)
  case walletPairingOfferRejected(_ onRetry: Callback<Void>)

  case avIdentityCheck(caseId: String)

  // NFC
  case nfcScan
  case nfcScanResult(_ packageResult: AVBeamPackageResult)

  case recordDocumentInformation
  case recordDocument

  // Selfie
  case avIntroSelfieVideo
  case recordSelfie

  case submitEidRequest
  case timeout

  case success(caseId: String)

  case avWelcome(caseId: String)

  case external(EIDRequestExternalDestination)

  /// Push
  case pushPermission(EIDRequestCase)

  // MARK: Public

  public var method: NavigationMethod {
    switch self {
    case .scanDocumentImageOverview,
         .walletPairingOffer:
      .managedSheet
    case .scanDocumentSecondPageInstructions:
      .managedCover
    default:
      .push
    }
  }

  public var body: some View {
    EIDRequestDestinationView(destination: self)
  }
}

// MARK: - ErrorWrapper

public struct ErrorWrapper: Hashable {

  // MARK: Lifecycle

  public init(_ error: Error) {
    self.error = error
  }

  // MARK: Public

  public let error: Error

  public static func == (lhs: ErrorWrapper, rhs: ErrorWrapper) -> Bool {
    type(of: lhs.error) == type(of: rhs.error)
      && lhs.error.localizedDescription == rhs.error.localizedDescription
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(String(describing: type(of: error)))
    hasher.combine(error.localizedDescription)
  }
}
