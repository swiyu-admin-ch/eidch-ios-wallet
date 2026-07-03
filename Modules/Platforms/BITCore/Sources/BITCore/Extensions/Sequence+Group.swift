import Foundation

extension Sequence {

  public func compactGroup<K: Hashable, V>(keySelector: (Iterator.Element) -> K?, valueTransform: (Iterator.Element) -> V?) -> [K: V] {
    let pairs: [(K, V)] = compactMap { element in
      guard
        let key = keySelector(element),
        let value = valueTransform(element)
      else { return nil }
      return (key, value)
    }
    return Dictionary(uniqueKeysWithValues: pairs)
  }

  public func compactGroup<K: Hashable, V>(keySelector: (Iterator.Element) throws -> K?, valueTransform: (Iterator.Element) throws -> V?, uniquingKeysWith: (V, V) throws -> V) throws -> [K: V] {
    let pairs: [(K, V)] = try compactMap { element in
      guard
        let key = try keySelector(element),
        let value = try valueTransform(element)
      else { return nil }
      return (key, value)
    }
    return try Dictionary(pairs, uniquingKeysWith: uniquingKeysWith)
  }

  public func compactGroupWith<V>(valueTransform: (Iterator.Element) -> V?) -> [Iterator.Element: V] {
    let pairs: [(Iterator.Element, V)] = compactMap { element in
      guard let value = valueTransform(element) else { return nil }
      return (element, value)
    }
    return Dictionary(uniqueKeysWithValues: pairs)
  }

  public func compactGroupBy<K>(keySelector: (Iterator.Element) throws -> K?) throws -> [K: Iterator.Element] {
    let pairs: [(K, Iterator.Element)] = try compactMap { element in
      guard let key = try keySelector(element) else { return nil }
      return (key, element)
    }
    return Dictionary(uniqueKeysWithValues: pairs)
  }
}
