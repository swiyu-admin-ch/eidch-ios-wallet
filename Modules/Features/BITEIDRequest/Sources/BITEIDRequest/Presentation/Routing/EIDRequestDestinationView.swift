import BITTheming
import Factory
import Foundation
import SwiftUI

struct EIDRequestDestinationView: View {

  // MARK: Lifecycle

  init(destination: EIDRequestDestinations) {
    self.destination = destination
  }

  // MARK: Internal

  var body: some View {
    switch destination {
    case .introduction:
      IntroductionView()
    case .dataPrivacyView:
      DataPrivacyView()
    case .setupSDK:
      SetupView()
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
    case .setupSDKError(let error, let callback):
      SetupSDKErrorView(error: error, callback: callback.handler)
    case .documentSelection:
      DocumentSelectionView()
    case .mrzMockData:
      MRZMockDataView()
    case .scanDocumentInformation(let isBackEnabled):
      ScanDocumentInformationView(isBackEnabled: isBackEnabled)
    case .scanDocument:
      ScanDocumentView()
    case .scanDocumentSubmit(let output):
      ScanDocumentSubmitView(output)
    case .scanDocumentImageOverview(let image):
      ScanDocumentImageOverviewView(image: image)
    case .avIdentityCheck(let caseId):
      AVIdentityCheckView(caseId: caseId)
    case .walletPairing:
      WalletPairingView()
    case .walletPairingList(let caseId):
      WalletPairingListView(caseId: caseId)
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
    case .avIntroSelfieVideo:
      AVIntroSelfieVideoView()
    case .recordSelfie:
      RecordSelfieView()
    case .submitEidRequest:
      SubmitEIDRequestView()
    case .nfcScanResult(let packageResult):
      NFCScanResultView(packageResult: packageResult)
    case .timeout:
      TimeoutView()
    case .success(let caseId):
      SuccessView(caseId: caseId)
    case .scanDocumentSecondPageInstructions(let callback):
      ScanDocumentSecondPageView(action: callback.handler)
    case .error(let dataset):
      EIDRequestErrorView(dataset: dataset)
    case .external(let externalDestination):
      eIDRequestExternalViewProvider?.view(for: externalDestination)
    case .avWelcome(let caseId):
      AVWelcomeView(caseId: caseId)
    case .pushPermission(let requestCase):
      PushPermissionView(requestCase)
    }
  }

  // MARK: Private

  private let destination: EIDRequestDestinations

  @Injected(\.eIDRequestExternalViewProvider) private var eIDRequestExternalViewProvider

}
