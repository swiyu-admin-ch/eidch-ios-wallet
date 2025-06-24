import BITOca
import Foundation

// MARK: - MockOCARepository

struct MockOCARepository: OCARepositoryProtocol {
  func fetchOCABundle(from url: URL) async throws -> RawOcaBundle {
    RawOcaBundle.Mock.sampleData
  }
}

// MARK: - RawOcaBundle.Mock

extension RawOcaBundle {
  struct Mock {
    static let sampleData: Data = Mocker.getData(fromFile: "oca-bundle-ui-mocks") ?? Data()
  }
}
