import Factory
import Foundation
import Spyable

// MARK: - DeclinePresentationUseCaseProtocol

@Spyable
public protocol DeclinePresentationUseCaseProtocol {
  func execute(requestObject: RequestObject) async throws
}

// MARK: - DeclinePresentationUseCase

struct DeclinePresentationUseCase: DeclinePresentationUseCaseProtocol {

  func execute(requestObject: RequestObject) async throws {
    try await service.decline(for: requestObject, with: .clientRejected)
  }

  @Injected(\.presentationRequestService) private var service
}
