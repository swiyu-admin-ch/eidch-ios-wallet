// swiftlint:disable implicitly_unwrapped_optional
import Combine
import Factory
import Spyable
import XCTest
@testable import BITActivity
@testable import BITTestingCore

final class GetActivityHistoryEnabledSubjectUseCaseTests: XCTestCase {

  // MARK: Internal

  override func setUp() {
    Container.shared.reset()
    registerMocks()
    useCase = GetActivityHistoryEnabledSubjectUseCase()
    createSuccessState()
  }

  func testCallAsFunction_returnsSubject() {
    let subject = useCase()

    XCTAssertTrue(subject === subjectMock)
  }

  // MARK: Private

  private var repositorySpy: ActivityRepositoryProtocolSpy!
  private var subjectMock: CurrentValueSubject<Bool, Never>!

  private var useCase: GetActivityHistoryEnabledSubjectUseCase!

  private func registerMocks() {
    subjectMock = CurrentValueSubject(false)
    repositorySpy = ActivityRepositoryProtocolSpy()
    Container.shared.activityRepository.register { self.repositorySpy }
  }

  private func createSuccessState() {
    repositorySpy.underlyingActivityHistoryEnabledSubject = subjectMock
  }
}
