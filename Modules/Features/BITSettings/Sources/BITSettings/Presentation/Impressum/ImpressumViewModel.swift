import BITAppInfo
import Factory
import Foundation

class ImpressumViewModel: ObservableObject {

  // MARK: Lifecycle

  init(
    getAppVersionUseCase: GetAppVersionUseCaseProtocol = Container.shared.getAppVersionUseCase(),
    getBuildNumberUseCase: GetBuildNumberUseCaseProtocol = Container.shared.getBuildNumberUseCase())
  {
    self.getAppVersionUseCase = getAppVersionUseCase
    self.getBuildNumberUseCase = getBuildNumberUseCase

    do { appVersion = try getAppVersionUseCase.execute().rawValue } catch { appVersion = "0.0.0" }
    do { buildNumber = try String(getBuildNumberUseCase.execute()) } catch { buildNumber = "0" }
  }

  // MARK: Internal

  let appVersion: String
  let buildNumber: String

  // MARK: Private

  private var getAppVersionUseCase: GetAppVersionUseCaseProtocol
  private var getBuildNumberUseCase: GetBuildNumberUseCaseProtocol

}
