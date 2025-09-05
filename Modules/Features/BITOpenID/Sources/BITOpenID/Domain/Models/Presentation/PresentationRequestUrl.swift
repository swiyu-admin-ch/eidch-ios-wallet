import Foundation

// MARK: - PresentationRequestUrl

enum PresentationRequestUrl {
  case https(URL)
  case openID4VP(url: URL, clientId: String)

  var url: URL {
    switch self {
    case .https(let url):
      url
    case .openID4VP(let url, _):
      url
    }
  }
}
