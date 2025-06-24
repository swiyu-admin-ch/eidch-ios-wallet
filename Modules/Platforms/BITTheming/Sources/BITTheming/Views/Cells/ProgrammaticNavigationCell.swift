import SwiftUI

// MARK: - ProgrammaticNavigationCell

public struct ProgrammaticNavigationCell<Cell: View>: View {

  // MARK: Lifecycle

  public init(didSelect: @escaping () -> Void, @ViewBuilder cell: @escaping () -> Cell) {
    self.didSelect = didSelect
    self.cell = cell
  }

  // MARK: Public

  public var body: some View {
    Button(action: didSelect, label: {
      HStack {
        cell()
        Spacer()
        NavigationLink.empty
          .layoutPriority(-1)
      }
      .contentShape(Rectangle())
    })
    .buttonStyle(.plain)
    .tint(colorScheme == .dark ? .white : .black)
  }

  // MARK: Internal

  @Environment(\.colorScheme) var colorScheme

  // MARK: Private

  private let didSelect: () -> Void
  private let cell: () -> Cell

}
