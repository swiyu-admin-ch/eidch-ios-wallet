import BITEntities

public struct BatchData: Codable, Equatable, Hashable {

  // MARK: Lifecycle

  public init(batchSize: Int) {
    self.batchSize = batchSize
  }

  init(_ entity: BatchDataEntity) {
    self.init(batchSize: entity.batchSize)
  }

  // MARK: Public

  public let batchSize: Int
}
