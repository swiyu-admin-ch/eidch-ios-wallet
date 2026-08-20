import Foundation

extension Sequence {
  public func sortedByDisplayOrder(using orderable: (Element) -> any CredentialDisplayOrderable) -> [Element] {
    map { element -> (element: Element, order: Int, createdAt: Date) in
      let orderable = orderable(element)
      let order = CredentialDisplayOrder.allCases.firstIndex(of: orderable.displayOrder)
        ?? CredentialDisplayOrder.allCases.count
      return (element, order, orderable.createdAt)
    }
    .sorted { $0.order != $1.order ? $0.order < $1.order : $0.createdAt > $1.createdAt }
    .map(\.element)
  }
}
