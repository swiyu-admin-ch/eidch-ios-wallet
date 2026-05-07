extension Array {

  public func reorder<T: Equatable>(by preferredOrder: [T], using: (Element) -> T) -> [Element] {
    reorder(by: preferredOrder, using: using, thenCompare: nil)
  }

  public func reorder<T: Equatable>(by preferredOrder: [T], using: (Element) -> T, thenCompare: ((Element, Element) -> Bool)?) -> [Element] {
    sorted {
      guard let first = preferredOrder.firstIndex(of: using($0)) else {
        return false
      }

      guard let second = preferredOrder.firstIndex(of: using($1)) else {
        return true
      }

      if first == second, let thenCompare {
        return thenCompare($0, $1)
      }

      return first < second
    }
  }
}
