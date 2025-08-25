import BITAVWrapper
import BITTheming
import Foundation
import SwiftUI

struct MRZMockDataView: View {

  // MARK: Lifecycle

  init(router: EIDRequestInternalRoutes) {
    self.router = router
  }

  // MARK: Internal

  var body: some View {
    List {
      ForEach(MRZData.Mock.array) { mrzData in
        DocumentSelectionCell(image: Image(systemName: "person.text.rectangle"), name: mrzData.displayName) {
          guard let mrz = try? MRZ(values: mrzData.payload.mrz) else { return }

          let output = ScanDocumentOutput(mrz: mrz, identityType: mrzData.identityType ?? .identityCard)
          router.scanDocumentSubmit(output)
        }
      }
    }
    .scrollContentBackground(.hidden)
    .listStyle(.grouped)
    .toolbar { CloseButtonToolbar(action: router.close) }
  }

  // MARK: Private

  private var router: EIDRequestInternalRoutes

}
