import BITEntities

extension BatchDataEntity {

  // MARK: Lifecycle

  public convenience init(_ batchData: BatchData) {
    self.init()
    setValues(from: batchData)
  }

  // MARK: Internal

  func setValues(from batchData: BatchData) {
    batchSize = batchData.batchSize
  }
}
