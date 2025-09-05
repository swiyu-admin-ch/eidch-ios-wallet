#if DEBUG
import Foundation
@testable import BITTestingCore

extension WalletPairingResponse: Mockable {
  struct Mock {
    static let sample: WalletPairingResponse = Mocker.decode(fromFile: "wallet-pairing-response", bundle: Bundle.module)
    static let sampleData: Data = Mocker.getData(fromFile: "wallet-pairing-response", bundle: Bundle.module) ?? Data()
  }
}
#endif
