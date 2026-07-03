import BITCore
import Foundation
import Spyable

// MARK: - PresentationRequestUrlParserProtocol

@Spyable
protocol PresentationRequestUrlParserProtocol {
  func parse(_ url: URL) throws -> PresentationRequestUrl
}

// MARK: - PresentationRequestUrlParser

struct PresentationRequestUrlParser: PresentationRequestUrlParserProtocol {

  // MARK: Internal

  func parse(_ url: URL) throws -> PresentationRequestUrl {
    if url.scheme == URLScheme.https.rawValue {
      return .https(url)
    }
    guard let parameters = url.queryParameters else { throw PresentationRequestUrlParserError.invalidRequestUrl }
    let requestURL = try parseRequestURL(from: parameters)
    let clientId = try parseClientId(from: parameters)
    return .openID4VP(url: requestURL, clientId: clientId)
  }

  // MARK: Private

  private func parseRequestURL(from parameters: [String: String]) throws -> URL {
    guard
      let requestUriString = parameters["request_uri"]?.removingPercentEncoding,
      let requestUri = URL(string: requestUriString)
    else { throw PresentationRequestUrlParserError.invalidRequestUrl }
    return requestUri
  }

  private func parseClientId(from parameters: [String: String]) throws -> String {
    guard let clientId = parameters["client_id"]?.removingPercentEncoding else {
      throw PresentationRequestUrlParserError.invalidRequestUrl
    }
    return clientId
  }
}

// MARK: - PresentationRequestUrlParserError

enum PresentationRequestUrlParserError: Error, Equatable {
  case invalidRequestUrl
}
