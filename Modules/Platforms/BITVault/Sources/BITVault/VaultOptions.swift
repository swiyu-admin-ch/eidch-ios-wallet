import Foundation

// MARK: - VaultOptions

public struct VaultOptions: OptionSet {

  public init(rawValue: UInt8) {
    self.rawValue = rawValue
  }

  public let rawValue: UInt8

  public static let secureEnclave = VaultOptions(rawValue: 1 << 0)
  public static let savePermanently = VaultOptions(rawValue: 1 << 1)

  public static let secureEnclavePermanently: VaultOptions = [.secureEnclave, .savePermanently]
  public static let none: VaultOptions = []
}

extension VaultOptions {
  public var secAccessControl: SecAccessControlCreateFlags {
    switch self {
    case .secureEnclave,
         .secureEnclavePermanently: [.privateKeyUsage]
    default: []
    }
  }
}
