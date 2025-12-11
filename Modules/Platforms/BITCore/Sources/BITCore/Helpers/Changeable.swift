import Foundation

// MARK: - Changeable

public protocol Changeable {}

extension Changeable {
  public func changing<T>(_ path: WritableKeyPath<Self, T>, to value: T) -> Self {
    var clone = self
    clone[keyPath: path] = value
    return clone
  }
}
