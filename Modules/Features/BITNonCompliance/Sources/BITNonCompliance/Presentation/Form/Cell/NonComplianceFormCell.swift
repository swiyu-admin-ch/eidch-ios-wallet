import BITL10n
import BITTheming
import Factory
import SwiftUI

// MARK: - NonComplianceFormCell

struct NonComplianceFormCell: View {

  // MARK: Lifecycle

  init(viewModel: NonComplianceFormCellViewModel, onSubmit: @escaping () -> Void = {}) {
    self.viewModel = viewModel
    self.onSubmit = onSubmit
  }

  // MARK: Internal

  var body: some View {
    VStack(alignment: .leading, spacing: .x1) {
      Text(viewModel.field.title)
        .font(.custom.bodyEmphasized)
        .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
        .accessibilityLabel(viewModel.field.titleAlt)
      switch viewModel.field {
      case .description: text
      case .email: emailField
      }
      if viewModel.isInvalid {
        hintText
      }
    }
    .accessibilityElement(children: .contain)
  }

  // MARK: Private

  private let viewModel: NonComplianceFormCellViewModel
  private let onSubmit: () -> Void

  private var text: some View {
    Text(viewModel.fieldText)
      .font(.custom.body)
      .foregroundStyle(
        viewModel.value.wrappedValue.isEmpty
          ? ThemingAssets.Label.secondary.swiftUIColor
          : ThemingAssets.Label.primary.swiftUIColor)
      .multilineTextAlignment(.leading)
  }

  private var emailField: some View {
    TextField(
      viewModel.field.placeholder,
      text: viewModel.value,
      placeholderColor: ThemingAssets.Label.secondary.swiftUIColor)
      .font(.custom.body)
      .foregroundStyle(ThemingAssets.Label.primary.swiftUIColor)
      .keyboardType(.emailAddress)
      .textContentType(.emailAddress)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .submitLabel(.continue)
      .onSubmit(onSubmit)
      .accessibilityLabel(Text(viewModel.field.title))
  }

  private var hintText: some View {
    HStack {
      if let hint = viewModel.field.hint(for: viewModel.validation) {
        Text(hint)
      }
      if let maxLength = viewModel.field.maximumLength {
        Spacer()
        Text("\(viewModel.value.wrappedValue.count)/\(maxLength)")
          .accessibilityLabel(L10n.tkNonComplianceReportFormDescriptionCharacterCountAlt(viewModel.value.wrappedValue.count, maxLength))
      }
    }
    .font(.custom.caption1)
    .foregroundStyle(ThemingAssets.Brand.Bright.swissRedLabel.swiftUIColor)
  }
}
