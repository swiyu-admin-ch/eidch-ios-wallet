import BITAnalytics
import BITCore
import Factory
import Foundation

@MainActor
@Observable
public class LicencesListViewModel {

  // MARK: Lifecycle

  public init(
    _ initialState: State = .loading,
    fetchPackagesUseCase: FetchPackagesUseCaseProtocol = Container.shared.fetchPackagesUseCase(),
    analytics: AnalyticsProtocol = Container.shared.analytics())
  {
    state = initialState
    self.fetchPackagesUseCase = fetchPackagesUseCase
    self.analytics = analytics
  }

  // MARK: Public

  public enum State: Equatable {
    case loading
    case results
    case empty
    case error
  }

  public enum Event {
    case fetch
    case setPackages(_ packages: [PackageDependency])
    case setError(_ errror: Error)
  }

  public func send(event: Event) async {
    switch (state, event) {
    case (_, .fetch):
      do {
        let packages = try fetchPackagesUseCase.execute()
        await send(event: .setPackages(packages))
      } catch {
        await send(event: .setError(error))
      }

    case (.loading, .setPackages(let packages)):
      self.packages = packages
      state = self.packages.isEmpty ? .empty : .results

    case (_, .setError(let error)):
      analytics.log(error)
      stateError = error
      state = .error

    case (.error, _):
      packages = []

    default:
      return
    }
  }

  // MARK: Internal

  var packages = [PackageDependency]()
  var stateError: Error?
  private(set) var state: State

  // MARK: Private

  private let analytics: AnalyticsProtocol
  private let fetchPackagesUseCase: FetchPackagesUseCaseProtocol

}
