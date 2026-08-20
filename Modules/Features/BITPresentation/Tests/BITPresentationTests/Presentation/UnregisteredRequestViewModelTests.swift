import Testing
@testable import BITOpenID
@testable import BITPresentation

// MARK: - UnregisteredRequestViewModelTests

@MainActor
struct UnregisteredRequestViewModelTests {

  @Test
  func proceed_noCompatibleCredential_navigatesToNoCompatibleCredential() {
    let context = PresentationRequestContext(requestObjectJWS: .Mock.sampleWithoutVerifiedQuery, compatibleCredentials: [])
    let viewModel = UnregisteredRequestViewModel(context: context)

    viewModel.proceed()

    guard case .noCompatibleCredential(let destinationContext) = viewModel.destination else {
      #expect(false)
      return
    }
    #expect(destinationContext == context)
  }

  @Test
  func proceed_singleCompatibleCredential_navigatesToRequestReview() {
    let context = PresentationRequestContext(requestObjectJWS: .Mock.sample, compatibleCredentials: [.Mock.BIT])
    let viewModel = UnregisteredRequestViewModel(context: context)

    viewModel.proceed()

    guard case .requestReview(let destinationContext) = viewModel.destination else {
      #expect(false)
      return
    }
    #expect(destinationContext == context)
  }

  @Test
  func proceed_multipleCompatibleCredentials_navigatesToCompatibleCredentials() {
    let context = PresentationRequestContext(requestObjectJWS: .Mock.sample, compatibleCredentials: [.Mock.BIT, .Mock.diploma])
    let viewModel = UnregisteredRequestViewModel(context: context)

    viewModel.proceed()

    guard case .compatibleCredentials(let destinationContext) = viewModel.destination else {
      #expect(false)
      return
    }
    #expect(destinationContext == context)
  }
}
