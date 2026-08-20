import BITL10n
import BITTheming
import Factory
import NavigatorUI
import SwiftUI

// MARK: - NonComplianceDescriptionView

struct NonComplianceDescriptionView: View {

  // MARK: Lifecycle

  init(initialValue: String) {
    _viewModel = State(initialValue: NonComplianceDescriptionViewModel(initialValue: initialValue))
  }

  // MARK: Internal

  var body: some View {
    ZStack(alignment: .top) {
      ThemingAssets.Background.secondary.swiftUIColor
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
      inputField
        .landscapeMaxWidth()
    }
    .safeAreaInset(edge: .bottom) {
      button
    }
    .navigationBarBackButtonHidden()
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(L10n.tkNonComplianceReportFormDescriptionTitle)
    .onAppear {
      focusField = true
    }
    .toolbar {
      ToolbarItem(placement: .topBarLeading) {
        Button(action: navigateBack) {
          Image(systemName: "chevron.backward")
        }
        .accessibilityLabel(Text(L10n.tkGlobalBack))
      }
      CloseButtonToolbar(action: {
        navigator.dismiss()
      })
    }
  }

  // MARK: Private

  @Environment(\.navigator) private var navigator

  @FocusState private var focusField: Bool
  @State private var viewModel: NonComplianceDescriptionViewModel

  private var inputField: some View {
    Form {
      Section {
        VStack(alignment: .leading, spacing: .x1) {
          TextField(
            L10n.tkNonComplianceReportFormDescriptionPlaceholder,
            text: $viewModel.value,
            placeholderColor: ThemingAssets.Label.secondary.swiftUIColor,
            axis: .vertical)
            .focused($focusField)
            .font(.custom.body)
            .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
            .accessibilityLabel(Text(L10n.tkNonComplianceReportFormDescriptionTitleAlt))
          hintText
        }
        .padding(.x4)
        .listRowInsets(EdgeInsets())
      }
    }
    .scrollContentBackground(.hidden)
  }

  private var hintText: some View {
    HStack(spacing: 0) {
      if let hint = NonComplianceFormField.description.hint(for: viewModel.validation) {
        Text(hint)
      }
      Spacer(minLength: .x2)
      if let maxLength = NonComplianceFormField.description.maximumLength {
        Text("\(viewModel.value.count)/\(maxLength)")
          .accessibilityLabel(L10n.tkNonComplianceReportFormDescriptionCharacterCountAlt(viewModel.value.count, maxLength))
      }
    }
    .font(.custom.caption1)
    .foregroundStyle(viewModel.validation == .valid ? ThemingAssets.Label.secondary.swiftUIColor : ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor)
  }

  private var button: some View {
    ButtonSheet(colorConfig: .secondary) {
      Button(action: navigateBack) {
        Text(L10n.tkNonComplianceReportFormDescriptionSaveButton)
          .frame(maxWidth: .infinity)
      }
      .disabled(viewModel.validation != .valid)
      .buttonStyle(.primary)
      .controlSize(.large)
    }
  }

  private func navigateBack() {
    navigator.returnToCheckpointSafely(
      NonComplianceCheckpoints.form,
      value: NonComplianceFormCheckpointUpdate(field: .description, value: viewModel.value))
  }
}

#if DEBUG
#Preview {
  NonComplianceDescriptionView(initialValue: String(repeating: "Y", count: 10))
}
#endif
