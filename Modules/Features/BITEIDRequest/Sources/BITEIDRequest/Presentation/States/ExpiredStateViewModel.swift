import Factory

public class ExpiredStateViewModel: RequestCaseStateBaseViewModel {

  // MARK: Internal

  func primaryAction() async {
    do {
      try await deleteEIDRequestCaseUseCase.execute(requestCaseId)
      delegate?.didDeleteRequestCase()
    } catch {
      // Do nothing
    }
  }

  // MARK: Private

  @Injected(\.deleteEIDRequestCaseUseCase) private var deleteEIDRequestCaseUseCase: DeleteEIDRequestCaseUseCaseProtocol

}
