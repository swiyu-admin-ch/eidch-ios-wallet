import Foundation

extension Collection where Element: Sendable {

  // MARK: Public

  public func concurrentMapLimited<T: Sendable>(
    maxConcurrentTasks: Int,
    _ transform: @escaping @Sendable (Element) async throws -> T) async
    -> [Result<T, Error>]
  {
    precondition(maxConcurrentTasks > 0)
    guard !isEmpty else { return [] }
    let elements = Array(self)
    return await withTaskGroup(
      of: (Int, Result<T, Error>).self,
      returning: [Result<T, Error>].self)
    { group in
      var iterator = elements.enumerated().makeIterator()
      var results = [Result<T, Error>?](repeating: nil, count: elements.count)
      for _ in 0..<Swift.min(maxConcurrentTasks, elements.count) {
        addNextTask(to: &group, iterator: &iterator, transform: transform)
      }
      while let (index, result) = await group.next() {
        results[index] = result
        addNextTask(to: &group, iterator: &iterator, transform: transform)
      }
      let returnResults = results.compactMap(\.self)
      assert(returnResults.count == elements.count)
      return returnResults
    }
  }

  // MARK: Private

  private func addNextTask<T: Sendable, I: IteratorProtocol>(
    to group: inout TaskGroup<(Int, Result<T, Error>)>,
    iterator: inout I,
    transform: @escaping @Sendable (Element) async throws -> T)
    where I.Element == (offset: Int, element: Element)
  {
    guard let (index, element) = iterator.next() else {
      return
    }
    group.addTask {
      do {
        try Task.checkCancellation()
        return try (index, .success(await transform(element)))
      } catch {
        return (index, .failure(error))
      }
    }
  }
}
