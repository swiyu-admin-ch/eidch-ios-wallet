import BITAnyCredentialFormat
import BITCredential
import BITCredentialShared
import BITOpenID
import Factory
import Spyable

// MARK: - GetCompatibleCredentialsUseCaseProtocol

@Spyable
public protocol GetCompatibleCredentialsUseCaseProtocol {
  func execute(using requestObject: RequestObject) async throws -> [CompatibleCredential]
}

// MARK: - GetCompatibleCredentialsUseCase

/// https://identity.foundation/presentation-exchange/spec/v2.1.0/#presentation-definition

struct GetCompatibleCredentialsUseCase: GetCompatibleCredentialsUseCaseProtocol {

  // MARK: Internal

  func execute(using requestObject: RequestObject) async throws -> [CompatibleCredential] {
    guard let inputDescriptor = requestObject.firstInputDescriptor else { return [] }
    let credentials = try await credentialRepository.getAllAcceptedVerifiableCredentials()
    return filter(credentials: credentials, withInputDescriptor: inputDescriptor)
  }

  // MARK: Private

  @Injected(\.credentialRepository) private var credentialRepository
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase
  @Injected(\.presentationFieldsValidator) private var presentationFieldsValidator

  private func filter(credentials: [VerifiableCredential], withInputDescriptor inputDescriptor: InputDescriptor) -> [CompatibleCredential] {
    credentials.compactMap { credential in
      do {
        guard credential.validate(withFormats: inputDescriptor.formats) else { return nil }
        let anyCredential = try createAnyCredentialUseCase.execute(from: credential.payload, format: credential.format)
        let matchingFields: [PresentationField] = try presentationFieldsValidator.validate(anyCredential, with: inputDescriptor.constraints.fields)
        guard !matchingFields.isEmpty else { return nil }
        return CompatibleCredential(credential: credential, requestedFields: matchingFields)
      } catch {
        return nil
      }
    }
  }
}

extension VerifiableCredential {

  fileprivate func validate(withFormats formats: [Format]) -> Bool {
    let matchingFormats = formats.filter { $0.label == self.format }
    return !matchingFormats.filter { $0.keyBindingAlgorithm == nil }.isEmpty
      || !matchingFormats.compactMap { f in f.keyBindingAlgorithm }
      .flatMap { $0 }
      .filter {
        self.keyBinding?.algorithm.caseInsensitiveCompare($0) == .orderedSame
      }.isEmpty
  }
}
