import Foundation

extension String {
  func sdJWSData(with disclosures: [String], keyBindingJWT: String? = nil) -> Data {
    var string = self + "~" + disclosures.joined(separator: "~") + "~"
    if let keyBindingJWT {
      string.append(keyBindingJWT)
    }
    return Data(string.utf8)
  }
}
