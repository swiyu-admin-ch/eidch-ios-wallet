import Factory
import Foundation

@MainActor
class LegalRepresentantQRCodeViewModel: ObservableObject {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes, caseId: String) {
    self.router = router
    self.caseId = caseId
  }

  // MARK: Internal

  enum QRCodeViewState: Equatable {
    case loading
    case error
    case result(Data, URL)
  }

  @Published var state = QRCodeViewState.loading

  var isShareQRCodeDisabled: Bool {
    state == .loading || state == .error
  }

  func finish() {
  }

  func getVerificationQRCode() async {
    state = .loading

    do {
      let verificationQRCode = try await getLegalRepresentantVerificationQRCodeUseCase.execute(for: caseId)
      state = .result(verificationQRCode.imageData, verificationQRCode.shareLink)
    } catch {
      state = .error
    }
  }

  // MARK: Private

  private let caseId: String
  private let router: EIDRequestInternalRoutes

  @Injected(\.getLegalRepresentantVerificationQRCodeUseCase) private var getLegalRepresentantVerificationQRCodeUseCase: GetLegalRepresentantVerificationQRCodeUseCaseProtocol
}
