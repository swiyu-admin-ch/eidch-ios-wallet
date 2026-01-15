import BITAVWrapper
import BITEIDRequestShared
import BITL10n
import BITTheming
import Foundation
import NavigatorUI
import SwiftUI


enum EIDRequestDestinations: NavigationDestination {
  case introduction
  case dataPrivacyView

  case attestation

  case legalRepresentant
  case legalRepresentantConsent(caseId: String)
  case legalRepresentantQRCode(caseId: String)
  case legalRepresentantVerification(caseId: String)
  case legalRepresentantConsentState(state: RequestCaseViewState)
  case queueInformation(_ onlineSessionStateDate: Date)

  case validateAttestationError(error: ErrorWrapper, Callback<Void>)

  case error(ErrorDataset)

  case documentSelection
  case mrzMockData

  // Document scan
  case scanDocumentInformation
  case scanDocument
  case scanDocumentSubmit(_ output: ScanDocumentOutput)

  // Wallet pairing
  case walletPairing
  case walletPairingList
  case walletPairingOffer(_ completionHandler: Callback<Void>)
  case walletPairingOfferRejected(_ onRetry: Callback<Void>)

  case avIdentityCheck

  // NFC
  case nfcScan
  case nfcScanResult(_ packageResult: AVBeamPackageResult)
  case nfcHelp
  case nfcHelpFailure

  case recordDocumentInformation
  case recordDocument

  // Selfie
  case avIntroSelfieVideo
  case recordSelfie

  case submitEidRequest
  case timeout

  case success

  // MARK: Internal

  var method: NavigationMethod {
    switch self {
    case .nfcHelp,
         .walletPairingOffer:
      .managedSheet
    default:
      .push
    }
  }

  var body: some View {
    switch self {
    case .introduction:
      IntroductionView()
    case .dataPrivacyView:
      DataPrivacyView()
    case .attestation:
      ValidateAttestationsView()
    case .legalRepresentant:
      LegalRepresentantView()
    case .legalRepresentantConsent(let caseId):
      LegalRepresentantConsentView(caseId: caseId)
    case .legalRepresentantQRCode(let caseId):
      LegalRepresentantQRCodeView(caseId: caseId)
    case .legalRepresentantVerification(let caseId):
      LegalRepresentantVerificationView(caseId: caseId)
    case .legalRepresentantConsentState(let state):
      LegalRepresentantConsentStateView(state: state)
    case .queueInformation(let date):
      QueueInformationView(onlineSessionStartDate: date)
    case .validateAttestationError(let error, let callback):
      ValidateAttestationsErrorView(error: error, callback: callback.handler)
    case .documentSelection:
      DocumentSelectionView()
    case .mrzMockData:
      MRZMockDataView()
    case .scanDocumentInformation:
      ScanDocumentInformationView()
    case .scanDocument:
      ScanDocumentView()
    case .scanDocumentSubmit(let output):
      ScanDocumentSubmitView(output)
    case .avIdentityCheck:
      AVIdentityCheckView()
    case .walletPairing:
      WalletPairingView()
    case .walletPairingList:
      WalletPairingListView()
    case .walletPairingOffer(let completionCallback):
      WalletPairingOfferView(completionCallback.handler)
        .navigationDestination(EIDRequestDestinations.self)
    case .walletPairingOfferRejected(let onRetry):
      WalletPairingOfferRejected(onRetry: onRetry.handler)
    case .nfcScan:
      NFCScanView()
    case .recordDocumentInformation:
      RecordDocumentInformationView()
    case .recordDocument:
      RecordDocumentView()
    case .nfcHelp:
      NFCHelpView()
    case .nfcHelpFailure:
      NFCHelpFailureView()
    case .avIntroSelfieVideo:
      AVIntroSelfieVideoView()
    case .recordSelfie:
      RecordSelfieView()
    case .submitEidRequest:

      DebugSubmitEIDRequestView()
    case .nfcScanResult(let packageResult):
      NFCScanResultView(packageResult: packageResult)
    case .timeout:
      TimeoutView()
    case .success:
      SuccessView()
    case .error(let dataset):
      ErrorView(dataset: dataset)
    }
  }

}

// MARK: - ErrorWrapper

struct ErrorWrapper: Hashable {

  // MARK: Lifecycle

  init(_ error: Error) {
    self.error = error
  }

  // MARK: Internal

  let error: Error

  static func == (lhs: ErrorWrapper, rhs: ErrorWrapper) -> Bool {
    type(of: lhs.error) == type(of: rhs.error) &&
      lhs.error.localizedDescription == rhs.error.localizedDescription
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(String(describing: type(of: error)))
    hasher.combine(error.localizedDescription)
  }

}
