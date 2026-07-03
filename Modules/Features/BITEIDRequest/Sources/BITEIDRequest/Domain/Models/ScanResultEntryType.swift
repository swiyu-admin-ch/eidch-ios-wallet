enum ScanResultEntryType: Hashable {
  case text(key: String, value: String)
  case image(ScanResultEntryImage)
}
