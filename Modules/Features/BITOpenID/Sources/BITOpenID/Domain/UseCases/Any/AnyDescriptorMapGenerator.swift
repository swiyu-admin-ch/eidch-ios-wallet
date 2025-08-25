import BITAnyCredentialFormat
import Factory

// MARK: - CreateAnyDescriptorMapUseCase

struct AnyDescriptorMapGenerator: AnyDescriptorMapGeneratorProtocol {

  // MARK: Lifecycle

  init(anyDescriptorMapGeneratorDispatcher: [CredentialFormat: AnyDescriptorMapGeneratorProtocol] = Container.shared.anyDescriptorMapGeneratorDispatcher()) {
    dispatcher = anyDescriptorMapGeneratorDispatcher
  }

  // MARK: Internal

  func generate(using inputDescriptor: InputDescriptor, vcFormat: String) throws -> [PresentationRequestBody.DescriptorMap] {
    inputDescriptor.formats
      .compactMap { CredentialFormat(rawValue: $0.label) }
      .compactMap { dispatcher[$0] }
      .compactMap { try? $0.generate(using: inputDescriptor, vcFormat: vcFormat) }
      .flatMap { $0 }
  }

  // MARK: Private

  private let dispatcher: [CredentialFormat: AnyDescriptorMapGeneratorProtocol]
}
