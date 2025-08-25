import BITAnyCredentialFormat
import BITCore
import BITCredential
import BITCredentialShared
import BITOpenID
import Factory

// MARK: - CompatibleCredentialsError

public enum CompatibleCredentialsError: Error {
  case emptyWallet
  case compatibleCredentialNotFound
}

// MARK: - GetCompatibleCredentialsUseCase

/// https://identity.foundation/presentation-exchange/spec/v2.1.0/#presentation-definition

struct GetCompatibleCredentialsUseCase: GetCompatibleCredentialsUseCaseProtocol {

  // MARK: Internal

  func execute(using requestObject: RequestObject) async throws -> [InputDescriptorID: [CompatibleCredential]] {
    do {
      let requests = try await withThrowingTaskGroup(of: (inputDescriptorId: String, compatibleCredentials: [CompatibleCredential]).self, returning: [String: [CompatibleCredential]].self) { group in
        for inputDescriptor in requestObject.presentationDefinition.inputDescriptors {
          group.addTask {
            let compatibleCredentials = try await execute(inputDescriptor: inputDescriptor)
            return (inputDescriptor.id, compatibleCredentials)
          }
        }

        var requests: [String: [CompatibleCredential]] = [:]
        for try await (inputDescriptorId, compatibleCredentials) in group {
          requests[inputDescriptorId] = compatibleCredentials
        }

        return requests
      }

      if requests.contains(where: \.value.isEmpty) {
        throw CompatibleCredentialsError.compatibleCredentialNotFound
      }

      return requests
    } catch {
      throw error
    }
  }

  // MARK: Private

  @Injected(\.databaseCredentialRepository) private var repository: CredentialRepositoryProtocol
  @Injected(\.createAnyCredentialUseCase) private var createAnyCredentialUseCase: CreateAnyCredentialUseCaseProtocol
  @Injected(\.presentationFieldsValidator) private var presentationFieldsValidator: PresentationFieldsValidatorProtocol

  private func execute(inputDescriptor: InputDescriptor) async throws -> [CompatibleCredential] {
    let credentials = try await repository.getAll()
    if credentials.isEmpty {
      throw CompatibleCredentialsError.emptyWallet
    }
    let compatibleCredentials = try filter(credentials: credentials, withInputDescriptor: inputDescriptor)
    if compatibleCredentials.isEmpty {
      throw CompatibleCredentialsError.compatibleCredentialNotFound
    }
    return compatibleCredentials
  }

  private func filter(credentials: [Credential], withInputDescriptor inputDescriptor: InputDescriptor) throws -> [CompatibleCredential] {
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

extension Credential {

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
