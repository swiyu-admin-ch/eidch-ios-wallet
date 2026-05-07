import Foundation

enum ScanResultEntryType: Hashable {
  case text(key: String, value: String)
  case image(key: String, value: Data, accessibilityLabel: String)
}
