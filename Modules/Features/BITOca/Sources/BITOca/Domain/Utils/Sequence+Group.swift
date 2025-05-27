import Foundation

extension Sequence {

  func compactGroup<K: Hashable, V>(keySelector: (Iterator.Element) -> K?, valueTransform: (Iterator.Element) -> V?) -> [K: V] {
    let pairs: [(K, V)] = compactMap { element in
      guard
        let key = keySelector(element),
        let value = valueTransform(element)
      else { return nil }
      return (key, value)
    }
    return Dictionary(uniqueKeysWithValues: pairs)
  }

  func compactGroupWith<V>(valueTransform: (Iterator.Element) -> V?) -> [Iterator.Element: V] {
    let pairs: [(Iterator.Element, V)] = compactMap { element in
      guard let value = valueTransform(element) else { return nil }
      return (element, value)
    }
    return Dictionary(uniqueKeysWithValues: pairs)
  }
}
