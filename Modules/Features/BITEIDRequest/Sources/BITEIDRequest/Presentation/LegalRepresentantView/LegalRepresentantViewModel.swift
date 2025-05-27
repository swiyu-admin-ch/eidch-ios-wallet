import Factory

@MainActor
class LegalRepresentantViewModel {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  func yesAction() {
    legalRepresentantRepository.set(true)
    router.checkCardIntroduction()
  }

  func noAction() {
    legalRepresentantRepository.set(false)
    router.checkCardIntroduction()
  }

  func close() {
    router.close()
  }

  // MARK: Private

  private let router: EIDRequestInternalRoutes
  // swiftlint:disable viewmodels_must_not_reference_repository
  @Injected(\.legalRepresentantRepository) private var legalRepresentantRepository: LegalRepresentantRepositoryProcotol
  // swiftlint:enable viewmodels_must_not_reference_repository
}
