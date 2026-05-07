import BITAVWrapper
import BITL10n
import BITNavigation
import Factory
import Foundation

@Observable
class NFCScanResultViewModel {

  // MARK: Lifecycle

  init(package: AVBeamPackageResult) {
    self.package = package
  }

  // MARK: Internal

  enum State {
    case loading
    case results([ScanResultEntryType])
    case error(Error)
  }

  var state = State.loading
  var destination: EIDRequestDestinations?

  func primaryAction() {
    destination = getNextDestination()
  }

  @MainActor
  func fetchScanResult() async {
    do {
      guard let caseId = context.caseId else {
        throw EIDRequestError.missingCaseId
      }

      let result = try fetchNFCScanResultUseCase.execute(for: caseId, packageResult: package)

      let entries: [ScanResultEntryType] = [
        .image(key: L10n.tkEidRequestNfcScanResultPhotoKey, value: result.facePicture, accessibilityLabel: L10n.tkEidRequestNfcScanResultPhotoAlt),
        .text(key: L10n.tkEidRequestNfcScanResultSurnameKey, value: result.surname),
        .text(key: L10n.tkEidRequestNfcScanResultGivenNamesKey, value: result.givenName),
        .text(key: L10n.tkEidRequestNfcScanResultExpirationDateKey, value: result.expirationDate),
        .text(key: L10n.tkEidRequestNfcScanResultPassportNumberKey, value: result.passportNumber),
      ]

      state = .results(entries)
    } catch {
      state = .error(error)
    }
  }

  // MARK: Private

  private let package: AVBeamPackageResult

  @ObservationIgnored @Injected(\.eidRequestContext) private var context
  @ObservationIgnored @Injected(\.fetchNFCScanResultUseCase) private var fetchNFCScanResultUseCase: FetchNFCScanResultUseCaseProtocol

  private func getNextDestination() -> EIDRequestDestinations {
    if context.autoVerificationResponse?.isDocumentVideoRecordingRequired == true {
      return .recordDocumentInformation
    }

    return .avIntroSelfieVideo
  }
}
