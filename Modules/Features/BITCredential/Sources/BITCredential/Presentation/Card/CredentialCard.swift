import BITCredentialShared
import BITL10n
import BITOpenID
import BITTheming
import SwiftUI

// MARK: - CredentialCard

public struct CredentialCard: View {

  // MARK: Lifecycle

  public init(
    name: String? = nil,
    summary: String? = nil,
    background: String? = nil,
    logoBase64: Data? = nil,
    environment: TrustEnvironment? = nil,
    statusBadgeLabel: String? = nil,
    statusBadgeImage: Image? = nil,
    statusBadgeStyle: (any BadgeStyle)? = nil,
    colorSchemeOverride: ColorScheme? = nil,
    style: CredentialCardStyle = .verifiable)
  {
    self.name = name
    self.summary = summary
    self.environment = environment
    self.background = background
    self.logoBase64 = logoBase64
    self.statusBadgeLabel = statusBadgeLabel
    self.statusBadgeImage = statusBadgeImage
    self.statusBadgeStyle = statusBadgeStyle
    self.colorSchemeOverride = colorSchemeOverride
    self.style = style
  }

  // MARK: Public

  public var body: some View {
    ZStack {
      Group {
        linearGradient()
        if controlSize > .small && style == .verifiable {
          radialBackground()
        }
      }
      .overlay {
        if backgroundColor == nil {
          fallbackBackground()
            .accessibilityHidden(true)
        }
      }
      .overlay {
        if style == .deferred {
          RoundedRectangle(cornerRadius: cornerRadius)
            .fill(ThemingAssets.Background.groupedRow.swiftUIColor)
            .opacity(deferredCredentialOverlayOpacity)
        }
      }
      .overlay {
        if style == .deferred {
          RoundedRectangle(cornerRadius: cornerRadius)
            .inset(by: 0.5)
            .stroke(
              backgroundColor ?? ThemingAssets.Background.fallback.swiftUIColor,
              style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
      }
      .overlay {
        if environment == .swiyuInt {
          (controlSize < .regular ? Assets.credentialDemoPatternSmall.swiftUIImage : Assets.credentialDemoPattern.swiftUIImage)
            .opacity(0.5)
            .clipped()
            .accessibilityHidden(true)
        }
      }
      content()
        .foregroundStyle(cardColorScheme.standardColor())
        .if(style == .verifiable, transform: {
          $0.colorScheme(cardColorScheme)
        })
    }
    .frame(minWidth: minWidth, maxWidth: maxWidth, minHeight: minHeight, maxHeight: maxHeight)
    .if(ratio != nil, transform: {
      $0.aspectRatio(ratio, contentMode: .fit)
    })
    .background(backgroundColor ?? ThemingAssets.Background.fallback.swiftUIColor)
    .clipShape(.rect(cornerRadius: cornerRadius))
    .contentShape(.accessibility, .rect(cornerRadius: cornerRadius))
  }

  // MARK: Private

  @Environment(\.sizeCategory) private var sizeCategory
  @Environment(\.controlSize) private var controlSize
  @State private var size = CGSize.zero

  private var name: String?
  private var summary: String?
  private var background: String?
  private var logoBase64: Data?
  private var environment: TrustEnvironment?
  private var statusBadgeLabel: String?
  private var statusBadgeImage: Image?
  private var statusBadgeStyle: (any BadgeStyle)?
  private var style: CredentialCardStyle
  private var colorSchemeOverride: ColorScheme?

  private let secondaryTextOpacity = 0.7
  private let deferredCredentialOverlayOpacity = 0.6
  private let defaultText = "n/a"

  private var cardColorScheme: ColorScheme {
    colorSchemeOverride ?? backgroundColor?.suggestedColorScheme() ?? .light
  }

  private var backgroundColor: Color? {
    guard let hexColor = background else { return nil }
    return Color(hex: hexColor)
  }

  @ViewBuilder
  private func fallbackBackground() -> some View {
    if controlSize > .small {
      Assets.credentialFallbackBackground.swiftUIImage
        .resizable()
        .scaledToFill()
        .opacity(0.5)
        .clipped()
    } else {
      Assets.credentialFallbackBackground.swiftUIImage
        .opacity(0.5)
        .clipped()
    }
  }

  @ViewBuilder
  private func image() -> some View {
    if let data = logoBase64, !sizeCategory.isAccessibilityCategory || controlSize < .large {
      Image(data: data)?
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(maxWidth: imageMaxWidth, maxHeight: imageMaxHeight, alignment: controlSize > .small ? .topTrailing : .center)
        .colorMultiply(cardColorScheme.standardColor())
        .accessibility(hidden: true)
    }
  }

  @ViewBuilder
  private func content() -> some View {
    switch controlSize {
    case .mini,
         .small: contentMini()
    case .large: contentLarge()
    default: contentRegular()
    }
  }

  private func contentRegular() -> some View {
    VStack(alignment: .leading) {

      HStack {
        Spacer()
        image()
      }

      Spacer()

      VStack(alignment: .leading) {
        Text(name ?? defaultText)
          .font(.mono.headline)
          .fixedSize(horizontal: false, vertical: true)
          .frame(maxWidth: .infinity, alignment: .leading)
          .multilineTextAlignment(.leading)

        if let summary {
          Text(summary)
            .font(.mono.headline)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .opacity(secondaryTextOpacity)
        }
      }
    }
    .padding(.x5)
  }

  private func contentLarge() -> some View {
    VStack(alignment: .leading, spacing: .x6) {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text(name ?? defaultText)
            .font(.mono.headline)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .accessibilitySortPriority(AccessibilityPriority.x1.rawValue)
            .accessibilityAddTraits(.isHeader)

          if let summary {
            Text(summary)
              .font(.mono.headline)
              .fixedSize(horizontal: false, vertical: true)
              .frame(maxWidth: .infinity, alignment: .leading)
              .multilineTextAlignment(.leading)
              .opacity(secondaryTextOpacity)
              .accessibilitySortPriority(AccessibilityPriority.x2.rawValue)
          }
        }

        Spacer(minLength: .x6)

        image()
      }

      Spacer()

      ViewThatFits {
        HStack {
          badges()
        }

        VStack {
          badges()
        }
      }
      .accessibilitySortPriority(AccessibilityPriority.x3.rawValue)
    }
    .padding(.x5)
  }

  private func contentMini() -> some View {
    image()
  }

  private func linearGradient() -> some View {
    LinearGradient(
      colors: [.black, Color.clear],
      startPoint: UnitPoint(angle: .degrees(110)),
      endPoint: UnitPoint(angle: .degrees(110 + 180)))
      .opacity(0.25)
  }

  private func radialBackground() -> some View {
    EllipticalGradient(
      colors: [.black, .black, .clear],
      center: .bottomLeading,
      startRadiusFraction: 0,
      endRadiusFraction: 1)
      .opacity(0.15)
      .blur(radius: 6)
      .scaleEffect(x: 0.8, y: 0.5, anchor: .bottomLeading)
  }

  @ViewBuilder
  private func badges() -> some View {
    if environment == .swiyuInt {
      Badge(label: L10n.tkCredentialStatusDemo)
        .badgeStyle(.info)
        .colorScheme(cardColorScheme == .dark ? .light : .dark)
        .accessibilityLabel(L10n.tkCredentialStatusDemoAlt)
    }
    if let statusBadgeLabel, let statusBadgeImage, let statusBadgeStyle {
      CredentialStatusBadge(label: statusBadgeLabel, image: statusBadgeImage, style: statusBadgeStyle)
    }
  }

}

extension CredentialCard {

  private var minWidth: CGFloat {
    switch controlSize {
    case .mini: 48
    case .small: 72
    default: 172
    }
  }

  private var maxWidth: CGFloat {
    switch controlSize {
    case .mini: 48
    case .small: 72
    default: .infinity
    }
  }

  private var minHeight: CGFloat {
    switch controlSize {
    case .mini: 66
    case .small: 96
    case .regular: 150
    case .large: 200
    @unknown default: 250
    }
  }

  private var maxHeight: CGFloat {
    switch controlSize {
    case .mini: 66
    case .small: 96
    case .large: .infinity
    default: sizeCategory.isAccessibilityCategory ? .infinity : 500
    }
  }

  private var ratio: CGFloat? {
    switch controlSize {
    case .regular: sizeCategory.isAccessibilityCategory ? nil : 0.681
    case .large: 1.586
    default: nil
    }
  }

  private var imageMaxHeight: CGFloat {
    switch controlSize {
    case .large: 32
    case .mini: 24
    default: 21
    }
  }

  private var imageMaxWidth: CGFloat {
    switch controlSize {
    case .mini: 24
    case .small: maxWidth - .x2
    default: 60
    }
  }

  private var cornerRadius: CGFloat {
    switch controlSize {
    case .mini: 8
    case .small: 12
    default: 20
    }
  }

}

#if DEBUG
#Preview {
  ScrollView {
    VStack {
      CredentialCard(statusBadgeLabel: "label", statusBadgeImage: Image(systemName: "faceid"), statusBadgeStyle: .info)
        .controlSize(.mini)

      CredentialCard(statusBadgeLabel: "label", statusBadgeImage: Image(systemName: "faceid"), statusBadgeStyle: .info)
        .controlSize(.small)

      CredentialCard(statusBadgeLabel: "label", statusBadgeImage: Image(systemName: "faceid"), statusBadgeStyle: .info)
        .controlSize(.regular)

      CredentialCard(statusBadgeLabel: "label", statusBadgeImage: Image(systemName: "faceid"), statusBadgeStyle: .info)
        .controlSize(.large)
    }
  }
}
#endif
