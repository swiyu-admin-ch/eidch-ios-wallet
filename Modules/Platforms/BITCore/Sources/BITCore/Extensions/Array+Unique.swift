import Foundation

extension Array where Element: Hashable {
  public func uniqued() -> [Element] {
    var uniques = Set<Element>()
    return filter { uniques.insert($0).inserted }
  }
}
