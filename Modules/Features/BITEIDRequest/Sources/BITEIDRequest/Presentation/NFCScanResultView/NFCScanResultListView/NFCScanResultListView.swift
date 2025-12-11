import SwiftUI

struct NFCScanResultListView: View {

  // MARK: Lifecycle

  init(entries: [NFCScanResultViewModel.NFCScanResultEntryType]) {
    self.entries = entries
  }

  // MARK: Internal

  var body: some View {
    ForEach(entries, id: \.self) { entry in
      NFCScanResultListViewCell(entry: entry)
        .padding(.leading, .x4)
    }
  }

  // MARK: Private

  private let entries: [NFCScanResultViewModel.NFCScanResultEntryType]

}
