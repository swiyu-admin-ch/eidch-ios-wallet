import BITTheming
import SwiftUI

struct ToggleMenuCell: View {

  // MARK: Lifecycle

  init(text: String, subtitle: String? = nil, isOn: Binding<Bool>, isLoading: Binding<Bool> = .constant(false), _ onTap: (() -> Void)? = nil) {
    self.text = text
    self.subtitle = subtitle
    self.onTap = onTap
    _isOn = isOn
    _isLoading = isLoading
  }

  // MARK: Internal

  @Binding var isOn: Bool
  @Binding var isLoading: Bool

  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading) {
        HStack(alignment: .firstTextBaseline, spacing: .x4) {
          Text(text)

          Spacer(minLength: .x2)

          HStack(spacing: .x2) {
            ProgressView()
              .opacity(isLoading ? 1 : 0)

            Toggle("", isOn: $isOn)
              .tint(ThemingAssets.accentColor.swiftUIColor)
              .labelsHidden()
              .disabled(isLoading)
              .allowsHitTesting(false)
              .onTapGesture {
                onTap?()
              }
              .simultaneousGesture(
                LongPressGesture()
                  .onEnded { _ in onTap?() }
              )
          }
          .offset(y: -20)
        }

        if let subtitle {
          Text(subtitle)
            .font(.custom.footnote)
            .foregroundStyle(ThemingAssets.secondary.swiftUIColor)
            .padding(.bottom, .x2)
        }
      }

      if hasDivider {
        Rectangle()
          .frame(maxWidth: .infinity, maxHeight: 1)
          .foregroundStyle(ThemingAssets.gray3.swiftUIColor)
      }
    }
    .contentShape(Rectangle())
    .onTapGesture {
      onTap?()
    }
    .onLongPressGesture {
      onTap?()
    }
  }

  // MARK: Private

  @Environment(\.menuCellDivider) private var hasDivider: Bool

  private var text: String
  private var subtitle: String?
  private var onTap: (() -> Void)?
}
