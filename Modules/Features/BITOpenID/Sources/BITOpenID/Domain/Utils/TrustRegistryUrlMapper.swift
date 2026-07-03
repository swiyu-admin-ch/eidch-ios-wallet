import BITJWT
import Factory
import Foundation
import RegexBuilder
import Spyable

// MARK: - TrustRegistryUrlMapperProtocol

@Spyable
public protocol TrustRegistryUrlMapperProtocol {
  func map(did: String) throws -> URL
}

// MARK: - TrustRegistryUrlMapperError

public enum TrustRegistryUrlMapperError: Error {
  case cannotParseTrustRegistryDomain
}

// MARK: - TrustRegistryUrlMapper

struct TrustRegistryUrlMapper: TrustRegistryUrlMapperProtocol {

  // MARK: Internal

  func map(did: String) throws -> URL {
    guard
      let baseRegistryDomain = try getBaseRegistryDomain(from: did),
      let trustRegistryDomain = trustRegistryMapping[baseRegistryDomain],
      let trustRegistryURL = URL(string: "https://\(trustRegistryDomain)")
    else {
      throw TrustRegistryUrlMapperError.cannotParseTrustRegistryDomain
    }
    return trustRegistryURL
  }

  // MARK: Private

  @Injected(\.trustRegistryMapping) private var trustRegistryMapping: [String: String]
  @Injected(\.didResolverHelper) private var didResolverHelper: DidResolverHelperProtocol

  private func getBaseRegistryDomain(from did: String) throws -> String? {
    let url = try didResolverHelper.getURL(from: did)
    return url.host()
  }
}
