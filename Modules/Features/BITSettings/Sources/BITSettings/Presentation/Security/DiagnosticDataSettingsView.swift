import BITL10n
import BITTheming
import SwiftUI

struct DiagnosticDataSettingsView: View {

  // MARK: Internal

  var body: some View {
    SettingsPage(title: L10n.tkSettingsDiagnosticDataTitle) {
      SettingsSection {
        VStack(alignment: .leading, spacing: .x4) {
          Text(L10n.tkSettingsDiagnosticDataBody)
            .padding(.vertical, .x3)
          VStack(alignment: .leading, spacing: .x1) {
            bulletPoint(L10n.tkSettingsDiagnosticDataGeneralError)
            bulletPoint(L10n.tkSettingsDiagnosticDataCommunicationError)
            bulletPoint(L10n.tkSettingsDiagnosticDataAppCrash)
          }
        }
        .padding(.vertical, .x4)
        .padding(.horizontal, .x6)
      }
    }
  }

  @ViewBuilder
  func bulletPoint(_ title: String) -> some View {
    HStack(spacing: .x1) {
      Assets.checkmark.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(width: checkmarkSize, height: checkmarkSize)
        .accessibilityHidden(true)
      Text(title)
        .multilineTextAlignment(.leading)
        .font(.custom.body)
        .foregroundColor(ThemingAssets.Label.primary.swiftUIColor)
    }
  }

  // MARK: Private

  @ScaledMetric(relativeTo: .body) private var checkmarkSize: CGFloat = 28
}

#Preview {
  DiagnosticDataSettingsView()
}
