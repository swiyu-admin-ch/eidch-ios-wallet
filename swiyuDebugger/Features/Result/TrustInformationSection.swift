import BITCredential
import BITNonCompliance
import Factory
import SwiftUI

// MARK: - TrustInformationSection

struct TrustInformationSection: View {

  // MARK: Lifecycle

  init(trustInformation: TrustInformation?, actorCompliance: ActorCompliance?) {
    self.trustInformation = trustInformation
    self.actorCompliance = actorCompliance
  }

  // MARK: Internal

  var body: some View {
    Section("Trust information") {
      if let trustInformation {
        switch trustInformation.identity {
        case .trusted:
          Text("Identity: trusted")
        case .untrusted:
          Text("Identity: untrusted")
        case .unknown:
          Text("Identity: unknown")
        case .trustedCheckApp:
          Text("Identity: trustedCheckApp")
        }
        Text("Actor trust: \(trustInformation.actorTrust.rawValue)")
        Text("VC Schema: \(trustInformation.vcSchema.rawValue)")
        switch actorCompliance {
        case .compliant?:
          Text("Actor compliance: compliant")
        case .notCompliant?:
          Text("Actor compliance: notCompliant")
        case nil:
          Text("Actor compliance: unknown")
        }
        if
          case .notCompliant(let reason) = actorCompliance,
          let localizedReason = reason?.getPreferredDisplay(considering: Container.shared.preferredUserLanguageCodes())
        {
          Text("Reason: \(localizedReason)")
        }
      } else {
        Text("Unavailable")
      }
    }
  }

  // MARK: Private

  private let trustInformation: TrustInformation?
  private let actorCompliance: ActorCompliance?

}

#if DEBUG
#Preview {
  TrustInformationSection(trustInformation: .Mock.fullyTrusted, actorCompliance: .compliant)
}
#endif
