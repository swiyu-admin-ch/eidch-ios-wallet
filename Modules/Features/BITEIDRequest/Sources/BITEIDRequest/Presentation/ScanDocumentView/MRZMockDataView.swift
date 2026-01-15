import BITAVWrapper
import BITTheming
import Foundation
import NavigatorUI
import SwiftUI

struct MRZMockDataView: View {

  // MARK: Internal

  var body: some View {
    List {
      ForEach(MRZData.Mock.array) { mrzData in
        DocumentSelectionCell(image: Image(systemName: "person.text.rectangle"), name: mrzData.displayName) {
          guard let mrz = try? MRZ(values: mrzData.payload.mrz) else { return }

          let output = ScanDocumentOutput(mrz: mrz, identityType: mrzData.identityType ?? .identityCard)
          navigator.push(EIDRequestDestinations.scanDocumentSubmit(output))
        }
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.grouped)
    .defaultEidRequestToolbar()
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

}
