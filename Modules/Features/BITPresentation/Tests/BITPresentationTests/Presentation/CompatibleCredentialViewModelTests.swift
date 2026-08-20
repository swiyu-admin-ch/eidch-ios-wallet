import Factory
import FactoryTesting
import Foundation
import Testing
@testable import BITCredential
@testable import BITCredentialShared
@testable import BITOpenID
@testable import BITPresentation

@MainActor
@Suite(.container)
struct CompatibleCredentialViewModelTests {

  // MARK: Internal

  @Test
  func verifierDisplay_oneLanguage_returnsDisplayInLanguage() throws {
    Container.shared.preferredUserLanguageCodes.register { ["en"] }

    let viewModel = CompatibleCredentialViewModel(context: contextMock)

    #expect(viewModel.verifierDisplay.name == "entityName en-US")
    #expect(try String(data: #require(viewModel.verifierDisplay.logo), encoding: .utf8) == "EN_logoUri")
    #expect(viewModel.verifierDisplay.trustInformation == contextMock.trustInformation)
  }

  @Test
  func didSelect_navigatesAndSelectsCredential() {
    let selectedCredential = CompatibleCredential.Mock.diploma
    let context = PresentationRequestContext(requestObjectJWS: .Mock.sample, compatibleCredentials: [.Mock.BIT, selectedCredential], trustInformation: .Mock.trustedIdentity)
    #expect(context.selectedCredential == nil)
    let viewModel = CompatibleCredentialViewModel(context: context)

    viewModel.didSelect(credential: selectedCredential.credential)

    #expect(context.selectedCredential == selectedCredential)
    guard case .requestReview(let destinationContext) = viewModel.destination else {
      Issue.record("Expected request review destination")
      return
    }
    #expect(destinationContext == context)
  }

  // MARK: Private

  private let contextMock = PresentationRequestContext.Mock.vcSdJwtSample
}
