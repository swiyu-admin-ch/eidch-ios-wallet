import Foundation

// MARK: - PackageDependency

public struct PackageDependency: Codable, Identifiable, Equatable, Hashable {
  public var id: UUID {
    UUID()
  }

  let name: String
  let version: String?
  let license: String?
}

// MARK: PackageDependency.Mock

extension PackageDependency {
  public struct Mock {
    public static let sample = PackageDependency(name: "Test package", version: "1.3.4", license: "MIT")
  }
}
