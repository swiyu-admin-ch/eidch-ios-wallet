import Factory

extension Container {

  public var qrCodeGenerator: Factory<QRCodeGeneratorProtocol> {
    self { QRCodeGenerator() }
  }

}
