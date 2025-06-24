import Foundation

public struct NetworkResponse<T> {

  public init(object: T, data: Data) {
    self.object = object
    self.data = data
  }

  public let object: T
  public let data: Data
}
