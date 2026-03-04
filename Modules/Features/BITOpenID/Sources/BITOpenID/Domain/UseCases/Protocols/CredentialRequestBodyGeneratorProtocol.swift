import Foundation
import Spyable

@Spyable
protocol CredentialRequestBodyGeneratorProtocol {
  func generate(for context: FetchCredentialContext, proofs: CredentialRequest.Proofs?) throws -> CredentialRequestBody
}
