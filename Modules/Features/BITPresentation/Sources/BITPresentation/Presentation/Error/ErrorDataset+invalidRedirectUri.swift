import BITL10n
import BITTheming

extension ErrorDataset {
  public static var invalidRedirectUri: ErrorDataset {
    ErrorDataset([
      .title(L10n.tkErrorRedirectUriInvalidPrimary),
      .body(L10n.tkErrorRedirectUriInvalidSecondary),
    ])
  }
}
