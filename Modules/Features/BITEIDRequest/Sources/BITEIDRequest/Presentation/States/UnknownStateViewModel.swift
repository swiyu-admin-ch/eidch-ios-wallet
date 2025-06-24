import Factory

public class UnknownStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Internal

  func primaryAction() async {
    do {
      try await updateEIDRequestCaseStatusUseCase.execute(for: requestCaseId)
      delegate?.didUpdateRequestCaseState()
    } catch {
      // Do nothing
    }
  }

  // MARK: Private

  @Injected(\.updateEIDRequestCaseStatusUseCase) private var updateEIDRequestCaseStatusUseCase: UpdateEIDRequestCaseStatusUseCaseProtocol

}
