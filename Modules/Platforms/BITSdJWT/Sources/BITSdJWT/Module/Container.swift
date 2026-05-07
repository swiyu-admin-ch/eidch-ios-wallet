import Factory

extension Container {

  public var sdJwsDecoder: Factory<SdJWSDecoderProtocol> {
    self { SdJWSDecoder() }
  }

  public var vcSdJwsDecoder: Factory<VcSdJWSDecoderProtocol> {
    self { VcSdJWSDecoder() }
  }
}
