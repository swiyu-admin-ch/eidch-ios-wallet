import SwiftUI

// MARK: - ButtonLibrary

struct ButtonPlaygrounds: View {

  @State var isHidden = false

  var body: some View {
    List {
      Section("primary") {
        section(style: .primary)
      }
      .listRowInsets(EdgeInsets())

      Section("secondary") {
        section(style: .secondary)
      }
      .listRowInsets(EdgeInsets())

      Section("secondary reversed") {
        section(style: .secondaryReversed)
          .background(ThemingAssets.Brand.Bright.navyBlue.swiftUIColor)
      }
      .listRowInsets(EdgeInsets())

      Section("tertiary") {
        section(style: .tertiary)
      }
      .listRowInsets(EdgeInsets())

      Section("destructive") {
        section(style: .destructive)
      }
      .listRowInsets(EdgeInsets())

      Section("bezeled") {
        section(style: .bezeled)
      }
      .listRowInsets(EdgeInsets())

      Section("navy blue") {
        section(style: .navyBlue)
      }
      .listRowInsets(EdgeInsets())

    }
  }

  @ViewBuilder
  func section(style: CustomButtonStyle, text: String = "Button", imageName: String = "arrow.right") -> some View {
    Group {
      ScrollView(.horizontal, showsIndicators: false) {
        VStack {
          buttonSet(label: { Text(text) }, style: style)
          buttonSet(label: { Text(text) }, style: style, isDisabled: true)
        }
        .padding()
      }

      ScrollView(.horizontal, showsIndicators: false) {
        VStack {
          buttonSet(label: { Label(text, systemImage: imageName) }, style: style)
          buttonSet(label: { Label(text, systemImage: imageName) }, style: style, isDisabled: true)
        }
        .padding()
      }

      ScrollView(.horizontal, showsIndicators: false) {
        VStack {
          circleButtonSet(label: { Image(systemName: imageName) }, style: style)
          circleButtonSet(label: { Image(systemName: imageName) }, style: style, isDisabled: true)
        }
        .padding()
      }
    }
  }

  @ViewBuilder
  func buttonSet(label: () -> some View, style: CustomButtonStyle, isDisabled: Bool = false) -> some View {
    HStack {
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.mini)
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.small)
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.regular)
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.large)
      if #available(iOS 17.0, *) {
        button(label: label, style: style, isDisabled: isDisabled)
          .controlSize(.extraLarge)
      } else {
        // Fallback on earlier versions
      }
    }
  }

  @ViewBuilder
  func circleButtonSet(label: () -> some View, style: CustomButtonStyle, isDisabled: Bool = false) -> some View {
    HStack {
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.mini)
        .clipShape(.circle)
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.small)
        .clipShape(.circle)
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.regular)
        .clipShape(.circle)
      button(label: label, style: style, isDisabled: isDisabled)
        .controlSize(.large)
        .clipShape(.circle)
      if #available(iOS 17.0, *) {
        button(label: label, style: style, isDisabled: isDisabled)
          .controlSize(.extraLarge)
          .clipShape(.circle)
      } else {
        // Fallback on earlier versions
      }
    }
  }

  @ViewBuilder
  func button(label: () -> some View, style: CustomButtonStyle, isDisabled: Bool = false) -> some View {
    Button(action: {}, label: label)
      .buttonStyle(style)
      .disabled(isDisabled)
  }

}

#Preview {
  ButtonPlaygrounds()
}
