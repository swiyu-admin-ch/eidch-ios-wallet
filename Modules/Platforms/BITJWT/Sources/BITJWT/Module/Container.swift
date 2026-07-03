import Factory
import Foundation

extension Container {

  // MARK: Public

  public var jwsValidator: Factory<JWSValidatorProtocol> {
    self { JWSValidator() }
  }

  public var jwsSignatureValidator: Factory<JWSSignatureValidatorProtocol> {
    self { JWSSignatureValidator() }
  }

  public var jwsDecoder: Factory<JWSDecoderProtocol> {
    self { JWSDecoder() }
  }

  public var jwsEncoder: Factory<JWSEncoderProtocol> {
    self { JWSEncoder() }
  }

  public var didResolverHelper: Factory<DidResolverHelperProtocol> {
    self { DidResolverHelper() }
  }

  // MARK: Internal

  var didResolverRepository: Factory<DidResolverRepositoryProtocol> {
    self { DidResolverRepository() }
  }

}
