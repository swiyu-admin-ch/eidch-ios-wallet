public protocol ProviderRegisterable: Sendable {
  var providers: [AnalyticsProviderProtocol] { get }
  func register(_ provider: any AnalyticsProviderProtocol)
}
