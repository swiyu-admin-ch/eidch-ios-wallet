import Foundation
import Spyable

@Spyable
protocol LocalEIDRequestRepositoryProtocol {
  func create(eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase
  func get(id: String) async throws -> EIDRequestCase
  func getAll() async throws -> [EIDRequestCase]
  func update(_ eIDRequestCase: EIDRequestCase) async throws -> EIDRequestCase
  func delete(_ eIDRequestCase: EIDRequestCase) async throws
}
