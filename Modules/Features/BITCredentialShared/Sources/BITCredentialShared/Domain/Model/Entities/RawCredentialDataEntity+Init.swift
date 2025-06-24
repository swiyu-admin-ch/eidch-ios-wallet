import BITEntities

extension RawCredentialDataEntity {

  convenience init(_ rawCredentialData: RawCredentialData) {
    self.init()
    id = rawCredentialData.id
    rawOIDMetadata = try? rawCredentialData.rawOIDMetadata?.compressed()
    rawOcaBundle = try? rawCredentialData.rawOcaBundle?.compressed()
  }

}
