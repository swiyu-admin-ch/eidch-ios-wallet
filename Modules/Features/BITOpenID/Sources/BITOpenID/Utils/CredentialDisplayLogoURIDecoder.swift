import BITCore
import Foundation
import Spyable

// MARK: - CredentialDisplayLogoURIDecoderProtocol

@Spyable
public protocol CredentialDisplayLogoURIDecoderProtocol {
  func decode(from string: String) -> Data?
  func decode(_ url: URL) -> URI?
}

// MARK: - CredentialDisplayLogoURIDecoder

public struct CredentialDisplayLogoURIDecoder: CredentialDisplayLogoURIDecoderProtocol {

  public func decode(from string: String) -> Data? {
    guard
      let urlString = URL(string: string),
      let uri = decode(urlString)
    else {
      return nil
    }
    return Data(base64Encoded: uri)
  }

  public func decode(_ url: URL) -> URI? {
    let urlString = url.absoluteString

    switch url.scheme {
    case URLScheme.https.rawValue:
      return urlString
    case URLScheme.data.rawValue:
      let components = urlString.split(separator: ",")
      guard urlString.isValid, components.count > 1 else {
        return nil
      }

      return String(components[1])
    default:
      return nil
    }
  }
}

public typealias URI = String

extension URI {
  fileprivate var isValid: Bool {
    for format in ValueType.supportedImageTypes where starts(with: "data:\(format.rawValue);base64") {
      return true
    }

    return false
  }
}
