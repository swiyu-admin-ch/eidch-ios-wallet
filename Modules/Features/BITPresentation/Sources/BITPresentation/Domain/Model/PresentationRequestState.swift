import BITOpenID

public enum PresentationRequestResultState: Equatable, Hashable {
  case dataTransmitted(PresentationResponse?)
  case deny(PresentationResponse?)
  case error

  var presentationResponse: PresentationResponse? {
    switch self {
    case .dataTransmitted(let presentationResponse),
         .deny(let presentationResponse):
      presentationResponse
    case .error:
      nil
    }
  }
}
