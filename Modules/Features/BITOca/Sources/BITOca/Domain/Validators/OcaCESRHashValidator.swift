import BITCrypto
import BITJsonCanonicalizer
import CryptoKit
import Factory
import Foundation
import Spyable

// MARK: - OcaCESRHashValidatorProtocol

@Spyable
public protocol OcaCESRHashValidatorProtocol {
  func validate(data: Data) -> Bool
  func validate(jsonString: String) -> Bool
}

// MARK: - OcaCESRHashValidator

/// OCA CESR Hash Validator
/// Following Draft 0.2 specification: https://github.com/e-id-admin/open-source-community/blob/main/tech-roadmap/rfcs/oca/spec.md#generate-cesr-encoding-flow-with-sha-256
public struct OcaCESRHashValidator: OcaCESRHashValidatorProtocol {

  // MARK: Public

  public func validate(jsonString: String) -> Bool {
    guard let jsonData = jsonString.data(using: .utf8) else {
      return false
    }
    return validate(data: jsonData)
  }

  public func validate(data: Data) -> Bool {
    do {
      let (originalOCAJson, originalDigest, digestAlgorithm) = try parseAndValidateOCA(from: data)
      let dummyDigestJSON = try createDummyDigestJSON(from: originalOCAJson, using: digestAlgorithm)
      let canonicalJsonBytes = try jsonCanonicalizer.canonicalize(jsonString: dummyDigestJSON)
      let rawDigest = digestAlgorithm.calculateDigest(for: canonicalJsonBytes)
      let computedDigest = formatDigest(rawDigest: rawDigest, algorithm: digestAlgorithm)

      return originalDigest == computedDigest
    } catch {
      return false
    }
  }

  // MARK: Private

  private let digestKey = "digest"
  @Injected(\.jsonCanonicalizer) private var jsonCanonicalizer: JsonCanonicalizerProtocol

  private func parseAndValidateOCA(from data: Data) throws -> ([String: Any], String, DigestAlgorithm) {
    guard let originalOCAJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      throw CESRHashValidatorError.jsonParsingError("Failed to parse into JSON object")
    }

    guard let originalDigest = originalOCAJson[digestKey] as? String else {
      throw CESRHashValidatorError.invalidOCAObject
    }

    guard !originalDigest.isEmpty else {
      throw CESRHashValidatorError.emptyOCADigest
    }

    guard
      let digestAlgorithmPrefix = originalDigest.first.map(String.init),
      let digestAlgorithm = DigestAlgorithm.fromPrefix(digestAlgorithmPrefix) else
    {
      throw CESRHashValidatorError.unsupportedDigestAlgorithm
    }

    return (originalOCAJson, originalDigest, digestAlgorithm)
  }

  private func createDummyDigestJSON(from originalJSON: [String: Any], using algorithm: DigestAlgorithm) throws -> String {
    var dummyDigestOCAJson = originalJSON
    dummyDigestOCAJson[digestKey] = algorithm.dummyDigest

    guard
      let dummyDigestOCAJsonData = try? JSONSerialization.data(withJSONObject: dummyDigestOCAJson),
      let dummyDigestOCAJsonString = String(data: dummyDigestOCAJsonData, encoding: .utf8) else
    {
      throw CESRHashValidatorError.jsonParsingError("Failed to create dummy digest JSON string")
    }

    return dummyDigestOCAJsonString
  }

  private func formatDigest(rawDigest: Data, algorithm: DigestAlgorithm) -> String {
    let rawDigestWithPadding = algorithm.paddingData + rawDigest

    var base64EncodedDigest = rawDigestWithPadding.base64URLEncodedString()
    if !base64EncodedDigest.isEmpty {
      base64EncodedDigest.removeFirst()
    }

    return "\(algorithm.prefix)\(base64EncodedDigest)"
  }
}

// MARK: OcaCESRHashValidator.DigestAlgorithm

extension OcaCESRHashValidator {
  private enum DigestAlgorithm: String {
    case sha256

    // MARK: Internal

    var prefix: String {
      switch self {
      case .sha256: "I"
      }
    }

    var dummyDigest: String {
      switch self {
      case .sha256:
        String(repeating: "#", count: 44)
      }
    }

    var paddingData: Data {
      switch self {
      case .sha256:
        Data([0x00])
      }
    }

    static func fromPrefix(_ prefix: String) -> DigestAlgorithm? {
      switch prefix {
      case "I": .sha256
      default: nil
      }
    }

    func calculateDigest(for data: Data) -> Data {
      switch self {
      case .sha256:
        SHA256Hasher().hash(data)
      }
    }
  }
}

// MARK: - CESRHashValidatorError

public enum CESRHashValidatorError: Error {
  case jsonParsingError(String)
  case invalidOCAObject
  case emptyOCADigest
  case unsupportedDigestAlgorithm
}
