import Foundation

public enum FetchPresentationRequestError: Error, Equatable {
  case invalidRequestUrl
  case expired
  case notFound
  case invalid(request: PresentationRequest)
}
