import BITActivity
import BITCredentialShared

extension Activity {
  init(credential: VerifiableCredential, trustInformation: TrustInformation) {
    self.init(
      type: .issuance,
      actorTrust: trustInformation.actorTrust,
      vcSchemaTrust: trustInformation.vcSchemaTrust,
      actorCompliance: trustInformation.actorComplianceStatus,
      nonComplianceReasonDisplays: trustInformation.nonComplianceReasonDisplays,
      actorDisplays: credential.issuerDisplays.map(ActivityActorDisplay.init))
  }
}

extension ActivityActorDisplay {
  init(display: CredentialIssuerDisplay) {
    self.init(
      name: display.name,
      locale: display.locale,
      image: display.image)
  }
}
