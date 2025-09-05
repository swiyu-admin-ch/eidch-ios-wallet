import BITL10n
import BITTheming
import SwiftUI

public struct LicenceDetailView: View {

  // MARK: Lifecycle

  public init(package: PackageDependency) {
    self.package = package
  }

  // MARK: Public

  public var body: some View {
    SettingsPage(title: package.name) {
      VStack(alignment: .leading, spacing: .x4) {
        Text(package.version ?? L10n.tkSettingsLicencesNoVersion)
          .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
          .font(.custom.headline)
        if let licence = package.license {
          Text(licence)
            .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
            .multilineTextAlignment(.leading)
            .font(.custom.footnote)
        }
      }
    }
  }

  // MARK: Private

  private let package: PackageDependency

}

#Preview {
  LicenceDetailView(package: PackageDependency(name: "Test", version: "1.0.0", license: "MIT"))
}
