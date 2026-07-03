import BITAVWrapper
import BITL10n
import BITTheming
import NavigatorUI
import SwiftUI

extension ErrorDataset {

  // MARK: Internal

  static func avBeamError(
    _ error: AVBeamError,
    retryAction: @escaping (Navigator) -> Void,
    closeAction: (() -> Void)? = nil)
    -> ErrorDataset
  {
    let contents = avBeamContents(for: error)
    return switch error.errorType {
    case .critical:
      criticalDataset(contents, closeAction)
    case .error:
      errorDataset(contents, retryAction)
    case .warning:
      warningDataset(contents, retryAction)
    }
  }

  static func avBeamContents(for error: AVBeamError) -> [InformationView2.ContentType] {
    [
      .hero(image: avBeamHeroImage(for: error)),
      .title(error.title),
      .body(error.content),
      .captionErrorDescription(error),
    ]
  }

  // MARK: Private

  private static func criticalDataset(_ contents: [InformationView2.ContentType], _ close: (() -> Void)? = nil) -> ErrorDataset {
    ErrorDataset(contents, actions: [
      .primary(L10n.tkGlobalClose, { navigator in
        close?()
        Task { @MainActor in
          navigator.dismiss()
        }
      }),
    ])
  }

  private static func errorDataset(_ contents: [InformationView2.ContentType], _ action: ((Navigator) -> Void)? = nil) -> ErrorDataset {
    ErrorDataset(contents, actions: [
      .primary(L10n.tkErrorGenericButtonPrimary, { navigator in
        Task { @MainActor in
          action?(navigator)
        }
      }),
    ])
  }

  private static func warningDataset(_ contents: [InformationView2.ContentType], _ retry: @escaping (Navigator) -> Void) -> ErrorDataset {
    ErrorDataset(contents, actions: [
      .primary(L10n.tkErrorGenericButtonPrimary, retry),
    ])
  }

  private static func avBeamHeroImage(for error: AVBeamError) -> Image {
    switch error {
    case .unsupportedCameraResolution:
      Assets.cameraSlash.swiftUIImage
    case .unsupportedVideoConfiguration:
      Assets.videoSlash.swiftUIImage
    case .imageBlurred:
      Assets.blurry.swiftUIImage
    case .reflection:
      Assets.reflections.swiftUIImage
    case .idNoData,
         .idNotDetected,
         .idPageMissing:
      Assets.unknown.swiftUIImage
    case .idMatchingFailed,
         .idNotInList:
      Assets.documentSlash.swiftUIImage
    case .idBadMrzFieldBirthDay,
         .idBadMrzFieldCompositCheckDigit,
         .idBadMrzFieldCountry,
         .idBadMrzFieldDocumentNumber,
         .idBadMrzFieldFirstName,
         .idBadMrzFieldGender,
         .idBadMrzFieldLastName,
         .idBadMrzFieldNationality,
         .idBadMrzFields,
         .mrzNotDetected:
      Assets.scanDocument.swiftUIImage
    case .faceNotRecognized:
      Assets.scanFaceSlash.swiftUIImage
    default:
      ThemingAssets.closeCircle.swiftUIImage
    }
  }
}
