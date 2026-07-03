// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// MARK: - L10n

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// An unexpected error occurred that could not be resolved. Please restart the process and try again.
  public static var avbeamErrorFaceCaptureIntegrityCheckFailedContent: String {
    L10n.tr("Localizable", "avbeam_error_faceCaptureIntegrityCheckFailed_content", fallback: "An unexpected error occurred that could not be resolved. Please restart the process and try again.")
  }

  /// Something went wrong
  public static var avbeamErrorFaceCaptureIntegrityCheckFailedTitle: String {
    L10n.tr("Localizable", "avbeam_error_faceCaptureIntegrityCheckFailed_title", fallback: "Something went wrong")
  }

  /// Your face could not be detected in the video. Make sure your face is well lit, centered, and not obstructed.
  public static var avbeamErrorFaceNotRecognizedContent: String {
    L10n.tr("Localizable", "avbeam_error_faceNotRecognized_content", fallback: "Your face could not be detected in the video. Make sure your face is well lit, centered, and not obstructed.")
  }

  /// Face not detected.
  public static var avbeamErrorFaceNotRecognizedTitle: String {
    L10n.tr("Localizable", "avbeam_error_faceNotRecognized_title", fallback: "Face not detected.")
  }

  /// The information on the document could not be read. Please try scanning the page again.
  public static var avbeamErrorIdBadMrzFieldsContent: String {
    L10n.tr("Localizable", "avbeam_error_idBadMrzFields_content", fallback: "The information on the document could not be read. Please try scanning the page again.")
  }

  /// Not readable
  public static var avbeamErrorIdBadMrzFieldsTitle: String {
    L10n.tr("Localizable", "avbeam_error_idBadMrzFields_title", fallback: "Not readable")
  }

  /// This document has expired. Please use a valid document or renew it before continuing.
  public static var avbeamErrorIdExpiredContent: String {
    L10n.tr("Localizable", "avbeam_error_idExpired_content", fallback: "This document has expired. Please use a valid document or renew it before continuing.")
  }

  /// Document expired
  public static var avbeamErrorIdExpiredTitle: String {
    L10n.tr("Localizable", "avbeam_error_idExpired_title", fallback: "Document expired")
  }

  /// The document used does not meet the requirements. You can use one of the following documents:
  ///
  /// Swiss identity card
  /// Swiss passport
  /// Swiss residence permit
  public static var avbeamErrorIdMatchingFailedContent: String {
    L10n.tr("Localizable", "avbeam_error_idMatchingFailed_content", fallback: "The document used does not meet the requirements. You can use one of the following documents:\n\nSwiss identity card\nSwiss passport\nSwiss residence permit")
  }

  /// No matching document
  public static var avbeamErrorIdMatchingFailedTitle: String {
    L10n.tr("Localizable", "avbeam_error_idMatchingFailed_title", fallback: "No matching document")
  }

  /// The document could not be recognized. Please try again and use one of the following documents:
  ///
  /// Swiss identity card
  /// Swiss passport
  /// Swiss residence permit
  public static var avbeamErrorIdNoDataContent: String {
    L10n.tr("Localizable", "avbeam_error_idNoData_content", fallback: "The document could not be recognized. Please try again and use one of the following documents:\n\nSwiss identity card\nSwiss passport\nSwiss residence permit")
  }

  /// Identity document does not match
  public static var avbeamErrorIdNoDataTitle: String {
    L10n.tr("Localizable", "avbeam_error_idNoData_title", fallback: "Identity document does not match")
  }

  /// Not all corners of the document are within the frame. Please make sure the document is fully inside the frame when scanning.
  public static var avbeamErrorIdNotDetectedContent: String {
    L10n.tr("Localizable", "avbeam_error_idNotDetected_content", fallback: "Not all corners of the document are within the frame. Please make sure the document is fully inside the frame when scanning.")
  }

  /// No document detected
  public static var avbeamErrorIdNotDetectedTitle: String {
    L10n.tr("Localizable", "avbeam_error_idNotDetected_title", fallback: "No document detected")
  }

  /// The document used does not meet the requirements. You can use one of the following documents:
  ///
  /// Swiss identity card
  /// Swiss passport
  /// Swiss residence permit
  public static var avbeamErrorIdNotInListContent: String {
    L10n.tr("Localizable", "avbeam_error_idNotInList_content", fallback: "The document used does not meet the requirements. You can use one of the following documents:\n\nSwiss identity card\nSwiss passport\nSwiss residence permit")
  }

  /// Invalid document
  public static var avbeamErrorIdNotInListTitle: String {
    L10n.tr("Localizable", "avbeam_error_idNotInList_title", fallback: "Invalid document")
  }

  /// We did not receive both pages of your document.
  ///
  /// Make sure, you scan the 1st and the 2nd page of your document.
  public static var avbeamErrorIdPageMissingContent: String {
    L10n.tr("Localizable", "avbeam_error_idPageMissing_content", fallback: "We did not receive both pages of your document.\n\nMake sure, you scan the 1st and the 2nd page of your document.")
  }

  /// Missing page
  public static var avbeamErrorIdPageMissingTitle: String {
    L10n.tr("Localizable", "avbeam_error_idPageMissing_title", fallback: "Missing page")
  }

  /// The image is blurry. Clean the camera lens and make sure the image is in focus. Then try again.
  public static var avbeamErrorImageBlurredContent: String {
    L10n.tr("Localizable", "avbeam_error_imageBlurred_content", fallback: "The image is blurry. Clean the camera lens and make sure the image is in focus. Then try again.")
  }

  /// Blurry image
  public static var avbeamErrorImageBlurredTitle: String {
    L10n.tr("Localizable", "avbeam_error_imageBlurred_title", fallback: "Blurry image")
  }

  /// Make sure your scans include the page with the document’s machine-readable zone (MRZ).
  public static var avbeamErrorMrzNotDetectedContent: String {
    L10n.tr("Localizable", "avbeam_error_mrzNotDetected_content", fallback: "Make sure your scans include the page with the document’s machine-readable zone (MRZ).")
  }

  /// No MRZ detected
  public static var avbeamErrorMrzNotDetectedTitle: String {
    L10n.tr("Localizable", "avbeam_error_mrzNotDetected_title", fallback: "No MRZ detected")
  }

  /// Reflections detected on the document. Turn off the camera flash, avoid direct light, and ensure the document is evenly lit before scanning again.
  public static var avbeamErrorReflectionContent: String {
    L10n.tr("Localizable", "avbeam_error_reflection_content", fallback: "Reflections detected on the document. Turn off the camera flash, avoid direct light, and ensure the document is evenly lit before scanning again.")
  }

  /// Reflections detected
  public static var avbeamErrorReflectionTitle: String {
    L10n.tr("Localizable", "avbeam_error_reflection_title", fallback: "Reflections detected")
  }

  /// Unfortunately, your device’s camera does not meet the technical requirements for applying for an e-ID.
  public static var avbeamErrorUnsupportedCameraResolutionContent: String {
    L10n.tr("Localizable", "avbeam_error_unsupportedCameraResolution_content", fallback: "Unfortunately, your device’s camera does not meet the technical requirements for applying for an e-ID.")
  }

  /// Camera not compatible
  public static var avbeamErrorUnsupportedCameraResolutionTitle: String {
    L10n.tr("Localizable", "avbeam_error_unsupportedCameraResolution_title", fallback: "Camera not compatible")
  }

  /// Unfortunately, your device’s video camera does not meet the technical requirements for applying for an e-ID.
  public static var avbeamErrorUnsupportedVideoConfigurationContent: String {
    L10n.tr("Localizable", "avbeam_error_unsupportedVideoConfiguration_content", fallback: "Unfortunately, your device’s video camera does not meet the technical requirements for applying for an e-ID.")
  }

  /// Video camera not compatible
  public static var avbeamErrorUnsupportedVideoConfigurationTitle: String {
    L10n.tr("Localizable", "avbeam_error_unsupportedVideoConfiguration_title", fallback: "Video camera not compatible")
  }

  /// Data decrypted.
  public static var avbeamNotificationDataDecrypted: String {
    L10n.tr("Localizable", "avbeam_notification_dataDecrypted", fallback: "Data decrypted.")
  }

  /// Please wait while the data is decrypted.
  public static var avbeamNotificationDataDecryptionStarted: String {
    L10n.tr("Localizable", "avbeam_notification_dataDecryptionStarted", fallback: "Please wait while the data is decrypted.")
  }

  /// Data encryption completed.
  public static var avbeamNotificationDataDecryptionStopped: String {
    L10n.tr("Localizable", "avbeam_notification_dataDecryptionStopped", fallback: "Data encryption completed.")
  }

  /// Data encrypted.
  public static var avbeamNotificationDataEncrypted: String {
    L10n.tr("Localizable", "avbeam_notification_dataEncrypted", fallback: "Data encrypted.")
  }

  /// Please wait while the data is encrypted.
  public static var avbeamNotificationDataEncryptionStarted: String {
    L10n.tr("Localizable", "avbeam_notification_dataEncryptionStarted", fallback: "Please wait while the data is encrypted.")
  }

  /// Data encryption completed.
  public static var avbeamNotificationDataEncryptionStopped: String {
    L10n.tr("Localizable", "avbeam_notification_dataEncryptionStopped", fallback: "Data encryption completed.")
  }

  /// Device integrity check failed. Please use a secure device.
  public static var avbeamNotificationDeviceIntegrityCheckFailed: String {
    L10n.tr("Localizable", "avbeam_notification_deviceIntegrityCheckFailed", fallback: "Device integrity check failed. Please use a secure device.")
  }

  /// Device integrity check successful.
  public static var avbeamNotificationDeviceIntegrityCheckSuccess: String {
    L10n.tr("Localizable", "avbeam_notification_deviceIntegrityCheckSuccess", fallback: "Device integrity check successful.")
  }

  /// Document captured.
  public static var avbeamNotificationDocCaptured: String {
    L10n.tr("Localizable", "avbeam_notification_docCaptured", fallback: "Document captured.")
  }

  /// Position the document within the frame.
  public static var avbeamNotificationDocCapturingStarted: String {
    L10n.tr("Localizable", "avbeam_notification_docCapturingStarted", fallback: "Position the document within the frame.")
  }

  /// Document capture completed.
  public static var avbeamNotificationDocCapturingStopped: String {
    L10n.tr("Localizable", "avbeam_notification_docCapturingStopped", fallback: "Document capture completed.")
  }

  /// Document recorded.
  public static var avbeamNotificationDocRecorded: String {
    L10n.tr("Localizable", "avbeam_notification_docRecorded", fallback: "Document recorded.")
  }

  /// Document recording started.
  public static var avbeamNotificationDocRecordingStarted: String {
    L10n.tr("Localizable", "avbeam_notification_docRecordingStarted", fallback: "Document recording started.")
  }

  /// Document recording stopped.
  public static var avbeamNotificationDocRecordingStopped: String {
    L10n.tr("Localizable", "avbeam_notification_docRecordingStopped", fallback: "Document recording stopped.")
  }

  /// Please blink naturally.
  public static var avbeamNotificationFaceCaptureBlink: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureBlink", fallback: "Please blink naturally.")
  }

  /// Face captured.
  public static var avbeamNotificationFaceCaptured: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptured", fallback: "Face captured.")
  }

  /// Liveness check failed. Please try again with natural movement.
  public static var avbeamNotificationFaceCaptureLivenessFailed: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureLivenessFailed", fallback: "Liveness check failed. Please try again with natural movement.")
  }

  /// Move your head slightly to the left.
  public static var avbeamNotificationFaceCaptureMoveLeft: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureMoveLeft", fallback: "Move your head slightly to the left.")
  }

  /// Move your head slightly to the right.
  public static var avbeamNotificationFaceCaptureMoveRight: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureMoveRight", fallback: "Move your head slightly to the right.")
  }

  /// Tilt your head slightly to the left.
  public static var avbeamNotificationFaceCaptureTiltLeft: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureTiltLeft", fallback: "Tilt your head slightly to the left.")
  }

  /// Tilt your head slightly to the right.
  public static var avbeamNotificationFaceCaptureTiltRight: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureTiltRight", fallback: "Tilt your head slightly to the right.")
  }

  /// Please look directly into the camera.
  public static var avbeamNotificationFaceCaptureTiltSmile: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureTiltSmile", fallback: "Please look directly into the camera.")
  }

  /// Hold your head position and wait.
  public static var avbeamNotificationFaceCaptureTiltWait: String {
    L10n.tr("Localizable", "avbeam_notification_faceCaptureTiltWait", fallback: "Hold your head position and wait.")
  }

  /// Position your face within the oval frame.
  public static var avbeamNotificationFaceCapturingStarted: String {
    L10n.tr("Localizable", "avbeam_notification_faceCapturingStarted", fallback: "Position your face within the oval frame.")
  }

  /// Face capture completed.
  public static var avbeamNotificationFaceCapturingStopped: String {
    L10n.tr("Localizable", "avbeam_notification_faceCapturingStopped", fallback: "Face capture completed.")
  }

  /// Face verification failed. Please try again with better lighting.
  public static var avbeamNotificationFaceVerificationFailed: String {
    L10n.tr("Localizable", "avbeam_notification_faceVerificationFailed", fallback: "Face verification failed. Please try again with better lighting.")
  }

  /// Look directly at the camera for verification.
  public static var avbeamNotificationFaceVerificationStarted: String {
    L10n.tr("Localizable", "avbeam_notification_faceVerificationStarted", fallback: "Look directly at the camera for verification.")
  }

  /// Face verification completed.
  public static var avbeamNotificationFaceVerificationStopped: String {
    L10n.tr("Localizable", "avbeam_notification_faceVerificationStopped", fallback: "Face verification completed.")
  }

  /// Face verified.
  public static var avbeamNotificationFaceVerified: String {
    L10n.tr("Localizable", "avbeam_notification_faceVerified", fallback: "Face verified.")
  }

  /// Position the document correctly within the frame.
  public static var avbeamNotificationIdBadPosition: String {
    L10n.tr("Localizable", "avbeam_notification_idBadPosition", fallback: "Position the document correctly within the frame.")
  }

  /// Document data ready for upload.
  public static var avbeamNotificationIdDataForUploadSet: String {
    L10n.tr("Localizable", "avbeam_notification_idDataForUploadSet", fallback: "Document data ready for upload.")
  }

  /// Document recognition completed.
  public static var avbeamNotificationIdDetectionDone: String {
    L10n.tr("Localizable", "avbeam_notification_idDetectionDone", fallback: "Document recognition completed.")
  }

  /// Document template detected.
  public static var avbeamNotificationIdDocMatched: String {
    L10n.tr("Localizable", "avbeam_notification_idDocMatched", fallback: "Document template detected.")
  }

  /// Make sure both sides of the document match.
  public static var avbeamNotificationIdDocNotMatched: String {
    L10n.tr("Localizable", "avbeam_notification_idDocNotMatched", fallback: "Make sure both sides of the document match.")
  }

  /// Final document dataset created.
  public static var avbeamNotificationIdFinalDataSet: String {
    L10n.tr("Localizable", "avbeam_notification_idFinalDataSet", fallback: "Final document dataset created.")
  }

  /// Please hold still.
  public static var avbeamNotificationIdHoldStill: String {
    L10n.tr("Localizable", "avbeam_notification_idHoldStill", fallback: "Please hold still.")
  }

  /// Hold your device closer to the document.
  public static var avbeamNotificationIdMoveCloser: String {
    L10n.tr("Localizable", "avbeam_notification_idMoveCloser", fallback: "Hold your device closer to the document.")
  }

  /// Hold your device farther away from the document.
  public static var avbeamNotificationIdMoveFurther: String {
    L10n.tr("Localizable", "avbeam_notification_idMoveFurther", fallback: "Hold your device farther away from the document.")
  }

  /// MRZ detected.
  public static var avbeamNotificationIdMrzFound: String {
    L10n.tr("Localizable", "avbeam_notification_idMrzFound", fallback: "MRZ detected.")
  }

  /// Make sure the MRZ area is visible and clear.
  public static var avbeamNotificationIdMrzNotFound: String {
    L10n.tr("Localizable", "avbeam_notification_idMrzNotFound", fallback: "Make sure the MRZ area is visible and clear.")
  }

  /// Keep the document on the same side.
  public static var avbeamNotificationIdNeedSamePageForMatching: String {
    L10n.tr("Localizable", "avbeam_notification_idNeedSamePageForMatching", fallback: "Keep the document on the same side.")
  }

  /// Keep the document on the same side to read the MRZ.
  public static var avbeamNotificationIdNeedSamePageForMrz: String {
    L10n.tr("Localizable", "avbeam_notification_idNeedSamePageForMrz", fallback: "Keep the document on the same side to read the MRZ.")
  }

  /// Turn the document to the other side.
  public static var avbeamNotificationIdNeedSecondPageForMatching: String {
    L10n.tr("Localizable", "avbeam_notification_idNeedSecondPageForMatching", fallback: "Turn the document to the other side.")
  }

  /// Turn the document to scan the back side.
  public static var avbeamNotificationIdNeedSecondPageForMrz: String {
    L10n.tr("Localizable", "avbeam_notification_idNeedSecondPageForMrz", fallback: "Turn the document to scan the back side.")
  }

  /// Additional security check required.
  public static var avbeamNotificationIdNeedSecurityFeatures: String {
    L10n.tr("Localizable", "avbeam_notification_idNeedSecurityFeatures", fallback: "Additional security check required.")
  }

  /// Make sure the document is clearly visible and well lit.
  public static var avbeamNotificationIdNotDetected: String {
    L10n.tr("Localizable", "avbeam_notification_idNotDetected", fallback: "Make sure the document is clearly visible and well lit.")
  }

  /// Position your document within the frame.
  public static var avbeamNotificationIdRecognitionStarted: String {
    L10n.tr("Localizable", "avbeam_notification_idRecognitionStarted", fallback: "Position your document within the frame.")
  }

  /// Document recognition completed.
  public static var avbeamNotificationIdRecognitionStopped: String {
    L10n.tr("Localizable", "avbeam_notification_idRecognitionStopped", fallback: "Document recognition completed.")
  }

  /// Avoid reflections by adjusting light or angle.
  public static var avbeamNotificationIdReflectionDetected: String {
    L10n.tr("Localizable", "avbeam_notification_idReflectionDetected", fallback: "Avoid reflections by adjusting light or angle.")
  }

  /// Rotate the document by 90 degrees.
  public static var avbeamNotificationIdRotate90: String {
    L10n.tr("Localizable", "avbeam_notification_idRotate90", fallback: "Rotate the document by 90 degrees.")
  }

  /// Rotate the document slightly to align it correctly.
  public static var avbeamNotificationIdRotateLess: String {
    L10n.tr("Localizable", "avbeam_notification_idRotateLess", fallback: "Rotate the document slightly to align it correctly.")
  }

  /// Rotate your device to match the document orientation.
  public static var avbeamNotificationIdRotateScreen: String {
    L10n.tr("Localizable", "avbeam_notification_idRotateScreen", fallback: "Rotate your device to match the document orientation.")
  }

  /// Rotate both your device and the document.
  public static var avbeamNotificationIdRotateScreenAndDoc: String {
    L10n.tr("Localizable", "avbeam_notification_idRotateScreenAndDoc", fallback: "Rotate both your device and the document.")
  }

  /// System initialized.
  public static var avbeamNotificationInitialized: String {
    L10n.tr("Localizable", "avbeam_notification_initialized", fallback: "System initialized.")
  }

  /// Messages deleted.
  public static var avbeamNotificationMessageClear: String {
    L10n.tr("Localizable", "avbeam_notification_messageClear", fallback: "Messages deleted.")
  }

  /// Accessing NFC security controls.
  public static var avbeamNotificationNfcAccessControl: String {
    L10n.tr("Localizable", "avbeam_notification_nfcAccessControl", fallback: "Accessing NFC security controls.")
  }

  /// Active authentication in progress.
  public static var avbeamNotificationNfcActiveAuthentication: String {
    L10n.tr("Localizable", "avbeam_notification_nfcActiveAuthentication", fallback: "Active authentication in progress.")
  }

  /// Authentication successful.
  public static var avbeamNotificationNfcAuthenticationPassDeprecated: String {
    L10n.tr("Localizable", "avbeam_notification_nfcAuthenticationPassDeprecated", fallback: "Authentication successful.")
  }

  /// Authenticating the NFC chip.
  public static var avbeamNotificationNfcChipAuthentication: String {
    L10n.tr("Localizable", "avbeam_notification_nfcChipAuthentication", fallback: "Authenticating the NFC chip.")
  }

  /// Chip authenticity verified.
  public static var avbeamNotificationNfcChipClonedDetectionEndSuccess: String {
    L10n.tr("Localizable", "avbeam_notification_nfcChipClonedDetectionEndSuccess", fallback: "Chip authenticity verified.")
  }

  /// Verifying chip authenticity.
  public static var avbeamNotificationNfcChipClonedDetectionStart: String {
    L10n.tr("Localizable", "avbeam_notification_nfcChipClonedDetectionStart", fallback: "Verifying chip authenticity.")
  }

  /// Connecting to verification server.
  public static var avbeamNotificationNfcConnectingToServer: String {
    L10n.tr("Localizable", "avbeam_notification_nfcConnectingToServer", fallback: "Connecting to verification server.")
  }

  /// NFC read failed. Try positioning your device differently.
  public static var avbeamNotificationNfcDataReadingEndFail: String {
    L10n.tr("Localizable", "avbeam_notification_nfcDataReadingEndFail", fallback: "NFC read failed. Try positioning your device differently.")
  }

  /// Data successfully read.
  public static var avbeamNotificationNfcDataReadingEndSuccess: String {
    L10n.tr("Localizable", "avbeam_notification_nfcDataReadingEndSuccess", fallback: "Data successfully read.")
  }

  /// Hold your device close to the document's NFC chip.
  public static var avbeamNotificationNfcDataReadingStart: String {
    L10n.tr("Localizable", "avbeam_notification_nfcDataReadingStart", fallback: "Hold your device close to the document's NFC chip.")
  }

  /// Passive authentication in progress.
  public static var avbeamNotificationNfcPassiveAuthentication: String {
    L10n.tr("Localizable", "avbeam_notification_nfcPassiveAuthentication", fallback: "Passive authentication in progress.")
  }

  /// NFC photo scan completed.
  public static var avbeamNotificationNfcPhotoReadingFinishDeprecated: String {
    L10n.tr("Localizable", "avbeam_notification_nfcPhotoReadingFinishDeprecated", fallback: "NFC photo scan completed.")
  }

  /// NFC photo scan started.
  public static var avbeamNotificationNfcPhotoReadingStartDeprecated: String {
    L10n.tr("Localizable", "avbeam_notification_nfcPhotoReadingStartDeprecated", fallback: "NFC photo scan started.")
  }

  /// Reading NFC chip information.
  public static var avbeamNotificationNfcReadAtrInfo: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadAtrInfo", fallback: "Reading NFC chip information.")
  }

  /// Reading document data group 1.
  public static var avbeamNotificationNfcReadDg1: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadDg1", fallback: "Reading document data group 1.")
  }

  /// Reading additional personal data.
  public static var avbeamNotificationNfcReadDg11: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadDg11", fallback: "Reading additional personal data.")
  }

  /// Reading additional document data.
  public static var avbeamNotificationNfcReadDg12: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadDg12", fallback: "Reading additional document data.")
  }

  /// Reading security features.
  public static var avbeamNotificationNfcReadDg14: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadDg14", fallback: "Reading security features.")
  }

  /// Reading active authentication data.
  public static var avbeamNotificationNfcReadDg15: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadDg15", fallback: "Reading active authentication data.")
  }

  /// Reading biometric data.
  public static var avbeamNotificationNfcReadDg2: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadDg2", fallback: "Reading biometric data.")
  }

  /// Reading signature data.
  public static var avbeamNotificationNfcReadDg7: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadDg7", fallback: "Reading signature data.")
  }

  /// NFC reading completed.
  public static var avbeamNotificationNfcReadingStopped: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadingStopped", fallback: "NFC reading completed.")
  }

  /// Reading security object data.
  public static var avbeamNotificationNfcReadSod: String {
    L10n.tr("Localizable", "avbeam_notification_nfcReadSod", fallback: "Reading security object data.")
  }

  /// NFC is not available on this device.
  public static var avbeamNotificationNfcUnavailable: String {
    L10n.tr("Localizable", "avbeam_notification_nfcUnavailable", fallback: "NFC is not available on this device.")
  }

  /// QR code captured.
  public static var avbeamNotificationQrCodeCaptured: String {
    L10n.tr("Localizable", "avbeam_notification_qrCodeCaptured", fallback: "QR code captured.")
  }

  /// QR code extraction complete.
  public static var avbeamNotificationQrCodeExtractionDone: String {
    L10n.tr("Localizable", "avbeam_notification_qrCodeExtractionDone", fallback: "QR code extraction complete.")
  }

  /// Hold your device closer to the QR code.
  public static var avbeamNotificationQrCodeMoveCloser: String {
    L10n.tr("Localizable", "avbeam_notification_qrCodeMoveCloser", fallback: "Hold your device closer to the QR code.")
  }

  /// Hold your device farther away from the QR code.
  public static var avbeamNotificationQrCodeMoveFurther: String {
    L10n.tr("Localizable", "avbeam_notification_qrCodeMoveFurther", fallback: "Hold your device farther away from the QR code.")
  }

  /// Point your camera at the QR code.
  public static var avbeamNotificationQrCodeRecognitionStarted: String {
    L10n.tr("Localizable", "avbeam_notification_qrCodeRecognitionStarted", fallback: "Point your camera at the QR code.")
  }

  /// QR code recognition stopped.
  public static var avbeamNotificationQrCodeRecognitionStopped: String {
    L10n.tr("Localizable", "avbeam_notification_qrCodeRecognitionStopped", fallback: "QR code recognition stopped.")
  }

  /// Security features ready.
  public static var avbeamNotificationSecurityFeaturesReady: String {
    L10n.tr("Localizable", "avbeam_notification_securityFeaturesReady", fallback: "Security features ready.")
  }

  /// Security check in progress.
  public static var avbeamNotificationSecurityFeaturesStarted: String {
    L10n.tr("Localizable", "avbeam_notification_securityFeaturesStarted", fallback: "Security check in progress.")
  }

  /// Security check completed.
  public static var avbeamNotificationSecurityFeaturesStopped: String {
    L10n.tr("Localizable", "avbeam_notification_securityFeaturesStopped", fallback: "Security check completed.")
  }

  /// Keep the document steady during the security check.
  public static var avbeamNotificationSecurityFeaturesTracking: String {
    L10n.tr("Localizable", "avbeam_notification_securityFeaturesTracking", fallback: "Keep the document steady during the security check.")
  }

  /// Security tracking lost. Please realign the document.
  public static var avbeamNotificationSecurityFeaturesTrackingLost: String {
    L10n.tr("Localizable", "avbeam_notification_securityFeaturesTrackingLost", fallback: "Security tracking lost. Please realign the document.")
  }

  /// Signature accepted.
  public static var avbeamNotificationSignatureAccepted: String {
    L10n.tr("Localizable", "avbeam_notification_signatureAccepted", fallback: "Signature accepted.")
  }

  /// Please sign again.
  public static var avbeamNotificationSignatureCleared: String {
    L10n.tr("Localizable", "avbeam_notification_signatureCleared", fallback: "Please sign again.")
  }

  /// Continue signing within the designated area.
  public static var avbeamNotificationSignatureDrawingStarted: String {
    L10n.tr("Localizable", "avbeam_notification_signatureDrawingStarted", fallback: "Continue signing within the designated area.")
  }

  /// Sign in the designated area.
  public static var avbeamNotificationSignatureStarted: String {
    L10n.tr("Localizable", "avbeam_notification_signatureStarted", fallback: "Sign in the designated area.")
  }

  /// Signature capture completed.
  public static var avbeamNotificationSignatureStopped: String {
    L10n.tr("Localizable", "avbeam_notification_signatureStopped", fallback: "Signature capture completed.")
  }

  /// Camera transmission started.
  public static var avbeamNotificationStreamingStarted: String {
    L10n.tr("Localizable", "avbeam_notification_streamingStarted", fallback: "Camera transmission started.")
  }

  /// Please wait while the visual zone is processed.
  public static var avbeamNotificationWaitingForViz: String {
    L10n.tr("Localizable", "avbeam_notification_waitingForViz", fallback: "Please wait while the visual zone is processed.")
  }

  /// Face ID
  public static var biometricSetupFaceidText: String {
    L10n.tr("Localizable", "biometricSetup_faceid_text", fallback: "Face ID")
  }

  /// Activate biometrics
  public static var biometricSetupNoClass3ToSettingsButton: String {
    L10n.tr("Localizable", "biometricSetup_noClass3_toSettingsButton", fallback: "Activate biometrics")
  }

  /// You can still log in with your pin, if biometrics are not working
  public static var biometricSetupReason: String {
    L10n.tr("Localizable", "biometricSetup_reason", fallback: "You can still log in with your pin, if biometrics are not working")
  }

  /// TouchID
  public static var biometricSetupTouchidText: String {
    L10n.tr("Localizable", "biometricSetup_touchid_text", fallback: "TouchID")
  }

  /// Refuse
  public static var credentialOfferRefuseButton: String {
    L10n.tr("Localizable", "credential_offer_refuseButton", fallback: "Refuse")
  }

  /// No data found…
  public static var emptyStateEmptyTitle: String {
    L10n.tr("Localizable", "emptyState_emptyTitle", fallback: "No data found…")
  }

  /// Oops, something went wrong…
  public static var emptyStateErrorTitle: String {
    L10n.tr("Localizable", "emptyState_errorTitle", fallback: "Oops, something went wrong…")
  }

  /// Your internet connection seems off, take a moment to check what's wrong and retry
  public static var emptyStateOfflineMessage: String {
    L10n.tr("Localizable", "emptyState_offlineMessage", fallback: "Your internet connection seems off, take a moment to check what's wrong and retry")
  }

  /// Missing internet connection
  public static var emptyStateOfflineTitle: String {
    L10n.tr("Localizable", "emptyState_offlineTitle", fallback: "Missing internet connection")
  }

  /// Back
  public static var globalBack: String {
    L10n.tr("Localizable", "global_back", fallback: "Back")
  }

  /// Cancel
  public static var globalCancel: String {
    L10n.tr("Localizable", "global_cancel", fallback: "Cancel")
  }

  /// Continue
  public static var onboardingContinue: String {
    L10n.tr("Localizable", "onboarding_continue", fallback: "Continue")
  }

  /// Your settings will be applied, which can take up to 30 seconds.
  public static var storageSetupText: String {
    L10n.tr("Localizable", "storageSetup_text", fallback: "Your settings will be applied, which can take up to 30 seconds.")
  }

  /// Applying settings
  public static var storageSetupTitle: String {
    L10n.tr("Localizable", "storageSetup_title", fallback: "Applying settings")
  }

  /// Shared data
  public static var tkAccessibilityInformationAbout: String {
    L10n.tr("Localizable", "tk_accessibility_information_about", fallback: "Shared data")
  }

  /// The state of the credential reflects the time when the activity occurred and might have changed since then.
  public static var tkActivityActivityDetailCredentialFooter: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_credential_footer", fallback: "The state of the credential reflects the time when the activity occurred and might have changed since then.")
  }

  /// Shared Data
  public static var tkActivityActivityDetailCredentialInfoTitleVerification: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_credential_info_title_verification", fallback: "Shared Data")
  }

  /// Credential
  public static var tkActivityActivityDetailCredentialTitle: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_credential_title", fallback: "Credential")
  }

  /// You won’t be able to restore or report this activity anymore.
  public static var tkActivityActivityDetailDeleteConfirmationBody: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_deleteConfirmation_body", fallback: "You won’t be able to restore or report this activity anymore.")
  }

  /// Delete entry?
  public static var tkActivityActivityDetailDeleteConfirmationTitle: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_deleteConfirmation_title", fallback: "Delete entry?")
  }

  /// Delete entry
  public static var tkActivityActivityDetailDeleteEntryButton: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_deleteEntry_button", fallback: "Delete entry")
  }

  /// Issuer
  public static var tkActivityActivityDetailIssuerTitle: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_issuer_title", fallback: "Issuer")
  }

  /// Report Issuer
  public static var tkActivityActivityDetailReportIssuerButton: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_reportIssuer_button", fallback: "Report Issuer")
  }

  /// Report Verifier
  public static var tkActivityActivityDetailReportVerifierButton: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_reportVerifier_button", fallback: "Report Verifier")
  }

  /// Activity Detail
  public static var tkActivityActivityDetailTitle: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_title", fallback: "Activity Detail")
  }

  /// The trust status of the issuer reflects the time when the activity occurred and might have changed since then.
  public static var tkActivityActivityDetailTrustInfoFooterIssuer: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_trust_info_footer_issuer", fallback: "The trust status of the issuer reflects the time when the activity occurred and might have changed since then.")
  }

  /// The trust status of the verifier reflects the time when the activity occurred and might have changed since then.
  public static var tkActivityActivityDetailTrustInfoFooterVerifier: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_trust_info_footer_verifier", fallback: "The trust status of the verifier reflects the time when the activity occurred and might have changed since then.")
  }

  /// Verifier
  public static var tkActivityActivityDetailVerifierTitle: String {
    L10n.tr("Localizable", "tk_activity_activityDetail_verifier_title", fallback: "Verifier")
  }

  /// Activity deleted
  public static var tkActivityActivityListEntryDeletedTitle: String {
    L10n.tr("Localizable", "tk_activity_activityList_entryDeleted_title", fallback: "Activity deleted")
  }

  /// Report successfully transmitted
  public static var tkActivityActivityListNonComplianceReportSentTitle: String {
    L10n.tr("Localizable", "tk_activity_activityList_nonCompliance_reportSent_title", fallback: "Report successfully transmitted")
  }

  /// History
  public static var tkActivityActivityListTitle: String {
    L10n.tr("Localizable", "tk_activity_activityList_title", fallback: "History")
  }

  /// Credential Issued
  public static var tkActivityCredentialAcceptedTitle: String {
    L10n.tr("Localizable", "tk_activity_credentialAccepted_title", fallback: "Credential Issued")
  }

  /// The history of your activities is turned off. To keep track of your activities edit it in the main settings.
  public static var tkActivityLatestActivitiesDisabledHistoryBody: String {
    L10n.tr("Localizable", "tk_activity_latestActivities_disabledHistory_body", fallback: "The history of your activities is turned off. To keep track of your activities edit it in the main settings.")
  }

  /// Entire Credential History
  public static var tkActivityLatestActivitiesEntireHistory: String {
    L10n.tr("Localizable", "tk_activity_latestActivities_entireHistory", fallback: "Entire Credential History")
  }

  /// Edit history settings
  public static var tkActivityLatestActivitiesGoToSettings: String {
    L10n.tr("Localizable", "tk_activity_latestActivities_goToSettings", fallback: "Edit history settings")
  }

  /// You’ll see your history here once credentials activities have been made.
  public static var tkActivityLatestActivitiesNoHistoryBody: String {
    L10n.tr("Localizable", "tk_activity_latestActivities_noHistory_body", fallback: "You’ll see your history here once credentials activities have been made.")
  }

  /// No History available
  public static var tkActivityLatestActivitiesNoHistoryTitle: String {
    L10n.tr("Localizable", "tk_activity_latestActivities_noHistory_title", fallback: "No History available")
  }

  /// Latest Activities
  public static var tkActivityLatestActivitiesTitle: String {
    L10n.tr("Localizable", "tk_activity_latestActivities_title", fallback: "Latest Activities")
  }

  /// Information Shared
  public static var tkActivityPresentationAcceptedTitle: String {
    L10n.tr("Localizable", "tk_activity_presentationAccepted_title", fallback: "Information Shared")
  }

  /// Declined
  public static var tkActivityPresentationDeclinedTitle: String {
    L10n.tr("Localizable", "tk_activity_presentationDeclined_title", fallback: "Declined")
  }

  /// Warning
  public static var tkActorNonCompliant: String {
    L10n.tr("Localizable", "tk_actor_nonCompliant", fallback: "Warning")
  }

  /// This actor has been reported
  public static var tkActorNonCompliantButton: String {
    L10n.tr("Localizable", "tk_actor_nonCompliant_button", fallback: "This actor has been reported")
  }

  /// Further information
  public static var tkBadgeInformationFurtherInformationLinkText: String {
    L10n.tr("Localizable", "tk_badgeInformation_furtherInformation_link_text", fallback: "Further information")
  }

  /// https://www.eid.admin.ch/en/swiyu-informs-signals-and-alerts
  public static var tkBadgeInformationFurtherInformationLinkValue: String {
    L10n.tr("Localizable", "tk_badgeInformation_furtherInformation_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-informs-signals-and-alerts")
  }

  /// Reasoning:
  public static var tkBadgeInformationNonCompliantSecondary: String {
    L10n.tr("Localizable", "tk_badgeInformation_nonCompliant_secondary", fallback: "Reasoning: ")
  }

  /// Data requested
  public static var tkBadgeInformationNonSensitiveClaimInfoPrimary: String {
    L10n.tr("Localizable", "tk_badgeInformation_nonSensitiveClaimInfo_primary", fallback: "Data requested")
  }

  /// Data has been requested from you. Decline the transaction if you do not wish to share this information.
  public static var tkBadgeInformationNonSensitiveClaimInfoSecondary: String {
    L10n.tr("Localizable", "tk_badgeInformation_nonSensitiveClaimInfo_secondary", fallback: "Data has been requested from you. Decline the transaction if you do not wish to share this information.")
  }

  /// The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.
  public static var tkBadgeInformationNotTrustedCheckAppHint: String {
    L10n.tr("Localizable", "tk_badgeInformation_notTrustedCheckApp_hint", fallback: "The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.")
  }

  /// This actor is using an untrusted proximity verifier app.
  public static var tkBadgeInformationNotTrustedCheckAppPrimary: String {
    L10n.tr("Localizable", "tk_badgeInformation_notTrustedCheckApp_primary", fallback: "This actor is using an untrusted proximity verifier app.")
  }

  /// Only share your data if you trust this actor. If you believe too much data is being requested, you may file a report.
  public static var tkBadgeInformationNotTrustedCheckAppSecondary: String {
    L10n.tr("Localizable", "tk_badgeInformation_notTrustedCheckApp_secondary", fallback: "Only share your data if you trust this actor. If you believe too much data is being requested, you may file a report. ")
  }

  /// Sensitive data requested
  public static var tkBadgeInformationSensitiveClaimInfoPrimary: String {
    L10n.tr("Localizable", "tk_badgeInformation_sensitiveClaimInfo_primary", fallback: "Sensitive data requested")
  }

  /// Sensitive data has been requested from you. Reject the transaction if you do not want to share this information.
  public static var tkBadgeInformationSensitiveClaimInfoSecondary: String {
    L10n.tr("Localizable", "tk_badgeInformation_sensitiveClaimInfo_secondary", fallback: "Sensitive data has been requested from you. Reject the transaction if you do not want to share this information.")
  }

  /// The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.
  public static var tkBadgeInformationTrustedCheckAppHint: String {
    L10n.tr("Localizable", "tk_badgeInformation_trustedCheckApp_hint", fallback: "The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.")
  }

  /// This actor is using the official swiyu Check app to verify your identity.
  public static var tkBadgeInformationTrustedCheckAppPrimary: String {
    L10n.tr("Localizable", "tk_badgeInformation_trustedCheckApp_primary", fallback: "This actor is using the official swiyu Check app to verify your identity.")
  }

  /// Only share your data if you trust this actor. If you believe too much data is being requested, you may file a report.
  public static var tkBadgeInformationTrustedCheckAppSecondary: String {
    L10n.tr("Localizable", "tk_badgeInformation_trustedCheckApp_secondary", fallback: "Only share your data if you trust this actor. If you believe too much data is being requested, you may file a report. ")
  }

  /// Incorrect password entered too many times. Please set a new password.
  public static var tkChangepasswordError4Notification: String {
    L10n.tr("Localizable", "tk_changepassword_error4_notification", fallback: "Incorrect password entered too many times. Please set a new password.\t")
  }

  /// Current password
  public static var tkChangepasswordStep1Note1: String {
    L10n.tr("Localizable", "tk_changepassword_step1_note1", fallback: "Current password")
  }

  /// Confirm new password
  public static var tkChangepasswordStep3Note1: String {
    L10n.tr("Localizable", "tk_changepassword_step3_note1", fallback: "Confirm new password")
  }

  /// Password successfully changed
  public static var tkChangepasswordSuccessfulNotification: String {
    L10n.tr("Localizable", "tk_changepassword_successful_notification", fallback: "Password successfully changed")
  }

  /// Credential
  public static var tkCredentialFallbackTitle: String {
    L10n.tr("Localizable", "tk_credential_fallback_title", fallback: "Credential")
  }

  /// Available credentials
  public static var tkCredentialIssuanceTypeAvailableCredentialsKey: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_availableCredentials_key", fallback: "Available credentials")
  }

  /// Batch
  public static var tkCredentialIssuanceTypeBatch: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_batch", fallback: "Batch")
  }

  /// This credential was issued as part of a batch.
  ///
  /// Each time it is presented, a new individual credential from the batch is used.
  ///
  /// This technical separation of individual uses provides additional privacy.
  public static var tkCredentialIssuanceTypeBatchBody: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_batch_body", fallback: "This credential was issued as part of a batch.\n\nEach time it is presented, a new individual credential from the batch is used.\n\nThis technical separation of individual uses provides additional privacy.")
  }

  /// Batch issuance
  public static var tkCredentialIssuanceTypeBatchTitle: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_batch_title", fallback: "Batch issuance")
  }

  /// Last updated
  public static var tkCredentialIssuanceTypeLastRefreshKey: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_lastRefresh_key", fallback: "Last updated")
  }

  /// Learn more
  public static var tkCredentialIssuanceTypeMoreInformation: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_moreInformation", fallback: "Learn more")
  }

  /// https://www.eid.admin.ch/
  public static var tkCredentialIssuanceTypeMoreInformationLinkValue: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_moreInformation_link_value", fallback: "https://www.eid.admin.ch/")
  }

  /// Standard
  public static var tkCredentialIssuanceTypeSingle: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_single", fallback: "Standard")
  }

  /// This credential was issued as a single credential.
  /// Each time it is presented, the same credential is used and optimized for its intended purpose.
  /// Usage complies with applicable data protection requirements.
  public static var tkCredentialIssuanceTypeSingleBody: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_single_body", fallback: "This credential was issued as a single credential.\nEach time it is presented, the same credential is used and optimized for its intended purpose.\nUsage complies with applicable data protection requirements.")
  }

  /// Standard issuance
  public static var tkCredentialIssuanceTypeSingleTitle: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_single_title", fallback: "Standard issuance")
  }

  /// Issuance type
  public static var tkCredentialIssuanceTypeTitle: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_title", fallback: "Issuance type")
  }

  /// Usage details
  public static var tkCredentialIssuanceTypeUsageDetailsTitle: String {
    L10n.tr("Localizable", "tk_credential_issuanceType_usageDetails_title", fallback: "Usage details")
  }

  /// Ready to add
  public static var tkCredentialProgressionStateUnaccepted: String {
    L10n.tr("Localizable", "tk_credential_progressionState_unaccepted", fallback: "Ready to add")
  }

  /// Demo
  public static var tkCredentialStatusDemo: String {
    L10n.tr("Localizable", "tk_credential_status_demo", fallback: "Demo")
  }

  /// Credential demo
  public static var tkCredentialStatusDemoAlt: String {
    L10n.tr("Localizable", "tk_credential_status_demo_alt", fallback: "Credential demo")
  }

  /// Expired
  public static var tkCredentialStatusInvalid: String {
    L10n.tr("Localizable", "tk_credential_status_invalid", fallback: "Expired")
  }

  /// Credential expired
  public static var tkCredentialStatusInvalidAlt: String {
    L10n.tr("Localizable", "tk_credential_status_invalid_alt", fallback: "Credential expired")
  }

  /// Revoked
  public static var tkCredentialStatusRevoked: String {
    L10n.tr("Localizable", "tk_credential_status_revoked", fallback: "Revoked")
  }

  /// Credential revoked
  public static var tkCredentialStatusRevokedAlt: String {
    L10n.tr("Localizable", "tk_credential_status_revoked_alt", fallback: "Credential revoked")
  }

  /// Valid soon
  public static var tkCredentialStatusSoon: String {
    L10n.tr("Localizable", "tk_credential_status_soon", fallback: "Valid soon")
  }

  /// Credential available soon
  public static var tkCredentialStatusSoonAlt: String {
    L10n.tr("Localizable", "tk_credential_status_soon_alt", fallback: "Credential available soon")
  }

  /// Currently blocked
  public static var tkCredentialStatusSuspended: String {
    L10n.tr("Localizable", "tk_credential_status_suspended", fallback: "Currently blocked")
  }

  /// Credential temporarily locked.
  public static var tkCredentialStatusSuspendedAlt: String {
    L10n.tr("Localizable", "tk_credential_status_suspended_alt", fallback: "Credential temporarily locked.")
  }

  /// Unknown
  public static var tkCredentialStatusUnknown: String {
    L10n.tr("Localizable", "tk_credential_status_unknown", fallback: "Unknown")
  }

  /// Validity status unknown
  public static var tkCredentialStatusUnknownAlt: String {
    L10n.tr("Localizable", "tk_credential_status_unknown_alt", fallback: "Validity status unknown")
  }

  /// Valid
  public static var tkCredentialStatusValid: String {
    L10n.tr("Localizable", "tk_credential_status_valid", fallback: "Valid")
  }

  /// Credential valid
  public static var tkCredentialStatusValidAlt: String {
    L10n.tr("Localizable", "tk_credential_status_valid_alt", fallback: "Credential valid")
  }

  /// Credential request rejected
  public static var tkCredentialOfferErrorCredentialRequestDeniedDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_credentialRequestDenied_description", fallback: "Credential request rejected")
  }

  /// Insufficient scope
  public static var tkCredentialOfferErrorInsufficientScopeDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_insufficientScope_description", fallback: "Insufficient scope")
  }

  /// Invalid client
  public static var tkCredentialOfferErrorInvalidClientDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidClient_description", fallback: "Invalid client")
  }

  /// Invalid credential request
  public static var tkCredentialOfferErrorInvalidCredentialRequestDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidCredentialRequest_description", fallback: "Invalid credential request")
  }

  /// Invalid encryption parameter
  public static var tkCredentialOfferErrorInvalidEncryptionParametersDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidEncryptionParameters_description", fallback: "Invalid encryption parameter")
  }

  /// Invalid grant
  public static var tkCredentialOfferErrorInvalidGrantDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidGrant_description", fallback: "Invalid grant")
  }

  /// Invalid nonce
  public static var tkCredentialOfferErrorInvalidNonceDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidNonce_description", fallback: "Invalid nonce")
  }

  /// Invalid proof
  public static var tkCredentialOfferErrorInvalidProofDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidProof_description", fallback: "Invalid proof")
  }

  /// Invalid request
  public static var tkCredentialOfferErrorInvalidRequestDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidRequest_description", fallback: "Invalid request")
  }

  /// Invalid scope
  public static var tkCredentialOfferErrorInvalidScopeDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidScope_description", fallback: "Invalid scope")
  }

  /// Invalid token
  public static var tkCredentialOfferErrorInvalidTokenDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidToken_description", fallback: "Invalid token")
  }

  /// Invalid transaction ID
  public static var tkCredentialOfferErrorInvalidTransactionIdDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_invalidTransactionId_description", fallback: "Invalid transaction ID")
  }

  /// Something went wrong
  public static var tkCredentialOfferErrorPrimary: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_primary", fallback: "Something went wrong")
  }

  /// We are currently unable to complete your request. This may be due to a temporary connection or system issue.
  public static var tkCredentialOfferErrorSecondary: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_secondary", fallback: "We are currently unable to complete your request. This may be due to a temporary connection or system issue.")
  }

  /// Unauthorized client
  public static var tkCredentialOfferErrorUnauthorizedClientDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_unauthorizedClient_description", fallback: "Unauthorized client")
  }

  /// Unknown credential configuration
  public static var tkCredentialOfferErrorUnknownCredentialConfigurationDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_unknownCredentialConfiguration_description", fallback: "Unknown credential configuration")
  }

  /// Unknown credential identifier
  public static var tkCredentialOfferErrorUnknownCredentialIdentifierDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_unknownCredentialIdentifier_description", fallback: "Unknown credential identifier")
  }

  /// Unsupported grant type
  public static var tkCredentialOfferErrorUnsupportedGrantTypeDescription: String {
    L10n.tr("Localizable", "tk_credentialOffer_error_unsupportedGrantType_description", fallback: "Unsupported grant type")
  }

  /// In progress
  public static var tkDeferredCredentialStatusInProgress: String {
    L10n.tr("Localizable", "tk_deferredCredential_status_inProgress", fallback: "In progress")
  }

  /// Rejected
  public static var tkDeferredCredentialStatusInvalid: String {
    L10n.tr("Localizable", "tk_deferredCredential_status_invalid", fallback: "Rejected")
  }

  /// Issuance failed
  public static var tkDeferredCredentialStatusIssuanceFailed: String {
    L10n.tr("Localizable", "tk_deferredCredential_status_issuanceFailed", fallback: "Issuance failed")
  }

  /// This credential is still being processed. Once it is ready, you can activate and use it.
  public static var tkDeferredCredentialDetailsInProgressContentBody: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_inProgress_contentBody", fallback: "This credential is still being processed. Once it is ready, you can activate and use it.")
  }

  /// What do you need to do?
  public static var tkDeferredCredentialDetailsInProgressContentTitle: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_inProgress_contentTitle", fallback: "What do you need to do?")
  }

  /// Delete credential
  public static var tkDeferredCredentialDetailsInvalidButton: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_invalid_button", fallback: "Delete credential")
  }

  /// An error occurred during the issuance of the credential. Please contact the issuer. This credential will remain until you delete it.
  public static var tkDeferredCredentialDetailsInvalidContentBody: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_invalid_contentBody", fallback: "An error occurred during the issuance of the credential. Please contact the issuer. This credential will remain until you delete it.")
  }

  /// The existing credential remains visible until you delete it.
  public static var tkDeferredCredentialDetailsInvalidContentBody2: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_invalid_contentBody2", fallback: "The existing credential remains visible until you delete it.")
  }

  /// Why is the credential invalid?
  public static var tkDeferredCredentialDetailsInvalidContentTitle: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_invalid_contentTitle", fallback: "Why is the credential invalid?")
  }

  /// What happens to this credential?
  public static var tkDeferredCredentialDetailsInvalidContentTitle2: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_invalid_contentTitle2", fallback: "What happens to this credential?")
  }

  /// There was an error with the issuing of the credential. Please contact the issuer. This credential will remain in place until you delete it.
  public static var tkDeferredCredentialDetailsIssuanceFailedContentBody: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_issuanceFailed_contentBody", fallback: "There was an error with the issuing of the credential. Please contact the issuer. This credential will remain in place until you delete it.")
  }

  /// What do you need to do?
  public static var tkDeferredCredentialDetailsIssuanceFailedContentTitle: String {
    L10n.tr("Localizable", "tk_deferredCredentialDetails_issuanceFailed_contentTitle", fallback: "What do you need to do?")
  }

  /// Your activities could be linked to this credential. Update it to better protect your privacy.
  public static var tkDisplaybatchPrivacyWarningBody: String {
    L10n.tr("Localizable", "tk_displaybatchPrivacyWarning_body", fallback: "Your activities could be linked to this credential. Update it to better protect your privacy.")
  }

  /// Update credential
  public static var tkDisplaybatchPrivacyWarningButton: String {
    L10n.tr("Localizable", "tk_displaybatchPrivacyWarning_button", fallback: "Update credential")
  }

  /// Your privacy protection is limited.
  public static var tkDisplaybatchPrivacyWarningTitle: String {
    L10n.tr("Localizable", "tk_displaybatchPrivacyWarning_title", fallback: "Your privacy protection is limited.")
  }

  /// This credential, along with all associated data, will be completely deleted from this device.
  public static var tkDisplaydeleteCredentialdeleteBody: String {
    L10n.tr("Localizable", "tk_displaydelete_credentialdelete_body", fallback: "This credential, along with all associated data, will be completely deleted from this device.")
  }

  /// Delete credential?
  public static var tkDisplaydeleteCredentialdeleteTitle: String {
    L10n.tr("Localizable", "tk_displaydelete_credentialdelete_title", fallback: "Delete credential?")
  }

  /// Delete credential
  public static var tkDisplaydeleteCredentialmenuPrimarybutton: String {
    L10n.tr("Localizable", "tk_displaydelete_credentialmenu_primarybutton", fallback: "Delete credential")
  }

  /// Issued by
  public static var tkDisplaydeleteDisplaycredential1Title5: String {
    L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title5", fallback: "Issued by")
  }

  /// Once issued, a credential cannot be changed.
  ///
  /// If you notice an error in your data, please contact the issuer.
  /// They can issue a new, corrected credential.
  public static var tkDisplaydeleteWrongdataBody: String {
    L10n.tr("Localizable", "tk_displaydelete_wrongdata_body", fallback: "Once issued, a credential cannot be changed.\n\nIf you notice an error in your data, please contact the issuer.\nThey can issue a new, corrected credential.")
  }

  /// Found any incorrect data?
  public static var tkDisplaydeleteWrongdataNavigationTitle: String {
    L10n.tr("Localizable", "tk_displaydelete_wrongdata_navigation_title", fallback: "Found any incorrect data?")
  }

  /// Report incorrect details
  public static var tkDisplaydeleteWrongdataTitle: String {
    L10n.tr("Localizable", "tk_displaydelete_wrongdata_title", fallback: "Report incorrect details")
  }

  /// This credential cannot be updated manually. If you notice incorrect or outdated data, please contact the issuer.
  public static var tkDisplayrefreshBody: String {
    L10n.tr("Localizable", "tk_displayrefresh_body", fallback: "This credential cannot be updated manually. If you notice incorrect or outdated data, please contact the issuer.")
  }

  /// Update now
  public static var tkDisplayrefreshButtonPrimarybutton: String {
    L10n.tr("Localizable", "tk_displayrefresh_button_primarybutton", fallback: "Update now")
  }

  /// Updating credential
  public static var tkDisplayrefreshLoadingTitle: String {
    L10n.tr("Localizable", "tk_displayrefresh_loading_title", fallback: "Updating credential")
  }

  /// Update credential
  public static var tkDisplayrefreshMenuPrimarybutton: String {
    L10n.tr("Localizable", "tk_displayrefresh_menu_primarybutton", fallback: "Update credential")
  }

  /// Credential successfully updated.
  public static var tkDisplayrefreshNotificationSuccess: String {
    L10n.tr("Localizable", "tk_displayrefresh_notification_success", fallback: "Credential successfully updated.")
  }

  /// Update credential
  public static var tkDisplayrefreshTitle: String {
    L10n.tr("Localizable", "tk_displayrefresh_title", fallback: "Update credential")
  }

  /// This credential cannot be updated manually.
  ///
  /// If you notice incorrect or outdated data, please contact the issuer.
  public static var tkDisplayrefreshUnavailableBody: String {
    L10n.tr("Localizable", "tk_displayrefresh_unavailable_body", fallback: "This credential cannot be updated manually.\n\nIf you notice incorrect or outdated data, please contact the issuer.")
  }

  /// Your identity is now being verified
  public static var tkEidRequestAgentReviewPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_agentReview_primary", fallback: "Your identity is now being verified")
  }

  /// The identity verification may take several business days. You will be notified once it is completed.
  public static var tkEidRequestAgentReviewSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_agentReview_secondary", fallback: "The identity verification may take several business days. You will be notified once it is completed.")
  }

  /// Just a moment - Verifying compatibility
  public static var tkEidRequestAttestationPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_attestation_primary", fallback: "Just a moment - Verifying compatibility")
  }

  /// We are checking whether your device meets the security requirements.
  public static var tkEidRequestAttestationSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_attestation_secondary", fallback: "We are checking whether your device meets the security requirements.")
  }

  /// Something went wrong.
  public static var tkEidRequestAttestationUnknownErrorPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_primary", fallback: "Something went wrong.")
  }

  /// Try again
  public static var tkEidRequestAttestationUnknownErrorPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_primary_button", fallback: "Try again")
  }

  /// Please try again.
  public static var tkEidRequestAttestationUnknownErrorSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_secondary", fallback: "Please try again.")
  }

  /// Cancel
  public static var tkEidRequestAttestationUnknownErrorSecondaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_secondary_button", fallback: "Cancel")
  }

  /// Start
  public static var tkEidRequestAutoVerificationIdentityCheckButton: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_button", fallback: "Start")
  }

  /// Identity verification
  public static var tkEidRequestAutoVerificationIdentityCheckPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_primary", fallback: "Identity verification")
  }

  /// Please have the same identity document ready as used for your e-ID application.
  /// Your identity will be verified using a face capture.
  public static var tkEidRequestAutoVerificationIdentityCheckSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_secondary", fallback: "Please have the same identity document ready as used for your e-ID application.\nYour identity will be verified using a face capture.")
  }

  /// Please do not cancel the process, otherwise all the information will be lost.
  public static var tkEidRequestAutoVerificationIdentityCheckTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_tertiary", fallback: "Please do not cancel the process, otherwise all the information will be lost.")
  }

  /// Tip
  public static var tkEidRequestAutoVerificationIdentityCheckTertiaryTip: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_tertiary_tip", fallback: "Tip")
  }

  /// Video recording to confirm your identity
  public static var tkEidRequestAutoVerificationIntroSelfieVideoPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationIntroSelfieVideo_primary", fallback: "Video recording to confirm your identity")
  }

  /// • Stand in front of a neutral background
  /// • Tap “Record” and look into the camera
  /// • Move your head slightly
  /// • Ensure good lighting and a clearly visible face
  public static var tkEidRequestAutoVerificationIntroSelfieVideoSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationIntroSelfieVideo_secondary", fallback: "• Stand in front of a neutral background\n• Tap “Record” and look into the camera\n• Move your head slightly\n• Ensure good lighting and a clearly visible face")
  }

  /// Start
  public static var tkEidRequestAutoVerificationWelcomeButton: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_button", fallback: "Start")
  }

  /// Welcome back
  public static var tkEidRequestAutoVerificationWelcomePrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_primary", fallback: "Welcome back")
  }

  /// The next step is identity verification. Please have the identity document ready that you used to start your application.
  public static var tkEidRequestAutoVerificationWelcomeSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_secondary", fallback: "The next step is identity verification. Please have the identity document ready that you used to start your application.")
  }

  /// Please take a few minutes and do not cancel the process, otherwise all the information will be lost.
  public static var tkEidRequestAutoVerificationWelcomeTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_tertiary", fallback: "Please take a few minutes and do not cancel the process, otherwise all the information will be lost.")
  }

  /// Tip
  public static var tkEidRequestAutoVerificationWelcomeTertiaryTip: String {
    L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_tertiary_tip", fallback: "Tip")
  }

  /// Apple attestation service error
  public static var tkEidRequestClientAttestationDeviceCheckErrorBody: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_error_body", fallback: "Apple attestation service error")
  }

  /// Something went wrong with Apple attestations service
  public static var tkEidRequestClientAttestationDeviceCheckErrorTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_error_title", fallback: "Something went wrong with Apple attestations service")
  }

  /// Timeout from apple service. try again later.
  public static var tkEidRequestClientAttestationDeviceCheckTimeoutBody: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_timeout_body", fallback: "Timeout from apple service. try again later.")
  }

  /// the Apple attestations service can't be reached
  public static var tkEidRequestClientAttestationDeviceCheckTimeoutTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_timeout_title", fallback: "the Apple attestations service can't be reached")
  }

  /// Storage level error
  public static var tkEidRequestClientAttestationInsufficientKeyStorageBody: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_insufficientKeyStorage_body", fallback: "Storage level error")
  }

  /// Storage level not sufficient
  public static var tkEidRequestClientAttestationInsufficientKeyStorageTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_insufficientKeyStorage_title", fallback: "Storage level not sufficient")
  }

  /// The security check could not be completed. Please try again later.
  public static var tkEidRequestClientAttestationSecurityCheckErrorBody: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_securityCheck_error_body", fallback: "The security check could not be completed. Please try again later.")
  }

  /// Your device security could not be verified.
  public static var tkEidRequestClientAttestationSecurityCheckErrorTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_securityCheck_error_title", fallback: "Your device security could not be verified.")
  }

  /// e-ID request preparation error
  public static var tkEidRequestClientAttestationServiceErrorBody: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_service_error_body", fallback: "e-ID request preparation error")
  }

  /// Something went wrong in the preparation of the e-ID request
  public static var tkEidRequestClientAttestationServiceErrorTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestation_service_error_title", fallback: "Something went wrong in the preparation of the e-ID request")
  }

  /// https://www.eid.admin.ch/
  public static var tkEidRequestClientAttestationErrorHelpLink: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_help_link", fallback: "https://www.eid.admin.ch/")
  }

  /// This wallet app is not supported.
  public static var tkEidRequestClientAttestationErrorPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_primary", fallback: "This wallet app is not supported.")
  }

  /// Download the swiyu Wallet
  public static var tkEidRequestClientAttestationErrorPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_primary_button", fallback: "Download the swiyu Wallet")
  }

  /// Please use the official swiyu Wallet or another compatible wallet app.
  public static var tkEidRequestClientAttestationErrorSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_secondary", fallback: "Please use the official swiyu Wallet or another compatible wallet app.")
  }

  /// Close
  public static var tkEidRequestClientAttestationErrorSecondaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_secondary_button", fallback: "Close")
  }

  /// Hilfe & FAQ
  public static var tkEidRequestClientAttestationErrorTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_tertiary", fallback: "Hilfe & FAQ")
  }

  /// Thank you for your application
  public static var tkEidRequestConsentOkAvQueuePrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_consentOk_avQueue_primary", fallback: "Thank you for your application")
  }

  /// Thank you for your application. It has been successfully submitted. Due to high demand, processing may take longer than usual. You will receive a notification once your application has been processed.
  public static var tkEidRequestConsentOkAvQueueSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_consentOk_avQueue_secondary", fallback: "Thank you for your application. It has been successfully submitted. Due to high demand, processing may take longer than usual. You will receive a notification once your application has been processed.")
  }

  /// We attach great importance to the protection of your data and your privacy. To create an e-ID, we require your consent to the data protection declaration.
  public static var tkEidRequestDataPrivacyBody: String {
    L10n.tr("Localizable", "tk_eidRequest_dataPrivacy_body", fallback: "We attach great importance to the protection of your data and your privacy. To create an e-ID, we require your consent to the data protection declaration.")
  }

  /// Privacy Statement
  public static var tkEidRequestDataPrivacyLinkText: String {
    L10n.tr("Localizable", "tk_eidRequest_dataPrivacy_link_text", fallback: "Privacy Statement")
  }

  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var tkEidRequestDataPrivacyLinkValue: String {
    L10n.tr("Localizable", "tk_eidRequest_dataPrivacy_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  }

  /// Agree and continue
  public static var tkEidRequestDataPrivacyPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_dataPrivacy_primaryButton", fallback: "Agree and continue")
  }

  /// Privacy Statement
  public static var tkEidRequestDataPrivacyTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_dataPrivacy_title", fallback: "Privacy Statement")
  }

  /// Turn your device to landscape mode.
  public static var tkEidRequestDocumentScanRotateCameraHint: String {
    L10n.tr("Localizable", "tk_eidRequest_documentScan_rotateCamera_hint", fallback: "Turn your device to landscape mode.")
  }

  /// Try again
  public static var tkEidRequestDocumentScanWrongDocumentButton: String {
    L10n.tr("Localizable", "tk_eidRequest_documentScan_wrongDocument_button", fallback: "Try again")
  }

  /// Identity document does not match
  public static var tkEidRequestDocumentScanWrongDocumentPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_documentScan_wrongDocument_primary", fallback: "Identity document does not match")
  }

  /// Please make sure you scan the same identity document you used to start your application again.
  public static var tkEidRequestDocumentScanWrongDocumentSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_documentScan_wrongDocument_secondary", fallback: "Please make sure you scan the same identity document you used to start your application again.")
  }

  /// Swiss ID Card
  public static var tkEidRequestDocumentSelectionIdCard: String {
    L10n.tr("Localizable", "tk_eidRequest_documentSelection_idCard", fallback: "Swiss ID Card")
  }

  /// Swiss Passport
  public static var tkEidRequestDocumentSelectionPassport: String {
    L10n.tr("Localizable", "tk_eidRequest_documentSelection_passport", fallback: "Swiss Passport")
  }

  /// Which identity document would you like to use?
  public static var tkEidRequestDocumentSelectionPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_documentSelection_primary", fallback: "Which identity document would you like to use?")
  }

  /// Swiss residence permit
  public static var tkEidRequestDocumentSelectionResidentPermit: String {
    L10n.tr("Localizable", "tk_eidRequest_documentSelection_residentPermit", fallback: "Swiss residence permit")
  }

  /// Select one of the listed documents to proof your eligibility. Only original and valid documents will be accepted.
  public static var tkEidRequestDocumentSelectionSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_documentSelection_secondary", fallback: "Select one of the listed documents to proof your eligibility. Only original and valid documents will be accepted.")
  }

  /// Finish
  public static var tkEidRequestGuardianConsentButtonFinish: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianConsent_button_finish", fallback: "Finish")
  }

  /// Share QR-Code
  public static var tkEidRequestGuardianConsentButtonShare: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianConsent_button_share", fallback: "Share QR-Code")
  }

  /// Scan QR Code
  public static var tkEidRequestGuardianConsentPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianConsent_primary", fallback: "Scan QR Code")
  }

  /// QR Code. Have a parent or guardian scan or share this code.
  public static var tkEidRequestGuardianConsentQrAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianConsent_qr_alt", fallback: "QR Code. Have a parent or guardian scan or share this code.")
  }

  /// Try again
  public static var tkEidRequestGuardianConsentQrButtonRetry: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianConsent_qr_button_retry", fallback: "Try again")
  }

  /// An error occurred while generating the QR code.
  public static var tkEidRequestGuardianConsentQrError: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianConsent_qr_error", fallback: "An error occurred while generating the QR code.")
  }

  /// A legal guardian must scan the QR code using their own swiyu Wallet to give consent.
  public static var tkEidRequestGuardianConsentSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianConsent_secondary", fallback: "A legal guardian must scan the QR code using their own swiyu Wallet to give consent.")
  }

  /// Continue as a parent/guardian
  public static var tkEidRequestGuardianSelectionButtonContinueAsGuardian: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianSelection_button_continueAsGuardian", fallback: "Continue as a parent/guardian")
  }

  /// Obtain consent
  public static var tkEidRequestGuardianSelectionButtonObtainConsent: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianSelection_button_obtainConsent", fallback: "Obtain consent")
  }

  /// To create this e-ID, consent from a parent or your legal guardian is required.
  public static var tkEidRequestGuardianSelectionPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianSelection_primary", fallback: "To create this e-ID, consent from a parent or your legal guardian is required.")
  }

  /// How would you like to proceed?
  public static var tkEidRequestGuardianSelectionSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianSelection_secondary", fallback: "How would you like to proceed?")
  }

  /// No
  public static var tkEidRequestGuardianshipButtonNo: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianship_button_no", fallback: "No")
  }

  /// Yes
  public static var tkEidRequestGuardianshipButtonYes: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianship_button_yes", fallback: "Yes")
  }

  /// Are you subject to full legal guardianship?
  public static var tkEidRequestGuardianshipPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianship_primary", fallback: "Are you subject to full legal guardianship?")
  }

  /// Are you of legal age and can only someone else make legally binding decisions for you?
  public static var tkEidRequestGuardianshipSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianship_secondary", fallback: "Are you of legal age and can only someone else make legally binding decisions for you?")
  }

  /// Start identity verification
  public static var tkEidRequestGuardianVerificationButtonStart: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianVerification_button_start", fallback: "Start identity verification")
  }

  /// Verify your identity to receive your e-ID.
  public static var tkEidRequestGuardianVerificationPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianVerification_primary", fallback: "Verify your identity to receive your e-ID.")
  }

  /// Verify your identity to obtain the e-ID for your child or a person under your care
  public static var tkEidRequestGuardianVerificationSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianVerification_secondary", fallback: "Verify your identity to obtain the e-ID for your child or a person under your care")
  }

  /// For the next steps, your child or the person you are assisting must be present for biometric verification.
  public static var tkEidRequestGuardianVerificationTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_guardianVerification_tertiary", fallback: "For the next steps, your child or the person you are assisting must be present for biometric verification.")
  }

  /// In the next steps, you will photograph and scan your identity document. Afterwards, you will record a short video of your face so we can identify you.
  public static var tkEidRequestIntroBody: String {
    L10n.tr("Localizable", "tk_eidRequest_intro_body", fallback: "In the next steps, you will photograph and scan your identity document. Afterwards, you will record a short video of your face so we can identify you.")
  }

  /// Order now
  public static var tkEidRequestIntroPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_intro_primaryButton", fallback: "Order now")
  }

  /// Later
  public static var tkEidRequestIntroSecondaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_intro_secondaryButton", fallback: "Later")
  }

  /// Exceptions
  /// Protecting your identity is our top priority. In rare cases, we may need to carry out an additional check to verify your identity. This can take several days more.
  ///
  public static var tkEidRequestIntroSmallBody: String {
    L10n.tr("Localizable", "tk_eidRequest_intro_smallBody", fallback: "Exceptions\nProtecting your identity is our top priority. In rare cases, we may need to carry out an additional check to verify your identity. This can take several days more.\n")
  }

  /// How to order your e-ID
  public static var tkEidRequestIntroTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_intro_title", fallback: "How to order your e-ID")
  }

  /// Unfortunately, this device is not supported.
  public static var tkEidRequestKeyAttestationErrorPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_primary", fallback: "Unfortunately, this device is not supported.")
  }

  /// Close
  public static var tkEidRequestKeyAttestationErrorPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_primary_button", fallback: "Close")
  }

  /// For security reasons, certain technical requirements must be met. Unfortunately, this is not possible with this device.
  public static var tkEidRequestKeyAttestationErrorSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_secondary", fallback: "For security reasons, certain technical requirements must be met. Unfortunately, this is not possible with this device.")
  }

  /// Help & FAQ
  public static var tkEidRequestKeyAttestationErrorTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_tertiary", fallback: "Help & FAQ")
  }

  /// Consent has been provided, you can start now with the verification process.
  public static var tkEidRequestLegalRepresentantGivenConsentReadyForAVPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantGivenConsent_readyForAV_primary", fallback: "Consent has been provided, you can start now with the verification process.")
  }

  /// Please have a valid ID ready.
  public static var tkEidRequestLegalRepresentantGivenConsentReadyForAVSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantGivenConsent_readyForAV_secondary", fallback: "Please have a valid ID ready.")
  }

  /// Order has expired.
  public static var tkEidRequestLegalRepresentantPendingConsentExpiredPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_expired_primary", fallback: "Order has expired.")
  }

  /// Unfortunately, your ordering deadline has expired.
  ///
  /// Reason: Your legal representative did not approve the order.
  ///
  /// You can place a new order at any time.
  public static var tkEidRequestLegalRepresentantPendingConsentExpiredSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_expired_secondary", fallback: "Unfortunately, your ordering deadline has expired.\n\nReason: Your legal representative did not approve the order.\n\nYou can place a new order at any time.")
  }

  /// Consent is missing, your e-ID is in the queue.
  public static var tkEidRequestLegalRepresentantPendingConsentInQueuePrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_inQueue_primary", fallback: "Consent is missing, your e-ID is in the queue.")
  }

  /// Your electronic identity is currently in the queue.
  ///
  /// As soon as it’s your turn, you will receive a notification via the app.
  ///
  /// Your parents’ or legal guardian’s consent is still missing.
  public static var tkEidRequestLegalRepresentantPendingConsentInQueueSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_inQueue_secondary", fallback: "Your electronic identity is currently in the queue.\n\nAs soon as it’s your turn, you will receive a notification via the app.\n\nYour parents’ or legal guardian’s consent is still missing.")
  }

  /// Consent is pending.
  public static var tkEidRequestLegalRepresentantPendingConsentReadyForAVPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_readyForAV_primary", fallback: "Consent is pending.")
  }

  /// Please verify your identity by
  public static var tkEidRequestLegalRepresentantPendingConsentReadyForAVSecondaryPrefix: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_readyForAV_secondary_prefix", fallback: "Please verify your identity by ")
  }

  /// , otherwise your order will be canceled.
  ///
  /// Your parents’ or legal guardian’s consent is still missing. You need to obtain the consent first in order to proceed.
  public static var tkEidRequestLegalRepresentantPendingConsentReadyForAVSecondarySuffix: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_readyForAV_secondary_suffix", fallback: ", otherwise your order will be canceled.\n\nYour parents’ or legal guardian’s consent is still missing. You need to obtain the consent first in order to proceed.")
  }

  /// Start
  public static var tkEidRequestLegalRepresentantPendingConsentStartButton: String {
    L10n.tr("Localizable", "tk_eidRequest_legalRepresentantPendingConsent_start_button", fallback: "Start")
  }

  /// Scan the front side of your document
  public static var tkEidRequestMrzScannerNotificationRectoPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_recto_primary", fallback: "Scan the front side of your document")
  }

  /// Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.
  public static var tkEidRequestMrzScannerNotificationRectoSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_recto_secondary", fallback: "Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.")
  }

  /// Scan the back side of your document
  public static var tkEidRequestMrzScannerNotificationVersoPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_verso_primary", fallback: "Scan the back side of your document")
  }

  /// Place your document on a flat surface and position the back side in the frame. Make sure you have enough light.
  public static var tkEidRequestMrzScannerNotificationVersoSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_verso_secondary", fallback: "Place your document on a flat surface and position the back side in the frame. Make sure you have enough light.")
  }

  /// Scan the first page
  public static var tkEidRequestMrzScannerRecto: String {
    L10n.tr("Localizable", "tk_eidRequest_mrzScanner_recto", fallback: "Scan the first page")
  }

  /// Scan the second page
  public static var tkEidRequestMrzScannerVerso: String {
    L10n.tr("Localizable", "tk_eidRequest_mrzScanner_verso", fallback: "Scan the second page")
  }

  /// Try again
  public static var tkEidRequestNfcScanErrorButtonRetry: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_error_button_retry", fallback: "Try again")
  }

  /// Identity document not fully read
  public static var tkEidRequestNfcScanErrorPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_error_primary", fallback: "Identity document not fully read")
  }

  /// We could not read the identity document. Please hold the document steady against the device and try again.
  public static var tkEidRequestNfcScanErrorSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_error_secondary", fallback: "We could not read the identity document. Please hold the document steady against the device and try again.")
  }

  /// Continue anyway
  public static var tkEidRequestNfcScanErrorFailedButtonContinue: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_errorFailed_button_continue", fallback: "Continue anyway")
  }

  /// Try again
  public static var tkEidRequestNfcScanErrorFailedButtonRetry: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_errorFailed_button_retry", fallback: "Try again")
  }

  /// Failed to read identity document
  public static var tkEidRequestNfcScanErrorFailedPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_errorFailed_primary", fallback: "Failed to read identity document")
  }

  /// You can continue without this step.
  /// You may be asked later to confirm possession of your identity document.
  public static var tkEidRequestNfcScanErrorFailedSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_errorFailed_secondary", fallback: "You can continue without this step.\nYou may be asked later to confirm possession of your identity document.")
  }

  /// How to hold the passport
  public static var tkEidRequestNfcScanHelpPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_help_primary", fallback: "How to hold the passport")
  }

  /// Place the passport flat against the back of your phone.
  /// Keep it steady until reading is complete.
  public static var tkEidRequestNfcScanHelpSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_help_secondary", fallback: "Place the passport flat against the back of your phone.\nKeep it steady until reading is complete.")
  }

  /// Tips
  public static var tkEidRequestNfcScanHelpTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_help_title", fallback: "Tips")
  }

  /// Trouble with the reading?
  public static var tkEidRequestNfcScanHelpFailurePrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_helpFailure_primary", fallback: "Trouble with the reading?")
  }

  /// Move the passport slightly up or down.
  /// Remove the phone case if you use one.
  public static var tkEidRequestNfcScanHelpFailureSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_helpFailure_secondary", fallback: "Move the passport slightly up or down.\nRemove the phone case if you use one.")
  }

  /// Tips
  public static var tkEidRequestNfcScanHelpFailureTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_helpFailure_title", fallback: "Tips")
  }

  /// Read passport with your phone
  public static var tkEidRequestNfcScanPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_primary", fallback: "Read passport with your phone")
  }

  /// Start reading
  public static var tkEidRequestNfcScanPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_primaryButton", fallback: "Start reading")
  }

  /// Identity document successfully read
  public static var tkEidRequestNfcScanScannerDoneHint: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_scanner_done_hint", fallback: "Identity document successfully read")
  }

  /// Reading passport…
  public static var tkEidRequestNfcScanScannerReadingHint: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_scanner_reading_hint", fallback: "Reading passport…")
  }

  /// Hold the passport against the back of your device and keep it steady
  public static var tkEidRequestNfcScanScannerSearchingHint: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_scanner_searching_hint", fallback: "Hold the passport against the back of your device and keep it steady")
  }

  /// • Hold your phone over the passport
  /// • Move the passport slightly
  /// • Wait for the signal
  /// • Keep the passport still
  ///
  /// If it does not work
  /// • Adjust the position and try again
  /// • Remove your phone case
  public static var tkEidRequestNfcScanSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_secondary", fallback: "• Hold your phone over the passport\n• Move the passport slightly\n• Wait for the signal\n• Keep the passport still\n\nIf it does not work\n• Adjust the position and try again\n• Remove your phone case")
  }

  /// See tips
  public static var tkEidRequestNfcScanTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScan_tertiary", fallback: "See tips")
  }

  /// Expiration date
  public static var tkEidRequestNfcScanResultExpirationDateKey: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScanResult_expirationDate_key", fallback: "Expiration date")
  }

  /// Given name(s)
  public static var tkEidRequestNfcScanResultGivenNamesKey: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScanResult_givenNames_key", fallback: "Given name(s)")
  }

  /// Passport number
  public static var tkEidRequestNfcScanResultPassportNumberKey: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScanResult_passportNumber_key", fallback: "Passport number")
  }

  /// Your photo
  public static var tkEidRequestNfcScanResultPhotoAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScanResult_photo_alt", fallback: "Your photo")
  }

  /// Photo
  public static var tkEidRequestNfcScanResultPhotoKey: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScanResult_photo_key", fallback: "Photo")
  }

  /// Surname
  public static var tkEidRequestNfcScanResultSurnameKey: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScanResult_surname_key", fallback: "Surname")
  }

  /// Your document details
  public static var tkEidRequestNfcScanResultTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_nfcScanResult_title", fallback: "Your document details")
  }

  /// Your identity is being carefully verified. This may take several business days. Once we are done, you will receive a notification.
  public static var tkEidRequestNotificationAgentReviewSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_agentReview_secondary", fallback: "Your identity is being carefully verified. This may take several business days. Once we are done, you will receive a notification.")
  }

  /// Your files have been sent. Please wait a moment.
  public static var tkEidRequestNotificationAutoVerificationFilesSubmittedSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_autoVerification_filesSubmitted_secondary", fallback: "Your files have been sent. Please wait a moment.")
  }

  /// Your e-ID application was cancelled
  public static var tkEidRequestNotificationCancelledPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_cancelled_primary", fallback: "Your e-ID application was cancelled")
  }

  /// You did not complete the application process. Please submit a new e-ID application.
  public static var tkEidRequestNotificationCancelledSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_cancelled_secondary", fallback: "You did not complete the application process. Please submit a new e-ID application.")
  }

  /// Close button
  public static var tkEidRequestNotificationCloseButton: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_close_button", fallback: "Close button")
  }

  /// https://www.eid.admin.ch/en
  public static var tkEidRequestNotificationDeclinedFaqLink: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_declined_faqLink", fallback: "https://www.eid.admin.ch/en")
  }

  /// Go to FAQ
  public static var tkEidRequestNotificationDeclinedPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_declined_primaryButton", fallback: "Go to FAQ")
  }

  /// In the FAQ you will find common errors and helpful tips. Afterwards, you can apply for an e-ID again.
  public static var tkEidRequestNotificationDeclinedSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_declined_secondary", fallback: "In the FAQ you will find common errors and helpful tips. Afterwards, you can apply for an e-ID again.")
  }

  /// You did not fully complete the ordering process. Please restart it to receive your e-ID.
  public static var tkEidRequestNotificationEidExpiredSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidExpired_secondary", fallback: "You did not fully complete the ordering process. Please restart it to receive your e-ID.")
  }

  /// Start identification
  public static var tkEidRequestNotificationEidReadyGreenButton: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidReady_greenButton", fallback: "Start identification")
  }

  /// Press to refresh
  public static var tkEidRequestNotificationEidUnknownStateButton: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidUnknownState_button", fallback: "Press to refresh")
  }

  /// Unable to retrieve the status status of your e-ID order.
  public static var tkEidRequestNotificationEidUnknownStateSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidUnknownState_secondary", fallback: "Unable to retrieve the status status of your e-ID order.")
  }

  /// Your e-ID is now available. Select the credential from the list to activate it.
  public static var tkEidRequestNotificationIssuingSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_issuing_secondary", fallback: "Your e-ID is now available. Select the credential from the list to activate it.")
  }

  /// Obtain consent
  public static var tkEidRequestNotificationLegalRepresentantPendingConsentInQueueButton: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_legalRepresentantPendingConsent_inQueue_button", fallback: "Obtain consent")
  }

  /// Obtain consent
  public static var tkEidRequestNotificationLegalRepresentantPendingConsentInQueuePrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_legalRepresentantPendingConsent_inQueue_primary", fallback: "Obtain consent")
  }

  /// Your electronic identity is currently in the queue. Your parents’ or legal guardian’s consent is still missing.
  public static var tkEidRequestNotificationLegalRepresentantPendingConsentInQueueSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_legalRepresentantPendingConsent_inQueue_secondary", fallback: "Your electronic identity is currently in the queue. Your parents’ or legal guardian’s consent is still missing.")
  }

  /// Obtain consent
  public static var tkEidRequestNotificationLegalRepresentantPendingConsentReadyForAVButton: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_legalRepresentantPendingConsent_readyForAV_button", fallback: "Obtain consent")
  }

  /// Obtain consent
  public static var tkEidRequestNotificationLegalRepresentantPendingConsentReadyForAVPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_legalRepresentantPendingConsent_readyForAV_primary", fallback: "Obtain consent")
  }

  /// Your identity is being carefully verified. This may take several business days. You will be notified once the process is complete.
  public static var tkEidRequestNotificationReadyForFinalEntitlementCheckSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_readyForFinalEntitlementCheck_secondary", fallback: "Your identity is being carefully verified. This may take several business days. You will be notified once the process is complete.")
  }

  /// Continue
  public static var tkEidRequestNotificationWalletPairingButton: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_walletPairing_button", fallback: "Continue")
  }

  /// Final steps for your e-ID
  public static var tkEidRequestNotificationWalletPairingPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_walletPairing_primary", fallback: "Final steps for your e-ID")
  }

  /// Please select your devices and verify your identity to complete your e-ID order.
  public static var tkEidRequestNotificationWalletPairingSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_notification_walletPairing_secondary", fallback: "Please select your devices and verify your identity to complete your e-ID order.")
  }

  /// Didn’t receive it? Check if your entered email address is correct.
  public static var tkEidRequestOtpCodeBodyHelp: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_body_help", fallback: "Didn’t receive it? Check if your entered email address is correct.")
  }

  /// The code is valid for 1 hour. Please enter the code to continue.
  public static var tkEidRequestOtpCodeBodyValidity: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_body_validity", fallback: "The code is valid for 1 hour. Please enter the code to continue.")
  }

  /// The code is incorrect. Please try again.
  public static var tkEidRequestOtpCodeErrorInvalid: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_error_invalid", fallback: "The code is incorrect. Please try again.")
  }

  /// Enter your 6 digit code
  public static var tkEidRequestOtpCodeFieldPlaceholder: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_field_placeholder", fallback: "Enter your 6 digit code")
  }

  /// Code
  public static var tkEidRequestOtpCodeFieldTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_field_title", fallback: "Code")
  }

  /// Enter code
  public static var tkEidRequestOtpCodeTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_title", fallback: "Enter code")
  }

  /// Your code has expired. Please request a new code.
  public static var tkEidRequestOtpCodeToastExpired: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_toast_expired", fallback: "Your code has expired. Please request a new code.")
  }

  /// Too many attempts. Request a new code.
  public static var tkEidRequestOtpCodeToastTooManyRequests: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_toast_tooManyRequests", fallback: "Too many attempts. Request a new code.")
  }

  /// Please enter your official email address with the domain @federaloffice.admin.ch. Your email address will be used to verify access to the test phase.
  public static var tkEidRequestOtpEmailBodyPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_body_primary", fallback: "Please enter your official email address with the domain @federaloffice.admin.ch. Your email address will be used to verify access to the test phase.")
  }

  /// A one-time code will be sent to this email address to complete your registration.
  public static var tkEidRequestOtpEmailBodySecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_body_secondary", fallback: "A one-time code will be sent to this email address to complete your registration.")
  }

  /// The "order e-ID" function is currently being tested and is available to only federal government employees with an email address ending in @federaloffice.admin.ch.
  public static var tkEidRequestOtpEmailErrorForbidden: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_error_forbidden", fallback: "The \"order e-ID\" function is currently being tested and is available to only federal government employees with an email address ending in @federaloffice.admin.ch.")
  }

  /// Something went wrong. Please try again.
  public static var tkEidRequestOtpEmailErrorGeneric: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_error_generic", fallback: "Something went wrong. Please try again.")
  }

  /// Wrong format.
  public static var tkEidRequestOtpEmailErrorInvalidFormat: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_error_invalid_format", fallback: "Wrong format.")
  }

  /// firstname.lastname@federaloffice.admin.ch
  public static var tkEidRequestOtpEmailFieldPlaceholder: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_field_placeholder", fallback: "firstname.lastname@federaloffice.admin.ch")
  }

  /// Email
  public static var tkEidRequestOtpEmailFieldTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_field_title", fallback: "Email")
  }

  /// Skip
  public static var tkEidRequestOtpEmailSkipButton: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_skip_button", fallback: "Skip")
  }

  /// Enter email address
  public static var tkEidRequestOtpEmailTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_email_title", fallback: "Enter email address")
  }

  /// The "order e-ID" function is currently being tested and is available to only federal government employees with an email address ending in @federaloffice.admin.ch.
  public static var tkEidRequestOtpIntroBody: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_intro_body", fallback: "The \"order e-ID\" function is currently being tested and is available to only federal government employees with an email address ending in @federaloffice.admin.ch.")
  }

  /// Continue
  public static var tkEidRequestOtpIntroPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_intro_primaryButton", fallback: "Continue")
  }

  /// Cancel
  public static var tkEidRequestOtpIntroSecondaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_intro_secondaryButton", fallback: "Cancel")
  }

  /// Registration for federal test phase
  public static var tkEidRequestOtpIntroTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_intro_title", fallback: "Registration for federal test phase")
  }

  /// To take part in the test phase, please confirm your eligibility and agree to the terms of use.
  public static var tkEidRequestOtpLegalBody: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_body", fallback: "To take part in the test phase, please confirm your eligibility and agree to the terms of use.")
  }

  /// Agree and continue
  public static var tkEidRequestOtpLegalPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_primaryButton", fallback: "Agree and continue")
  }

  /// Privacy Policy
  public static var tkEidRequestOtpLegalPrivacyLinkText: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_privacy_linkText", fallback: "Privacy Policy")
  }

  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var tkEidRequestOtpLegalPrivacyLinkValue: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_privacy_linkValue", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  }

  /// I do not agree
  public static var tkEidRequestOtpLegalSecondaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_secondaryButton", fallback: "I do not agree")
  }

  /// Terms of Participation
  public static var tkEidRequestOtpLegalTermsLinkText: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_terms_linkText", fallback: "Terms of Participation")
  }

  /// https://www.eid.admin.ch/en/swiyu-terms-e
  public static var tkEidRequestOtpLegalTermsLinkValue: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_terms_linkValue", fallback: "https://www.eid.admin.ch/en/swiyu-terms-e")
  }

  /// Terms of use
  public static var tkEidRequestOtpLegalTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_legal_title", fallback: "Terms of use")
  }

  /// The code could not be verified after multiple attempts.
  public static var tkEidRequestOtpTooManyAttemptsBodyPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_tooManyAttempts_body_primary", fallback: "The code could not be verified after multiple attempts.")
  }

  /// Please restart the registration to receive a new one-time code.
  public static var tkEidRequestOtpTooManyAttemptsBodySecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_tooManyAttempts_body_secondary", fallback: "Please restart the registration to receive a new one-time code.")
  }

  /// Too many attempts
  public static var tkEidRequestOtpTooManyAttemptsTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_tooManyAttempts_title", fallback: "Too many attempts")
  }

  /// Registration for the test phase is temporarily not available. We kindly ask you to try again later.
  public static var tkEidRequestOtpUnavailableBody: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_unavailable_body", fallback: "Registration for the test phase is temporarily not available. We kindly ask you to try again later.")
  }

  /// Visit status page
  public static var tkEidRequestOtpUnavailableLinkText: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_unavailable_link_text", fallback: "Visit status page")
  }

  /// https://www.eid.admin.ch/en/swiyu-terms-e
  public static var tkEidRequestOtpUnavailableLinkValue: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_unavailable_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-terms-e")
  }

  /// Back to wallet
  public static var tkEidRequestOtpUnavailablePrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_unavailable_primaryButton", fallback: "Back to wallet")
  }

  /// Registration temporarily unavailable
  public static var tkEidRequestOtpUnavailableTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_otp_unavailable_title", fallback: "Registration temporarily unavailable")
  }

  /// We have received your request. Unfortunately, your order can't be processed immediately due to high demand.
  ///
  /// As soon as it is your turn, you will receive a message via the app.
  public static var tkEidRequestQueuingBody: String {
    L10n.tr("Localizable", "tk_eidRequest_queuing_body", fallback: "We have received your request. Unfortunately, your order can't be processed immediately due to high demand. \n\nAs soon as it is your turn, you will receive a message via the app.")
  }

  /// Estimated time:
  public static var tkEidRequestQueuingBody2Ios: String {
    L10n.tr("Localizable", "tk_eidRequest_queuing_body2_ios", fallback: "Estimated time:")
  }

  /// In Queue for Processing
  public static var tkEidRequestQueuingTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_queuing_title", fallback: "In Queue for Processing")
  }

  /// Tap to stop recording.
  public static var tkEidRequestRecordDocumentButtonRecordingStateAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_buttonRecordingState_alt", fallback: "Tap to stop recording.")
  }

  /// Proceed
  public static var tkEidRequestRecordDocumentInformationButtonPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_information_button_primary", fallback: "Proceed")
  }

  /// Record identity document
  public static var tkEidRequestRecordDocumentInformationPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_information_primary", fallback: "Record identity document")
  }

  /// • Keep the identity document ready
  /// • Avoid direct light and reflections
  /// • Align it within the frame
  /// • Slightly move and tilt the document
  /// • Repeat for page 2
  /// • Press the red button
  public static var tkEidRequestRecordDocumentInformationSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_information_secondary", fallback: "• Keep the identity document ready\n• Avoid direct light and reflections\n• Align it within the frame\n• Slightly move and tilt the document\n• Repeat for page 2\n• Press the red button")
  }

  /// Scan the front side of your document
  public static var tkEidRequestRecordDocumentNotificationRectoPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_recto_primary", fallback: "Scan the front side of your document")
  }

  /// Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.
  public static var tkEidRequestRecordDocumentNotificationRectoSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_recto_secondary", fallback: "Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.")
  }

  /// Scan the back side of your document.
  public static var tkEidRequestRecordDocumentNotificationVersoPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_verso_primary", fallback: "Scan the back side of your document.")
  }

  /// Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.
  public static var tkEidRequestRecordDocumentNotificationVersoSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_verso_secondary", fallback: "Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.")
  }

  /// Camera running, please position back of the document
  public static var tkEidRequestRecordDocumentOverlayBackAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_overlay_back_alt", fallback: "Camera running, please position back of the document")
  }

  /// Camera running, please position front of the document
  public static var tkEidRequestRecordDocumentOverlayFrontAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_overlay_front_alt", fallback: "Camera running, please position front of the document")
  }

  /// Processing finished
  public static var tkEidRequestRecordDocumentProcessingFinishedAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_processingFinished_alt", fallback: "Processing finished")
  }

  /// Recording finished, processing
  public static var tkEidRequestRecordDocumentProcessingStartAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_processingStart_alt", fallback: "Recording finished, processing")
  }

  /// Capture first page
  public static var tkEidRequestRecordDocumentRecto: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_recto", fallback: "Capture first page")
  }

  /// Capture second page
  public static var tkEidRequestRecordDocumentVerso: String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_verso", fallback: "Capture second page")
  }

  /// Press to stop recording
  public static var tkEidRequestRecordSelfieButtonRecordingStateAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_buttonRecordingState_alt", fallback: "Press to stop recording")
  }

  /// Start face recording
  public static var tkEidRequestRecordSelfieNotificationPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_notification_primary", fallback: "Start face recording")
  }

  /// Position your face within the frame. Stand in front of a neutral background where there is sufficient light.
  public static var tkEidRequestRecordSelfieNotificationSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_notification_secondary", fallback: "Position your face within the frame. Stand in front of a neutral background where there is sufficient light.")
  }

  /// Position your face within the frame. If needed, ask someone for help.
  public static var tkEidRequestRecordSelfiePictureFrameAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_pictureFrame_alt", fallback: "Position your face within the frame. If needed, ask someone for help.")
  }

  /// Processing finished
  public static var tkEidRequestRecordSelfieProcessingFinishedAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_processingFinished_alt", fallback: "Processing finished")
  }

  /// Recording finished, processing
  public static var tkEidRequestRecordSelfieProcessingStartAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_processingStart_alt", fallback: "Recording finished, processing")
  }

  /// Record Selfie
  public static var tkEidRequestRecordSelfieTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_title", fallback: "Record Selfie")
  }

  /// Tap to start scanning.
  public static var tkEidRequestScanDocumentButtonInitialStateAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_buttonInitialState_alt", fallback: "Tap to start scanning.")
  }

  /// Tap to stop scanning.
  public static var tkEidRequestScanDocumentButtonRecordStateAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_buttonRecordState_alt", fallback: "Tap to stop scanning.")
  }

  /// Continue
  public static var tkEidRequestScanDocumentInformationButtonPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_information_button_primary", fallback: "Continue")
  }

  /// Now scan your identity document
  public static var tkEidRequestScanDocumentInformationPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_information_primary", fallback: "Now scan your identity document")
  }

  /// • Place the identity document on a flat surface
  /// • Avoid direct light and reflections
  /// • Avoid direct light or reflections
  /// • Keep the device steady
  /// • Press the red button
  public static var tkEidRequestScanDocumentInformationSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_information_secondary", fallback: "• Place the identity document on a flat surface\n• Avoid direct light and reflections\n• Avoid direct light or reflections\n• Keep the device steady\n• Press the red button")
  }

  /// Your MRZ data is being prepared and sent for validation.
  public static var tkEidRequestScanDocumentInitializationSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_initialization_secondary", fallback: "Your MRZ data is being prepared and sent for validation.")
  }

  /// Camera running, please position back of the document
  public static var tkEidRequestScanDocumentOverlayBackAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_overlay_back_alt", fallback: "Camera running, please position back of the document")
  }

  /// Camera active. Please position the document in front of the camera.
  public static var tkEidRequestScanDocumentOverlayFrontAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_overlay_front_alt", fallback: "Camera active. Please position the document in front of the camera.")
  }

  /// Scan the back side of your identity document.
  public static var tkEidRequestScanDocumentSecondPageIdCardPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_secondPage_idCard_primary", fallback: "Scan the back side of your identity document.")
  }

  /// Turn the identity document over and scan the second page.
  public static var tkEidRequestScanDocumentSecondPageIdCardSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_secondPage_idCard_secondary", fallback: "Turn the identity document over and scan the second page.")
  }

  /// Scan the page with your signature
  public static var tkEidRequestScanDocumentSecondPagePassportPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_secondPage_passport_primary", fallback: "Scan the page with your signature")
  }

  /// Scan the 2nd page of your passport with your signature.
  public static var tkEidRequestScanDocumentSecondPagePassportSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocument_secondPage_passport_secondary", fallback: "Scan the 2nd page of your passport with your signature.")
  }

  /// Close
  public static var tkEidRequestScanDocumentOverviewCloseButtonTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentOverview_closeButtonTitle", fallback: "Close")
  }

  /// Expanded image of your scan
  public static var tkEidRequestScanDocumentSubmitExpandedImageAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_expandedImageAlt", fallback: "Expanded image of your scan")
  }

  /// Image of first scan
  public static var tkEidRequestScanDocumentSubmitFirstScanImageAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_firstScanImageAlt", fallback: "Image of first scan")
  }

  /// First scan
  public static var tkEidRequestScanDocumentSubmitFirstScanImageTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_firstScanImageTitle", fallback: "First scan")
  }

  /// Expand
  public static var tkEidRequestScanDocumentSubmitScanImageExpandButtonAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_scanImage_expandButton_alt", fallback: "Expand")
  }

  /// Scan again
  public static var tkEidRequestScanDocumentSubmitSecondaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_secondaryButton", fallback: "Scan again")
  }

  /// Image of second scan
  public static var tkEidRequestScanDocumentSubmitSecondScanImageAlt: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_secondScanImageAlt", fallback: "Image of second scan")
  }

  /// Second scan
  public static var tkEidRequestScanDocumentSubmitSecondScanImageTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_secondScanImageTitle", fallback: "Second scan")
  }

  /// Your scan
  public static var tkEidRequestScanDocumentSubmitTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_scanDocumentSubmit_title", fallback: "Your scan")
  }

  /// Data is being transmitted…
  public static var tkEidRequestSubmitDocumentsPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_submitDocuments_primary", fallback: "Data is being transmitted…")
  }

  /// Your data is being processed and will be validated shortly.
  public static var tkEidRequestSubmitDocumentsSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_submitDocuments_secondary", fallback: "Your data is being processed and will be validated shortly.")
  }

  /// Something went wrong.
  public static var tkEidRequestSubmitErrorPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_submitError_primary", fallback: "Something went wrong.")
  }

  /// Retry
  public static var tkEidRequestSubmitErrorPrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_submitError_primaryButton", fallback: "Retry")
  }

  /// No valid document detected. Keep the device steady and make sure the document is fully visible and free of reflections.
  public static var tkEidRequestSubmitErrorSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_submitError_secondary", fallback: "No valid document detected. Keep the device steady and make sure the document is fully visible and free of reflections.")
  }

  /// Help & FAQ
  public static var tkEidRequestSubmitErrorTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_submitError_tertiary", fallback: "Help & FAQ")
  }

  /// https://www.eid.admin.ch/
  public static var tkEidRequestSubmitErrorTertiaryLink: String {
    L10n.tr("Localizable", "tk_eidRequest_submitError_tertiaryLink", fallback: "https://www.eid.admin.ch/")
  }

  /// Restart
  public static var tkEidRequestTimeoutButtonRestart: String {
    L10n.tr("Localizable", "tk_eidRequest_timeout_button_restart", fallback: "Restart")
  }

  /// Session expired
  public static var tkEidRequestTimeoutPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_timeout_primary", fallback: "Session expired")
  }

  /// To protect your informations, we had to end your session.
  /// You can restart it and continue your e-ID verification process.
  public static var tkEidRequestTimeoutSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_timeout_secondary", fallback: "To protect your informations, we had to end your session.\nYou can restart it and continue your e-ID verification process.")
  }

  /// Get all devices you want to add ready now.
  public static var tkEidRequestWalletPairing1Body: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing1_body", fallback: "Get all devices you want to add ready now.")
  }

  /// Only on this device
  public static var tkEidRequestWalletPairing1PrimaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing1_primaryButton", fallback: "Only on this device")
  }

  /// Also on other devices
  public static var tkEidRequestWalletPairing1SecondaryButton: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing1_secondaryButton", fallback: "Also on other devices")
  }

  /// Note
  /// For security reasons, you can only set this now. Afterwards, it will no longer be possible to store your e-ID on additional devices.
  public static var tkEidRequestWalletPairing1SmallBody: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing1_smallBody", fallback: "Note\nFor security reasons, you can only set this now. Afterwards, it will no longer be possible to store your e-ID on additional devices.")
  }

  /// Would you like to use your e-ID on multiple devices?
  public static var tkEidRequestWalletPairing1Title: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing1_title", fallback: "Would you like to use your e-ID on multiple devices?")
  }

  /// Add another device
  public static var tkEidRequestWalletPairingAdditionalDeviceButtonPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_additionalDevice_button_primary", fallback: "Add another device")
  }

  /// You have reached the maximum number of devices that can be added.
  public static var tkEidRequestWalletPairingAdditionalDeviceSectionFooter: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_additionalDevice_sectionFooter", fallback: "You have reached the maximum number of devices that can be added.")
  }

  /// Additonal devices
  public static var tkEidRequestWalletPairingAdditionalDeviceSectionTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_additionalDevice_sectionTitle", fallback: "Additonal devices")
  }

  /// Continue with verification
  public static var tkEidRequestWalletPairingButtonPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_button_primary", fallback: "Continue with verification")
  }

  /// Add this device
  public static var tkEidRequestWalletPairingCurrentDeviceButtonPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_currentDevice_button_primary", fallback: "Add this device")
  }

  /// Device is being prepared…
  public static var tkEidRequestWalletPairingCurrentDeviceLoadingTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_currentDevice_loadingTitle", fallback: "Device is being prepared…")
  }

  /// This device
  public static var tkEidRequestWalletPairingCurrentDeviceSectionTitle: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_currentDevice_sectionTitle", fallback: "This device")
  }

  /// Wallet paired successfully
  public static var tkEidRequestWalletPairingNotificationSuccess: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_notification_success", fallback: "Wallet paired successfully")
  }

  /// Riprova
  public static var tkEidRequestWalletPairingOfferRejectedButtonPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_offer_rejected_button_primary", fallback: "Riprova")
  }

  /// Something went wrong
  public static var tkEidRequestWalletPairingOfferRejectedPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_offer_rejected_primary", fallback: "Something went wrong")
  }

  /// The device could not be paired due to an unexpected error. Please try again or contact support.
  public static var tkEidRequestWalletPairingOfferRejectedSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_offer_rejected_secondary", fallback: "The device could not be paired due to an unexpected error. Please try again or contact support.")
  }

  /// Help & FAQ
  public static var tkEidRequestWalletPairingOfferRejectedTertiary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_offer_rejected_tertiary", fallback: "Help & FAQ")
  }

  /// https://www.eid.admin.ch/en/help-publicbeta-e
  public static var tkEidRequestWalletPairingOfferRejectedTertiaryLink: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_offer_rejected_tertiary_link", fallback: "https://www.eid.admin.ch/en/help-publicbeta-e")
  }

  /// Where would you like to store your e-ID?
  public static var tkEidRequestWalletPairingPrimary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_primary", fallback: "Where would you like to store your e-ID?")
  }

  /// Set up your e-ID on this device or additional devices. This setting cannot be changed later.
  public static var tkEidRequestWalletPairingSecondary: String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_secondary", fallback: "Set up your e-ID on this device or additional devices. This setting cannot be changed later.")
  }

  /// Please check your internet connection or try again later
  public static var tkErrorConnectionproblemBody: String {
    L10n.tr("Localizable", "tk_error_connectionproblem_body", fallback: "Please check your internet connection or try again later")
  }

  /// Connection problems
  public static var tkErrorConnectionproblemTitle: String {
    L10n.tr("Localizable", "tk_error_connectionproblem_title", fallback: "Connection problems")
  }

  /// Try again
  public static var tkErrorGenericButtonPrimary: String {
    L10n.tr("Localizable", "tk_error_generic_button_primary", fallback: "Try again")
  }

  /// Help & FAQ
  public static var tkErrorGenericHelpLinkLabel: String {
    L10n.tr("Localizable", "tk_error_generic_helpLink_label", fallback: "Help & FAQ")
  }

  /// https://www.eid.admin.ch/en/hilfe-e
  public static var tkErrorGenericHelpLinkValue: String {
    L10n.tr("Localizable", "tk_error_generic_helpLink_value", fallback: "https://www.eid.admin.ch/en/hilfe-e")
  }

  /// Something went wrong
  public static var tkErrorGenericPrimary: String {
    L10n.tr("Localizable", "tk_error_generic_primary", fallback: "Something went wrong")
  }

  /// We’re unable to complete your request right now. This might be due to a temporary connection or system issue.
  public static var tkErrorGenericSecondary: String {
    L10n.tr("Localizable", "tk_error_generic_secondary", fallback: "We’re unable to complete your request right now. This might be due to a temporary connection or system issue.")
  }

  /// This check cannot be perfomed.
  public static var tkErrorInvalidrequestBody: String {
    L10n.tr("Localizable", "tk_error_invalidrequest_body", fallback: "This check cannot be perfomed.")
  }

  /// Invalid check
  public static var tkErrorInvalidrequestTitle: String {
    L10n.tr("Localizable", "tk_error_invalidrequest_title", fallback: "Invalid check")
  }

  /// This credential cannot be added to the swiyu Wallet.
  public static var tkErrorInvitationcredentialBody: String {
    L10n.tr("Localizable", "tk_error_invitationcredential_body", fallback: "This credential cannot be added to the swiyu Wallet.")
  }

  /// Invalid credential
  public static var tkErrorInvitationcredentialTitle: String {
    L10n.tr("Localizable", "tk_error_invitationcredential_title", fallback: "Invalid credential")
  }

  /// There is no matching credential in your swiyu Wallet.
  public static var tkErrorNosuchcredentialBody: String {
    L10n.tr("Localizable", "tk_error_nosuchcredential_body", fallback: "There is no matching credential in your swiyu Wallet.")
  }

  /// No matching credential available
  public static var tkErrorNosuchcredentialTitle: String {
    L10n.tr("Localizable", "tk_error_nosuchcredential_title", fallback: "No matching credential available")
  }

  /// This issuer is not registered.
  public static var tkErrorNotregisteredBody: String {
    L10n.tr("Localizable", "tk_error_notregistered_body", fallback: "This issuer is not registered.")
  }

  /// Unknown issuer
  public static var tkErrorNotregisteredTitle: String {
    L10n.tr("Localizable", "tk_error_notregistered_title", fallback: "Unknown issuer")
  }

  /// This QR code is no longer valid, please create a new one.
  public static var tkErrorNotusableBody: String {
    L10n.tr("Localizable", "tk_error_notusable_body", fallback: "This QR code is no longer valid, please create a new one.")
  }

  /// QR code no longer valid
  public static var tkErrorNotusableTitle: String {
    L10n.tr("Localizable", "tk_error_notusable_title", fallback: "QR code no longer valid")
  }

  /// Try again
  public static var tkErrorViewDefaultPrimaryButton: String {
    L10n.tr("Localizable", "tk_errorView_default_primaryButton", fallback: "Try again")
  }

  /// The following link will take you to an external website where you can create beta IDs.
  /// You can then import them and use them to test the swiyu Wallet.
  public static var tkGetBetaIdCreateBody: String {
    L10n.tr("Localizable", "tk_getBetaId_create_body", fallback: "The following link will take you to an external website where you can create beta IDs.\nYou can then import them and use them to test the swiyu Wallet.")
  }

  /// Create Beta-ID
  public static var tkGetBetaIdCreateTitle: String {
    L10n.tr("Localizable", "tk_getBetaId_create_title", fallback: "Create Beta-ID")
  }

  /// Add credentials
  public static var tkGetBetaIdFirstUseBody: String {
    L10n.tr("Localizable", "tk_getBetaId_firstUse_body", fallback: "Add credentials")
  }

  /// Empty wallet
  public static var tkGetBetaIdFirstUseTitle: String {
    L10n.tr("Localizable", "tk_getBetaId_firstUse_title", fallback: "Empty wallet")
  }

  /// Back
  public static var tkGlobalBack: String {
    L10n.tr("Localizable", "tk_global_back", fallback: "Back")
  }

  /// https://www.bcs.admin.ch/bcs-web/?lang=EN
  public static var tkGlobalBetaidUrl: String {
    L10n.tr("Localizable", "tk_global_betaid_url", fallback: "https://www.bcs.admin.ch/bcs-web/?lang=EN")
  }

  /// Cancel
  public static var tkGlobalCancel: String {
    L10n.tr("Localizable", "tk_global_cancel", fallback: "Cancel")
  }

  /// Change password
  public static var tkGlobalChangepassword: String {
    L10n.tr("Localizable", "tk_global_changepassword", fallback: "Change password")
  }

  /// Close
  public static var tkGlobalClose: String {
    L10n.tr("Localizable", "tk_global_close", fallback: "Close")
  }

  /// Close details
  public static var tkGlobalClosedetailsAlt: String {
    L10n.tr("Localizable", "tk_global_closedetails_alt", fallback: "Close details")
  }

  /// Next
  public static var tkGlobalContinue: String {
    L10n.tr("Localizable", "tk_global_continue", fallback: "Next")
  }

  /// Delete
  public static var tkGlobalDelete: String {
    L10n.tr("Localizable", "tk_global_delete", fallback: "Delete")
  }

  /// Empty
  public static var tkGlobalEmpty: String {
    L10n.tr("Localizable", "tk_global_empty", fallback: "Empty")
  }

  /// Link leaves the app
  public static var tkGlobalExternalLinkHint: String {
    L10n.tr("Localizable", "tk_global_externalLink_hint", fallback: "Link leaves the app")
  }

  /// Finish
  public static var tkGlobalFinish: String {
    L10n.tr("Localizable", "tk_global_finish", fallback: "Finish")
  }

  /// Create Beta-ID
  public static var tkGlobalGetbetaidPrimarybutton: String {
    L10n.tr("Localizable", "tk_global_getbetaid_primarybutton", fallback: "Create Beta-ID")
  }

  /// Password is hidden. Show password.
  public static var tkGlobalInvisibleAlt: String {
    L10n.tr("Localizable", "tk_global_invisible_alt", fallback: "Password is hidden. Show password.")
  }

  /// Login
  public static var tkGlobalLoginPrimarybutton: String {
    L10n.tr("Localizable", "tk_global_login_primarybutton", fallback: "Login")
  }

  /// More options
  public static var tkGlobalMoreoptionsAlt: String {
    L10n.tr("Localizable", "tk_global_moreoptions_alt", fallback: "More options")
  }

  /// New password
  public static var tkGlobalNewpassword: String {
    L10n.tr("Localizable", "tk_global_newpassword", fallback: "New password")
  }

  /// No thanks
  public static var tkGlobalNo: String {
    L10n.tr("Localizable", "tk_global_no", fallback: "No thanks")
  }

  /// Please wait
  public static var tkGlobalPleasewait: String {
    L10n.tr("Localizable", "tk_global_pleasewait", fallback: "Please wait")
  }

  /// Scan
  public static var tkGlobalScanPrimarybutton: String {
    L10n.tr("Localizable", "tk_global_scan_primarybutton", fallback: "Scan")
  }

  /// Scan
  public static var tkGlobalScanPrimarybuttonAlt: String {
    L10n.tr("Localizable", "tk_global_scan_primarybutton_alt", fallback: "Scan")
  }

  /// Sensitive
  public static var tkGlobalSensitiveData: String {
    L10n.tr("Localizable", "tk_global_sensitiveData", fallback: "Sensitive")
  }

  /// Sensitive information
  public static var tkGlobalSensitiveDataAlt: String {
    L10n.tr("Localizable", "tk_global_sensitiveData_alt", fallback: "Sensitive information")
  }

  /// Sensitive information
  public static var tkGlobalSensitiveDataHint: String {
    L10n.tr("Localizable", "tk_global_sensitiveData_hint", fallback: "Sensitive information")
  }

  /// Still loading
  public static var tkGlobalStillworking: String {
    L10n.tr("Localizable", "tk_global_stillworking", fallback: "Still loading")
  }

  /// https://apps.apple.com/ch/app/swiyu/id6737259614
  public static var tkGlobalStoreLink: String {
    L10n.tr("Localizable", "tk_global_store_link", fallback: "https://apps.apple.com/ch/app/swiyu/id6737259614")
  }

  /// Go to settings
  public static var tkGlobalTothesettings: String {
    L10n.tr("Localizable", "tk_global_tothesettings", fallback: "Go to settings")
  }

  /// Password is visible. Hide password.
  public static var tkGlobalVisibleAlt: String {
    L10n.tr("Localizable", "tk_global_visible_alt", fallback: "Password is visible. Hide password.")
  }

  /// Welcome back
  public static var tkGlobalWelcomeback: String {
    L10n.tr("Localizable", "tk_global_welcomeback", fallback: "Welcome back")
  }

  /// Report incorrect details
  public static var tkGlobalWrongdata: String {
    L10n.tr("Localizable", "tk_global_wrongdata", fallback: "Report incorrect details")
  }

  /// swiyu Wallet home screen
  public static var tkHomeHomescreenAlt: String {
    L10n.tr("Localizable", "tk_home_homescreen_alt", fallback: "swiyu Wallet home screen")
  }

  /// Refresh
  public static var tkHomeHomescreenEmptyStateButton: String {
    L10n.tr("Localizable", "tk_home_homescreen_emptyState_button", fallback: "Refresh")
  }

  /// Credential has been added.
  public static var tkHomeNotificationCredentialAccepted: String {
    L10n.tr("Localizable", "tk_home_notification_credential_accepted", fallback: "Credential has been added.")
  }

  /// Credential has been declined.
  public static var tkHomeNotificationCredentialDeclined: String {
    L10n.tr("Localizable", "tk_home_notification_credential_declined", fallback: "Credential has been declined.")
  }

  /// Credential has been deleted.
  public static var tkHomeNotificationCredentialDeleted: String {
    L10n.tr("Localizable", "tk_home_notification_credential_deleted", fallback: "Credential has been deleted.")
  }

  /// Wallet
  public static var tkHomeTitle: String {
    L10n.tr("Localizable", "tk_home_title", fallback: "Wallet")
  }

  /// Authorised issuance
  public static var tkIssuerLegitimate: String {
    L10n.tr("Localizable", "tk_issuer_legitimate", fallback: "Authorised issuance")
  }

  /// Unknown
  public static var tkIssuerNotInSystem: String {
    L10n.tr("Localizable", "tk_issuer_notInSystem", fallback: "Unknown")
  }

  /// Not authorised issuance
  public static var tkIssuerNotLegitimate: String {
    L10n.tr("Localizable", "tk_issuer_notLegitimate", fallback: "Not authorised issuance")
  }

  /// Not verified
  public static var tkIssuerNotTrusted: String {
    L10n.tr("Localizable", "tk_issuer_notTrusted", fallback: "Not verified")
  }

  /// Verified
  public static var tkIssuerTrusted: String {
    L10n.tr("Localizable", "tk_issuer_trusted", fallback: "Verified")
  }

  /// Preparing your camera...
  public static var tkLoaderInitializationPrimary: String {
    L10n.tr("Localizable", "tk_loader_initialization_primary", fallback: "Preparing your camera...")
  }

  /// Please wait while we set everything up.
  public static var tkLoaderInitializationSecondary: String {
    L10n.tr("Localizable", "tk_loader_initialization_secondary", fallback: "Please wait while we set everything up.")
  }

  /// Enter password
  public static var tkLoginFacenotrecognised2Body: String {
    L10n.tr("Localizable", "tk_login_facenotrecognised2_body", fallback: "Enter password")
  }

  /// Forgotten your password?
  public static var tkLoginLockedSecondarybuttonText: String {
    L10n.tr("Localizable", "tk_login_locked_secondarybutton_text", fallback: "Forgotten your password?")
  }

  /// https://www.eid.admin.ch/en/help-swiyu-safety-e
  public static var tkLoginLockedSecondarybuttonValue: String {
    L10n.tr("Localizable", "tk_login_locked_secondarybutton_value", fallback: "https://www.eid.admin.ch/en/help-swiyu-safety-e")
  }

  /// The swiyu Wallet is currently not available. Please try again later.
  public static var tkLoginLockedTitle: String {
    L10n.tr("Localizable", "tk_login_locked_title", fallback: "The swiyu Wallet is currently not available. Please try again later.")
  }

  /// Enter swiyu app password
  public static var tkLoginPasswordAlt: String {
    L10n.tr("Localizable", "tk_login_password_alt", fallback: "Enter swiyu app password")
  }

  /// Please enter your password:
  public static var tkLoginPasswordBody: String {
    L10n.tr("Localizable", "tk_login_password_body", fallback: "Please enter your password:")
  }

  /// Password
  public static var tkLoginPasswordNote: String {
    L10n.tr("Localizable", "tk_login_password_note", fallback: "Password")
  }

  /// The password is incorrect. Please try again.
  public static var tkLoginPasswordfailedNotification: String {
    L10n.tr("Localizable", "tk_login_passwordfailed_notification", fallback: "The password is incorrect. Please try again.")
  }

  /// The swiyu Wallet is locked
  public static var tkLoginVariantBody: String {
    L10n.tr("Localizable", "tk_login_variant_body", fallback: "The swiyu Wallet is locked")
  }

  /// Create Beta-ID
  public static var tkMenuHomeListAdd: String {
    L10n.tr("Localizable", "tk_menu_homeList_add", fallback: "Create Beta-ID")
  }

  /// Help & Contact
  public static var tkMenuHomeListHelp: String {
    L10n.tr("Localizable", "tk_menu_homeList_help", fallback: "Help & Contact")
  }

  /// Order e-ID
  public static var tkMenuHomeListOrderEid: String {
    L10n.tr("Localizable", "tk_menu_homeList_orderEid", fallback: "Order e-ID")
  }

  /// Settings
  public static var tkMenuHomeListSettings: String {
    L10n.tr("Localizable", "tk_menu_homeList_settings", fallback: "Settings")
  }

  /// During a data request, more information about me was requested than necessary.
  public static var tkNonComplianceListExcessiveDataBody: String {
    L10n.tr("Localizable", "tk_nonCompliance_list_excessiveData_body", fallback: "During a data request, more information about me was requested than necessary.")
  }

  /// Excessive data request
  public static var tkNonComplianceListExcessiveDataTitle: String {
    L10n.tr("Localizable", "tk_nonCompliance_list_excessiveData_title", fallback: "Excessive data request")
  }

  /// Attention: Until the official launch of swiyu, reports will not be reviewed, and verifiers will therefore not be sanctioned for misconduct.
  /// The categories are not final yet.
  public static var tkNonComplianceListFooter: String {
    L10n.tr("Localizable", "tk_nonCompliance_list_footer", fallback: "Attention: Until the official launch of swiyu, reports will not be reviewed, and verifiers will therefore not be sanctioned for misconduct.\nThe categories are not final yet.")
  }

  /// What would you like to report?
  public static var tkNonComplianceListTitle: String {
    L10n.tr("Localizable", "tk_nonCompliance_list_title", fallback: "What would you like to report?")
  }

  /// You are reporting this organization
  public static var tkNonComplianceReportFormActorFooter: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_actor_footer", fallback: "You are reporting this organization")
  }

  /// Providing your email address is optional and it will only be used to communicate about the case.
  public static var tkNonComplianceReportFormContactFooter: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_contact_footer", fallback: "Providing your email address is optional and it will only be used to communicate about the case.")
  }

  /// name@example.ch
  public static var tkNonComplianceReportFormContactPlaceholder: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_contact_placeholder", fallback: "name@example.ch")
  }

  /// Email contact (optional)
  public static var tkNonComplianceReportFormContactTitle: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_contact_title", fallback: "Email contact (optional)")
  }

  /// Please enter a valid email address
  public static var tkNonComplianceReportFormContactValidation: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_contact_validation", fallback: "Please enter a valid email address")
  }

  /// Please write at least 20 characters
  public static var tkNonComplianceReportFormDescriptionFooter: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_description_footer", fallback: "Please write at least 20 characters")
  }

  /// Please write a maximum of 500 characters.
  public static var tkNonComplianceReportFormDescriptionMaxCharacterFooter: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_description_maxCharacter_footer", fallback: "Please write a maximum of 500 characters.")
  }

  /// Please describe the incident as precisely as possible…
  public static var tkNonComplianceReportFormDescriptionPlaceholder: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_description_placeholder", fallback: "Please describe the incident as precisely as possible…")
  }

  /// Save
  public static var tkNonComplianceReportFormDescriptionSaveButton: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_description_save_button", fallback: "Save")
  }

  /// Description*
  public static var tkNonComplianceReportFormDescriptionTitle: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_description_title", fallback: "Description*")
  }

  /// Description mandatory
  public static var tkNonComplianceReportFormDescriptionTitleAlt: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_description_title_alt", fallback: "Description mandatory")
  }

  /// Report
  public static var tkNonComplianceReportFormReportSectionTitle: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_reportSection_title", fallback: "Report")
  }

  /// Send
  public static var tkNonComplianceReportFormSendButton: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_send_button", fallback: "Send")
  }

  /// In the next step, record your report for the responsible authority.
  /// Please also specify which data was requested without authorization.
  public static var tkNonComplianceReportInfoBody: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_info_body", fallback: "In the next step, record your report for the responsible authority. \nPlease also specify which data was requested without authorization.")
  }

  /// Show more tips
  public static var tkNonComplianceReportInfoMoreInformationLinkText: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_info_moreInformation_link_text", fallback: "Show more tips")
  }

  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var tkNonComplianceReportInfoMoreInformationLinkValue: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_info_moreInformation_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  }

  /// Recommended procedure
  public static var tkNonComplianceReportInfoTitle: String {
    L10n.tr("Localizable", "tk_nonCompliance_report_info_title", fallback: "Recommended procedure")
  }

  /// Excessive data request
  public static var tkNonComplianceReportExcessiveDataTitle: String {
    L10n.tr("Localizable", "tk_nonCompliance_reportExcessiveData_title", fallback: "Excessive data request")
  }

  /// Allow
  public static var tkOnboardingAnalyticsButtonPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_analytics_button_primary", fallback: "Allow")
  }

  /// Do not allow
  public static var tkOnboardingAnalyticsButtonSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_analytics_button_secondary", fallback: "Do not allow")
  }

  /// Contribute anonymously to improving the app
  public static var tkOnboardingAnalyticsPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_analytics_primary", fallback: "Contribute anonymously to improving the app")
  }

  /// Take advantage of an app tailored to your needs. Do you want to share your anonymous user data with the development team in return?
  public static var tkOnboardingAnalyticsSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_analytics_secondary", fallback: "Take advantage of an app tailored to your needs. Do you want to share your anonymous user data with the development team in return?")
  }

  /// Data protection and security
  public static var tkOnboardingAnalyticsTertiaryLinkText: String {
    L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_text", fallback: "Data protection and security")
  }

  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var tkOnboardingAnalyticsTertiaryLinkValue: String {
    L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  }

  /// Yes, use
  public static var tkOnboardingBiometricsPermissionButtonPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermission_button_primary", fallback: "Yes, use")
  }

  /// You can still use your password if biometric authentication does not work.
  public static var tkOnboardingBiometricsPermissionReason: String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermission_reason", fallback: "You can still use your password if biometric authentication does not work.")
  }

  /// Go to settings
  public static var tkOnboardingBiometricsPermissionDisabledButtonPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermissionDisabled_button_primary", fallback: "Go to settings")
  }

  /// Passwort muss mindestens 6 Zeichen lang sein
  public static var tkOnboardingCharactersSubtitle: String {
    L10n.tr("Localizable", "tk_onboarding_characters_subtitle", fallback: "Passwort muss mindestens 6 Zeichen lang sein")
  }

  /// All set up
  public static var tkOnboardingDonePrimary: String {
    L10n.tr("Localizable", "tk_onboarding_done_primary", fallback: "All set up")
  }

  /// Your swiyu Wallet is now optimally protected against unauthorized access.
  public static var tkOnboardingDoneSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_done_secondary", fallback: "Your swiyu Wallet is now optimally protected against unauthorized access.")
  }

  /// Try again
  public static var tkOnboardingDoneErrorButtonPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_doneError_button_primary", fallback: "Try again")
  }

  /// Something went wrong
  public static var tkOnboardingDoneErrorPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_doneError_primary", fallback: "Something went wrong")
  }

  /// We are currently unable to provide the app. Please try again later.
  public static var tkOnboardingDoneErrorSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_doneError_secondary", fallback: "We are currently unable to provide the app. Please try again later.")
  }

  /// Overview of your activities
  public static var tkOnboardingIntroductionStepActivitiesPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_activities_primary", fallback: "Overview of your activities")
  }

  /// Keep track of all credentials you have received and the data you have shared. This data is stored only locally on your phone, and you can disable this feature at any time in the settings
  public static var tkOnboardingIntroductionStepActivitiesSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_activities_secondary", fallback: "Keep track of all credentials you have received and the data you have shared. This data is stored only locally on your phone, and you can disable this feature at any time in the settings")
  }

  /// Never forget your ID card again.
  public static var tkOnboardingIntroductionStepNeverForgetPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_neverForget_primary", fallback: "Never forget your ID card again.")
  }

  /// Thanks to the swiyu Wallet, you always carry your identity documents with you on your mobile phone.
  public static var tkOnboardingIntroductionStepNeverForgetSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_neverForget_secondary", fallback: "Thanks to the swiyu Wallet, you always carry your identity documents with you on your mobile phone.")
  }

  /// Start
  public static var tkOnboardingIntroductionStepSecurityButtonPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_security_button_primary", fallback: "Start")
  }

  /// Securely store digital credentials
  public static var tkOnboardingIntroductionStepSecurityPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_security_primary", fallback: "Securely store digital credentials")
  }

  /// Welcome to the onboarding of the swiyu Wallet
  public static var tkOnboardingIntroductionStepSecurityScreenAlt: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_security_screen_alt", fallback: "Welcome to the onboarding of the swiyu Wallet")
  }

  /// Your identity data is encrypted and stored locally in the swiyu Wallet on your mobile phone.
  public static var tkOnboardingIntroductionStepSecuritySecondary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_security_secondary", fallback: "Your identity data is encrypted and stored locally in the swiyu Wallet on your mobile phone.")
  }

  /// Your data belongs to you
  public static var tkOnboardingIntroductionStepYourDataPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_primary", fallback: "Your data belongs to you")
  }

  /// You control who can verify your data and when.
  /// Without consent, there is no access.
  public static var tkOnboardingIntroductionStepYourDataSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_secondary", fallback: "You control who can verify your data and when.\nWithout consent, there is no access.")
  }

  /// More about decentralized data storage
  public static var tkOnboardingIntroductionStepYourDataTertiaryLinkText: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_text", fallback: "More about decentralized data storage")
  }

  /// https://www.eid.admin.ch/en/technology
  public static var tkOnboardingIntroductionStepYourDataTertiaryLinkValue: String {
    L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_value", fallback: "https://www.eid.admin.ch/en/technology")
  }

  /// The passwords do not match. Please try again.
  public static var tkOnboardingNopasswordmismatchNotification: String {
    L10n.tr("Localizable", "tk_onboarding_nopasswordmismatch_notification", fallback: "The passwords do not match. Please try again.")
  }

  /// Password is empty
  public static var tkOnboardingPasswordErrorEmpty: String {
    L10n.tr("Localizable", "tk_onboarding_password_error_empty", fallback: "Password is empty")
  }

  /// Enter swiyu app password
  public static var tkOnboardingPasswordInputAlt: String {
    L10n.tr("Localizable", "tk_onboarding_password_input_alt", fallback: "Enter swiyu app password")
  }

  /// Password
  public static var tkOnboardingPasswordInputPlaceholder: String {
    L10n.tr("Localizable", "tk_onboarding_password_input_placeholder", fallback: "Password")
  }

  /// Password must be at least 6 characters
  public static var tkOnboardingPasswordInputSubtitle: String {
    L10n.tr("Localizable", "tk_onboarding_password_input_subtitle", fallback: "Password must be at least 6 characters")
  }

  /// Enter password
  public static var tkOnboardingPasswordTitle: String {
    L10n.tr("Localizable", "tk_onboarding_password_title", fallback: "Enter password")
  }

  /// Enter swiyu app password
  public static var tkOnboardingPasswordConfirmationInputAlt: String {
    L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_alt", fallback: "Enter swiyu app password")
  }

  /// Incorrect password. Please try again.
  public static var tkOnboardingPasswordConfirmationInputErrorWrongPassword: String {
    L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_error_wrongPassword", fallback: "Incorrect password. Please try again.")
  }

  /// Password
  public static var tkOnboardingPasswordConfirmationInputPlaceholder: String {
    L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_placeholder", fallback: "Password")
  }

  /// Confirm password
  public static var tkOnboardingPasswordConfirmationTitle: String {
    L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_title", fallback: "Confirm password")
  }

  /// Create password
  public static var tkOnboardingPasswordIntroductionButtonPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_button_primary", fallback: "Create password")
  }

  /// ou have entered the wrong password too many times.
  /// Please create a new password.
  public static var tkOnboardingPasswordIntroductionErrorTooManyAttempts: String {
    L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_error_tooManyAttempts", fallback: "ou have entered the wrong password too many times. \nPlease create a new password.")
  }

  /// Secure app with a password
  public static var tkOnboardingPasswordIntroductionPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_primary", fallback: "Secure app with a password")
  }

  /// Protect your app from unauthorised access.
  public static var tkOnboardingPasswordIntroductionSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_secondary", fallback: "Protect your app from unauthorised access.")
  }

  /// Password must be at least 6 characters
  public static var tkOnboardingPasswordlengthNotification: String {
    L10n.tr("Localizable", "tk_onboarding_passwordlength_notification", fallback: "Password must be at least 6 characters")
  }

  /// Please wait…
  public static var tkOnboardingSetupPrimary: String {
    L10n.tr("Localizable", "tk_onboarding_setup_primary", fallback: "Please wait…")
  }

  /// Your settings are being applied. This may take up to 30 seconds.
  public static var tkOnboardingSetupSecondary: String {
    L10n.tr("Localizable", "tk_onboarding_setup_secondary", fallback: "Your settings are being applied. This may take up to 30 seconds.")
  }

  /// Select credential
  public static var tkPresentCompatibleCredentialsPrimary: String {
    L10n.tr("Localizable", "tk_present_compatibleCredentials_primary", fallback: "Select credential")
  }

  /// There is no credential in your swiyu Wallet yet
  public static var tkPresentCredentialNotFoundBody: String {
    L10n.tr("Localizable", "tk_present_credentialNotFound_body", fallback: "There is no credential in your swiyu Wallet yet")
  }

  /// No matching credential available
  public static var tkPresentCredentialNotFoundTitle: String {
    L10n.tr("Localizable", "tk_present_credentialNotFound_title", fallback: "No matching credential available")
  }

  /// Transaction_data is not supported
  public static var tkPresentErrorInvalidTransactionDataSecondary: String {
    L10n.tr("Localizable", "tk_present_error_invalidTransactionData_secondary", fallback: "Transaction_data is not supported")
  }

  /// Error
  public static var tkPresentErrorPrimary: String {
    L10n.tr("Localizable", "tk_present_error_primary", fallback: "Error")
  }

  /// The swiyu Wallet did not accept the authorization request
  public static var tkPresentErrorSecondary: String {
    L10n.tr("Localizable", "tk_present_error_secondary", fallback: "The swiyu Wallet did not accept the authorization request")
  }

  /// Verification aborted
  public static var tkPresentResultCanceledVerificationPrimary: String {
    L10n.tr("Localizable", "tk_present_result_canceledVerification_primary", fallback: "Verification aborted")
  }

  /// No data was transmitted.
  public static var tkPresentResultCanceledVerificationSecondary: String {
    L10n.tr("Localizable", "tk_present_result_canceledVerification_secondary", fallback: "No data was transmitted.")
  }

  /// Confirmation
  public static var tkPresentResultConfirmAlt: String {
    L10n.tr("Localizable", "tk_present_result_confirm_alt", fallback: "Confirmation")
  }

  /// Your credential has been successfully submitted and is being verified
  public static var tkPresentResultDataTransmittedBody: String {
    L10n.tr("Localizable", "tk_present_result_data_transmitted_body", fallback: "Your credential has been successfully submitted and is being verified")
  }

  /// Your data has been submitted.
  public static var tkPresentResultDataTransmittedTitle: String {
    L10n.tr("Localizable", "tk_present_result_data_transmitted_title", fallback: "Your data has been submitted.")
  }

  /// Data not submitted
  public static var tkPresentResultDeclinedPrimary: String {
    L10n.tr("Localizable", "tk_present_result_declined_primary", fallback: "Data not submitted")
  }

  /// Try again
  public static var tkPresentResultErrorButtonRetry: String {
    L10n.tr("Localizable", "tk_present_result_error_button_retry", fallback: "Try again")
  }

  /// Oops, something went wrong!
  public static var tkPresentResultErrorPrimary: String {
    L10n.tr("Localizable", "tk_present_result_error_primary", fallback: "Oops, something went wrong!")
  }

  /// Please try again
  public static var tkPresentResultErrorSecondary: String {
    L10n.tr("Localizable", "tk_present_result_error_secondary", fallback: "Please try again")
  }

  /// The verification of the transferred data was not successful.
  public static var tkPresentResultInvalidCredentialPrimary: String {
    L10n.tr("Localizable", "tk_present_result_invalidCredential_primary", fallback: "The verification of the transferred data was not successful.")
  }

  /// Please check the validity of your credential.
  public static var tkPresentResultInvalidCredentialSecondary: String {
    L10n.tr("Localizable", "tk_present_result_invalidCredential_secondary", fallback: "Please check the validity of your credential.")
  }

  /// Your data has been successfully submitted.
  public static var tkPresentResultSuccessPrimary: String {
    L10n.tr("Localizable", "tk_present_result_success_primary", fallback: "Your data has been successfully submitted.")
  }

  /// Warning
  public static var tkPresentResultWarningAlt: String {
    L10n.tr("Localizable", "tk_present_result_warning_alt", fallback: "Warning")
  }

  /// Your credential is expired.
  public static var tkPresentReviewBusinessExpiryWarningPrimary: String {
    L10n.tr("Localizable", "tk_present_review_businessExpiryWarning_primary", fallback: "Your credential is expired.")
  }

  /// Your credential is expired. Would you like to share the information anyway?
  public static var tkPresentReviewBusinessExpiryWarningSecondary: String {
    L10n.tr("Localizable", "tk_present_review_businessExpiryWarning_secondary", fallback: "Your credential is expired. Would you like to share the information anyway?")
  }

  /// Share data
  public static var tkPresentReviewConfirmPresentationButtonPrimary: String {
    L10n.tr("Localizable", "tk_present_review_confirmPresentation_button_primary", fallback: "Share data")
  }

  /// Decline data sharing
  public static var tkPresentReviewConfirmPresentationButtonSecondary: String {
    L10n.tr("Localizable", "tk_present_review_confirmPresentation_button_secondary", fallback: "Decline data sharing")
  }

  /// You are sharing your data with an unknown organization.
  public static var tkPresentReviewConfirmPresentationPrimary: String {
    L10n.tr("Localizable", "tk_present_review_confirmPresentation_primary", fallback: "You are sharing your data with an unknown organization.")
  }

  /// This organization is not part of the swiyu ecosystem. Its trustworthiness cannot be verified. Do you still want to share this data?
  public static var tkPresentReviewConfirmPresentationSecondary: String {
    L10n.tr("Localizable", "tk_present_review_confirmPresentation_secondary", fallback: "This organization is not part of the swiyu ecosystem. Its trustworthiness cannot be verified. Do you still want to share this data?")
  }

  /// Requested data
  public static var tkPresentReviewCredentialDataSectionPrimary: String {
    L10n.tr("Localizable", "tk_present_review_credential_dataSection_primary", fallback: "Requested data")
  }

  /// Please wait
  public static var tkPresentReviewLoading: String {
    L10n.tr("Localizable", "tk_present_review_loading", fallback: "Please wait")
  }

  /// Please wait. Your information is being sent.
  public static var tkPresentReviewLoadingAlt: String {
    L10n.tr("Localizable", "tk_present_review_loading_alt", fallback: "Please wait. Your information is being sent.")
  }

  /// Allow
  public static var tkPresentReviewPrimaryButton: String {
    L10n.tr("Localizable", "tk_present_review_primaryButton", fallback: "Allow")
  }

  /// Submit data
  public static var tkPresentReviewPrimaryButtonAlt: String {
    L10n.tr("Localizable", "tk_present_review_primaryButton_alt", fallback: "Submit data")
  }

  /// Decline
  public static var tkPresentReviewSecondaryButton: String {
    L10n.tr("Localizable", "tk_present_review_secondaryButton", fallback: "Decline")
  }

  /// Decline Request
  public static var tkPresentReviewSecondaryButtonAlt: String {
    L10n.tr("Localizable", "tk_present_review_secondaryButton_alt", fallback: "Decline Request")
  }

  /// Please log in with your password
  public static var tkPresentReviewSessionTimeoutBody: String {
    L10n.tr("Localizable", "tk_present_review_sessionTimeout_body", fallback: "Please log in with your password")
  }

  /// Login
  public static var tkPresentReviewSessionTimeoutPrimaryButton: String {
    L10n.tr("Localizable", "tk_present_review_sessionTimeout_primaryButton", fallback: "Login")
  }

  /// Session timeout
  public static var tkPresentReviewSessionTimeoutTitle: String {
    L10n.tr("Localizable", "tk_present_review_sessionTimeout_title", fallback: "Session timeout")
  }

  /// Your credential is suspended.
  public static var tkPresentReviewSuspendedWarningPrimary: String {
    L10n.tr("Localizable", "tk_present_review_suspendedWarning_primary", fallback: "Your credential is suspended.")
  }

  /// Your credential is suspended. Would you like to share the information anyway?
  public static var tkPresentReviewSuspendedWarningSecondary: String {
    L10n.tr("Localizable", "tk_present_review_suspendedWarning_secondary", fallback: "Your credential is suspended. Would you like to share the information anyway?")
  }

  /// Unregistered Request
  public static var tkPresentReviewUnregisteredRequestWarningPrimary: String {
    L10n.tr("Localizable", "tk_present_review_unregisteredRequestWarning_primary", fallback: "Unregistered Request")
  }

  /// This request is not registered in the Confederation’s system. Accepting may pose a risk to your data.
  public static var tkPresentReviewUnregisteredRequestWarningSecondary: String {
    L10n.tr("Localizable", "tk_present_review_unregisteredRequestWarning_secondary", fallback: "This request is not registered in the Confederation’s system. Accepting may pose a risk to your data.")
  }

  /// This request is not registered in the Confederation’s system. Accepting may pose a risk to your data.
  public static var tkPresentUnregisteredRequestBody: String {
    L10n.tr("Localizable", "tk_present_unregisteredRequest_body", fallback: "This request is not registered in the Confederation’s system. Accepting may pose a risk to your data.")
  }

  /// Proceed
  public static var tkPresentUnregisteredRequestPrimaryButton: String {
    L10n.tr("Localizable", "tk_present_unregisteredRequest_primaryButton", fallback: "Proceed")
  }

  /// Unregistered Request
  public static var tkPresentUnregisteredRequestTitle: String {
    L10n.tr("Localizable", "tk_present_unregisteredRequest_title", fallback: "Unregistered Request")
  }

  /// This request is not registered in the Confederation’s system. Accepting may pose a risk to your data.
  public static var tkPresentUnregisteredRequestWarning: String {
    L10n.tr("Localizable", "tk_present_unregisteredRequest_warning", fallback: "This request is not registered in the Confederation’s system. Accepting may pose a risk to your data.")
  }

  /// Unknown verificator
  public static var tkPresentVerifierNameUnknown: String {
    L10n.tr("Localizable", "tk_present_verifier_name_unknown", fallback: "Unknown verificator")
  }

  /// Close QR code
  public static var tkProximityEngagementCloseAlt: String {
    L10n.tr("Localizable", "tk_proximity_engagement_close_alt", fallback: "Close QR code")
  }

  /// Your personal information is shared only with your consent. Only show your swiyu code to trusted parties and take a moment to check the next steps.
  public static var tkProximityEngagementPrimary: String {
    L10n.tr("Localizable", "tk_proximity_engagement_primary", fallback: "Your personal information is shared only with your consent. Only show your swiyu code to trusted parties and take a moment to check the next steps.")
  }

  /// Your swiyu QR Code
  public static var tkProximityEngagementQrCodeAltText: String {
    L10n.tr("Localizable", "tk_proximity_engagement_qrCode_altText", fallback: "Your swiyu QR Code")
  }

  /// QR code
  public static var tkProximityEngagementTab: String {
    L10n.tr("Localizable", "tk_proximity_engagement_tab", fallback: "QR code")
  }

  /// QR code
  public static var tkProximityEngagementTitle: String {
    L10n.tr("Localizable", "tk_proximity_engagement_title", fallback: "QR code")
  }

  /// Enable push notifications in your mobile phone settings so that we can notify you as soon as your request is ready
  public static var tkPushNotificationPermissionBody: String {
    L10n.tr("Localizable", "tk_pushNotificationPermission_body", fallback: "Enable push notifications in your mobile phone settings so that we can notify you as soon as your request is ready")
  }

  /// Enable push notifications in your mobile phone settings so we can notify you as soon as your request is ready.
  public static var tkPushNotificationPermissionDeniedBody: String {
    L10n.tr("Localizable", "tk_pushNotificationPermission_denied_body", fallback: "Enable push notifications in your mobile phone settings so we can notify you as soon as your request is ready.")
  }

  /// Enable push notifications in your mobile phone settings so we can notify you as soon as your request is ready.
  public static var tkPushNotificationPermissionDeniedTitle: String {
    L10n.tr("Localizable", "tk_pushNotificationPermission_denied_title", fallback: "Enable push notifications in your mobile phone settings so we can notify you as soon as your request is ready.")
  }

  /// Push notifications could not be enabled.
  /// Try again or skip this step.
  public static var tkPushNotificationPermissionErrorBody: String {
    L10n.tr("Localizable", "tk_pushNotificationPermission_error_body", fallback: "Push notifications could not be enabled.\nTry again or skip this step.")
  }

  /// Notifications could not be enabled
  public static var tkPushNotificationPermissionErrorTitle: String {
    L10n.tr("Localizable", "tk_pushNotificationPermission_error_title", fallback: "Notifications could not be enabled")
  }

  /// Skip
  public static var tkPushNotificationPermissionSecondaryButton: String {
    L10n.tr("Localizable", "tk_pushNotificationPermission_secondaryButton", fallback: "Skip")
  }

  /// Do not miss when your request is ready
  public static var tkPushNotificationPermissionTitle: String {
    L10n.tr("Localizable", "tk_pushNotificationPermission_title", fallback: "Do not miss when your request is ready")
  }

  /// Close QR code scanner
  public static var tkQrscannerButtonCloseAlt: String {
    L10n.tr("Localizable", "tk_qrscanner_button_close_alt", fallback: "Close QR code scanner")
  }

  /// Camera is running. QR code is being searched via camera.
  public static var tkQrscannerCameraFeedAlt: String {
    L10n.tr("Localizable", "tk_qrscanner_camera_feed_alt", fallback: "Camera is running. QR code is being searched via camera.")
  }

  /// Camera off
  public static var tkQrscannerCameraOffAlt: String {
    L10n.tr("Localizable", "tk_qrscanner_camera_off_alt", fallback: "Camera off")
  }

  /// Flashlight off. Turn on.
  public static var tkQrscannerLightoffLabel: String {
    L10n.tr("Localizable", "tk_qrscanner_lightoff_label", fallback: "Flashlight off. Turn on.")
  }

  /// Flashlight on. Turn off.
  public static var tkQrscannerLightonLabel: String {
    L10n.tr("Localizable", "tk_qrscanner_lighton_label", fallback: "Flashlight on. Turn off.")
  }

  /// Flashlight is on
  public static var tkQrscannerLightonTitle: String {
    L10n.tr("Localizable", "tk_qrscanner_lighton_title", fallback: "Flashlight is on")
  }

  /// Close note
  public static var tkQrscannerNotificationCloseButtonAlt: String {
    L10n.tr("Localizable", "tk_qrscanner_notification_closeButton_alt", fallback: "Close note")
  }

  /// QR code scanned
  public static var tkQrscannerProcessingAlt: String {
    L10n.tr("Localizable", "tk_qrscanner_processing_alt", fallback: "QR code scanned")
  }

  /// Scan the QR code to confirm your identity or receive a document or credential.
  public static var tkQrscannerScanningBody: String {
    L10n.tr("Localizable", "tk_qrscanner_scanning_body", fallback: "Scan the QR code to confirm your identity or receive a document or credential.")
  }

  /// Scan the QR code to confirm your identity or receive a document or credential.
  ///
  /// No data is shared without consent.
  public static var tkQrscannerScanningOverlayBody: String {
    L10n.tr("Localizable", "tk_qrscanner_scanning_overlay_body", fallback: "Scan the QR code to confirm your identity or receive a document or credential.\n\nNo data is shared without consent.")
  }

  /// Scan QR code
  public static var tkQrscannerScanningTitle: String {
    L10n.tr("Localizable", "tk_qrscanner_scanning_title", fallback: "Scan QR code")
  }

  /// For security reasons, please sign in with the swiyu password.
  public static var tkQrscannerSessionTimeoutBody: String {
    L10n.tr("Localizable", "tk_qrscanner_sessionTimeout_body", fallback: "For security reasons, please sign in with the swiyu password.")
  }

  /// Login
  public static var tkQrscannerSessionTimeoutPrimaryButton: String {
    L10n.tr("Localizable", "tk_qrscanner_sessionTimeout_primaryButton", fallback: "Login")
  }

  /// Session timeout
  public static var tkQrscannerSessionTimeoutTitle: String {
    L10n.tr("Localizable", "tk_qrscanner_sessionTimeout_title", fallback: "Session timeout")
  }

  /// Securely connected – with Bluetooth
  public static var tkReceiveBluetoothPermissionPrimary: String {
    L10n.tr("Localizable", "tk_receive_bluetooth_permission_primary", fallback: "Securely connected – with Bluetooth")
  }

  /// To transfer your data securely, the app requires an active Bluetooth connection.
  /// This ensures that everything reaches its destination – encrypted and reliable.
  public static var tkReceiveBluetoothPermissionSecondary: String {
    L10n.tr("Localizable", "tk_receive_bluetooth_permission_secondary", fallback: "To transfer your data securely, the app requires an active Bluetooth connection.\nThis ensures that everything reaches its destination – encrypted and reliable.")
  }

  /// The use of the camera is a core function for the swiyu Wallet.
  /// Without camera access, you cannot obtain or use identity documents or credentials.
  public static var tkReceiveCameraaccessneeded1Body: String {
    L10n.tr("Localizable", "tk_receive_cameraaccessneeded1_body", fallback: "The use of the camera is a core function for the swiyu Wallet.\nWithout camera access, you cannot obtain or use identity documents or credentials.")
  }

  /// swiyu Wallet would like to use the camera
  public static var tkReceiveCameraaccessneeded1Title: String {
    L10n.tr("Localizable", "tk_receive_cameraaccessneeded1_title", fallback: "swiyu Wallet would like to use the camera")
  }

  /// The swiyu Wallet of the Swiss Confederation requires camera access to add your electronic identity (e-ID) and other credentials or to identify yourself.
  /// Only in this way can you take a picture of your ID and your face, and scan QR codes.
  public static var tkReceiveCameraaccessneeded3Body: String {
    L10n.tr("Localizable", "tk_receive_cameraaccessneeded3_body", fallback: "The swiyu Wallet of the Swiss Confederation requires camera access to add your electronic identity (e-ID) and other credentials or to identify yourself.\nOnly in this way can you take a picture of your ID and your face, and scan QR codes.")
  }

  /// Allow access to camera
  public static var tkReceiveCameraaccessneeded3Title: String {
    L10n.tr("Localizable", "tk_receive_cameraaccessneeded3_title", fallback: "Allow access to camera")
  }

  /// Add
  public static var tkReceiveCredentialOfferButtonAccept: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_button_accept", fallback: "Add")
  }

  /// Decline
  public static var tkReceiveCredentialOfferButtonDecline: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_button_decline", fallback: "Decline")
  }

  /// Accept credential
  public static var tkReceiveCredentialOfferConfirmIssuanceButtonPrimary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_confirmIssuance_button_primary", fallback: "Accept credential")
  }

  /// Decline credential
  public static var tkReceiveCredentialOfferConfirmIssuanceButtonSecondary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_confirmIssuance_button_secondary", fallback: "Decline credential")
  }

  /// Are you sure you want to accept a credential from an unknown issuer?
  public static var tkReceiveCredentialOfferConfirmIssuancePrimary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_confirmIssuance_primary", fallback: "Are you sure you want to accept a credential from an unknown issuer?")
  }

  /// This issuer is not part of the swiyu ecosystem.
  /// The trustworthiness can not be ensured.
  /// Would you like to proceed?
  public static var tkReceiveCredentialOfferConfirmIssuanceSecondary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_confirmIssuance_secondary", fallback: "This issuer is not part of the swiyu ecosystem. \nThe trustworthiness can not be ensured. \nWould you like to proceed?")
  }

  /// Would like to issue the following credential:
  public static var tkReceiveCredentialOfferHeaderSectionSecondary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_headerSection_secondary", fallback: "Would like to issue the following credential:")
  }

  /// Found any incorrect data?
  public static var tkReceiveCredentialOfferWrongDataPrimary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_wrongData_primary", fallback: "Found any incorrect data?")
  }

  /// Once issued, a credential cannot be changed.
  ///
  /// If you notice an error in your data, please contact the issuer.
  /// They can issue a new, corrected credential.
  public static var tkReceiveCredentialOfferWrongDataSecondary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_wrongData_secondary", fallback: "Once issued, a credential cannot be changed.\n\nIf you notice an error in your data, please contact the issuer.\nThey can issue a new, corrected credential.")
  }

  /// Report incorrect details
  public static var tkReceiveCredentialOfferWrongDataSectionCellPrimary: String {
    L10n.tr("Localizable", "tk_receive_credentialOffer_wrongDataSection_cell_primary", fallback: "Report incorrect details")
  }

  /// Decline credential?
  public static var tkReceiveDeclineOfferPrimary: String {
    L10n.tr("Localizable", "tk_receive_declineOffer_primary", fallback: "Decline credential?")
  }

  /// Decline credential
  public static var tkReceiveDeclineOfferPrimaryButton: String {
    L10n.tr("Localizable", "tk_receive_declineOffer_primaryButton", fallback: "Decline credential")
  }

  /// A rejected credential cannot be added to the swiyu Wallet.
  /// If you decline it, you must request a new one from the issuer.
  public static var tkReceiveDeclineOfferSecondary: String {
    L10n.tr("Localizable", "tk_receive_declineOffer_secondary", fallback: "A rejected credential cannot be added to the swiyu Wallet.\nIf you decline it, you must request a new one from the issuer.")
  }

  /// Report incorrect details
  public static var tkReceiveIncorrectdataTitle: String {
    L10n.tr("Localizable", "tk_receive_incorrectdata_title", fallback: "Report incorrect details")
  }

  /// Accessibility Declaration
  public static var tkSettingsAccessibilityDeclarationLinkText: String {
    L10n.tr("Localizable", "tk_settings_accessibility_declaration_link_text", fallback: "Accessibility Declaration")
  }

  /// https://www.eid.admin.ch/en/accessibility-in-the-federal-administration
  public static var tkSettingsAccessibilityDeclarationLinkValue: String {
    L10n.tr("Localizable", "tk_settings_accessibility_declaration_link_value", fallback: "https://www.eid.admin.ch/en/accessibility-in-the-federal-administration")
  }

  /// Report Accessibility Issue
  public static var tkSettingsAccessibilityReportIssueLinkText: String {
    L10n.tr("Localizable", "tk_settings_accessibility_reportIssue_link_text", fallback: "Report Accessibility Issue")
  }

  /// https://forms.eid.admin.ch/
  public static var tkSettingsAccessibilityReportIssueLinkValue: String {
    L10n.tr("Localizable", "tk_settings_accessibility_reportIssue_link_value", fallback: "https://forms.eid.admin.ch/")
  }

  /// Delete entire history?
  public static var tkSettingsActivityHistoryDeletionConfirmationPrimary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_deletion_confirmationPrimary", fallback: "Delete entire history?")
  }

  /// You won’t be able to restore or report these activities anymore.
  public static var tkSettingsActivityHistoryDeletionConfirmationSecondary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_deletion_confirmationSecondary", fallback: "You won’t be able to restore or report these activities anymore.")
  }

  /// Delete entire activity history
  public static var tkSettingsActivityHistoryDeletionPrimary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_deletion_primary", fallback: "Delete entire activity history")
  }

  /// Activity history deleted
  public static var tkSettingsActivityHistoryDeletionSuccessMessage: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_deletion_successMessage", fallback: "Activity history deleted")
  }

  /// History Settings
  public static var tkSettingsActivityHistoryTitle: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_title", fallback: "History Settings")
  }

  /// Confirm
  public static var tkSettingsActivityHistoryToggleHistoryConfirmationButtonPrimary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_toggleHistory_confirmationButtonPrimary", fallback: "Confirm")
  }

  /// Turn off history?
  public static var tkSettingsActivityHistoryToggleHistoryConfirmationPrimary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_toggleHistory_confirmationPrimary", fallback: "Turn off history?")
  }

  /// If you disable the history, future activities of all credentials will no longer be stored. These activities can then no longer be reviewed or reported.
  public static var tkSettingsActivityHistoryToggleHistoryConfirmationSecondary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_toggleHistory_confirmationSecondary", fallback: "If you disable the history, future activities of all credentials will no longer be stored. These activities can then no longer be reviewed or reported.")
  }

  /// Save all activities
  public static var tkSettingsActivityHistoryToggleHistoryPrimary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_toggleHistory_primary", fallback: "Save all activities")
  }

  /// Existing history will be kept unless you delete them.
  public static var tkSettingsActivityHistoryToggleHistorySecondary: String {
    L10n.tr("Localizable", "tk_settings_activityHistory_toggleHistory_secondary", fallback: "Existing history will be kept unless you delete them.")
  }

  /// The app has been closed unexpectedly
  public static var tkSettingsDiagnosticDataAppCrash: String {
    L10n.tr("Localizable", "tk_settings_diagnosticData_appCrash", fallback: "The app has been closed unexpectedly")
  }

  /// When sharing diagnostic data, swiyu occasionally sends anonymous, non-personal information. This helps us continuously improve the app and fix errors more quickly. It is not possible to draw any conclusions about your identity.
  ///
  ///
  ///
  public static var tkSettingsDiagnosticDataBody: String {
    L10n.tr("Localizable", "tk_settings_diagnosticData_body", fallback: "When sharing diagnostic data, swiyu occasionally sends anonymous, non-personal information. This helps us continuously improve the app and fix errors more quickly. It is not possible to draw any conclusions about your identity.\n\n\n")
  }

  /// A connection could not be established.
  public static var tkSettingsDiagnosticDataCommunicationError: String {
    L10n.tr("Localizable", "tk_settings_diagnosticData_communicationError", fallback: "A connection could not be established.")
  }

  /// General error messages
  public static var tkSettingsDiagnosticDataGeneralError: String {
    L10n.tr("Localizable", "tk_settings_diagnosticData_generalError", fallback: "General error messages")
  }

  /// Share diagnostic data
  public static var tkSettingsDiagnosticDataTitle: String {
    L10n.tr("Localizable", "tk_settings_diagnosticData_title", fallback: "Share diagnostic data")
  }

  /// Feedback and support
  public static var tkSettingsFeedbackSupportSectionTitle: String {
    L10n.tr("Localizable", "tk_settings_feedbackSupport_sectionTitle", fallback: "Feedback and support")
  }

  /// Accessibility
  public static var tkSettingsGeneralAccessibility: String {
    L10n.tr("Localizable", "tk_settings_general_accessibility", fallback: "Accessibility")
  }

  /// Send  feedback
  public static var tkSettingsGeneralFeedbackLinkText: String {
    L10n.tr("Localizable", "tk_settings_general_feedback_link_text", fallback: "Send  feedback")
  }

  /// https://findmind.ch/c/feedback_public_beta_en
  public static var tkSettingsGeneralFeedbackLinkValue: String {
    L10n.tr("Localizable", "tk_settings_general_feedback_link_value", fallback: "https://findmind.ch/c/feedback_public_beta_en")
  }

  /// Help & Contact
  public static var tkSettingsGeneralHelpLinkText: String {
    L10n.tr("Localizable", "tk_settings_general_help_link_text", fallback: "Help & Contact")
  }

  /// https://www.eid.admin.ch/en/hilfe-e
  public static var tkSettingsGeneralHelpLinkValue: String {
    L10n.tr("Localizable", "tk_settings_general_help_link_value", fallback: "https://www.eid.admin.ch/en/hilfe-e")
  }

  /// Legal notice
  public static var tkSettingsGeneralImprint: String {
    L10n.tr("Localizable", "tk_settings_general_imprint", fallback: "Legal notice")
  }

  /// Licences
  public static var tkSettingsGeneralLicences: String {
    L10n.tr("Localizable", "tk_settings_general_licences", fallback: "Licences")
  }

  /// General
  public static var tkSettingsGeneralSectionTitle: String {
    L10n.tr("Localizable", "tk_settings_general_sectionTitle", fallback: "General")
  }

  /// App Version
  public static var tkSettingsImprintAppInformationAppVersion: String {
    L10n.tr("Localizable", "tk_settings_imprint_appInformation_appVersion", fallback: "App Version")
  }

  /// The swiyu Wallet is open source. You can find the source code on GitHub
  public static var tkSettingsImprintAppInformationBody: String {
    L10n.tr("Localizable", "tk_settings_imprint_appInformation_body", fallback: "The swiyu Wallet is open source. You can find the source code on GitHub")
  }

  /// Build Number
  public static var tkSettingsImprintAppInformationBuildNumber: String {
    L10n.tr("Localizable", "tk_settings_imprint_appInformation_buildNumber", fallback: "Build Number")
  }

  /// https://github.com/swiyu-admin-ch
  public static var tkSettingsImprintAppInformationGithubLinkText: String {
    L10n.tr("Localizable", "tk_settings_imprint_appInformation_github_link_text", fallback: "https://github.com/swiyu-admin-ch")
  }

  /// https://github.com/swiyu-admin-ch
  public static var tkSettingsImprintAppInformationGithubLinkValue: String {
    L10n.tr("Localizable", "tk_settings_imprint_appInformation_github_link_value", fallback: "https://github.com/swiyu-admin-ch")
  }

  /// Disclaimer
  public static var tkSettingsImprintLegalDisclaimerPrimary: String {
    L10n.tr("Localizable", "tk_settings_imprint_legal_disclaimer_primary", fallback: "Disclaimer")
  }

  /// The authors assume no responsibility for the reliability or completeness of the information. We accept no responsibility for references and links to third-party websites.
  public static var tkSettingsImprintLegalDisclaimerSecondary: String {
    L10n.tr("Localizable", "tk_settings_imprint_legal_disclaimer_secondary", fallback: "The authors assume no responsibility for the reliability or completeness of the information. We accept no responsibility for references and links to third-party websites.")
  }

  /// Legal information
  public static var tkSettingsImprintLegalSectionTitle: String {
    L10n.tr("Localizable", "tk_settings_imprint_legal_sectionTitle", fallback: "Legal information")
  }

  /// Terms of use
  public static var tkSettingsImprintLegalTermsOfUseLinkText: String {
    L10n.tr("Localizable", "tk_settings_imprint_legal_termsOfUse_link_text", fallback: "Terms of use")
  }

  /// https://www.eid.admin.ch/en/swiyu-terms-e
  public static var tkSettingsImprintLegalTermsOfUseLinkValue: String {
    L10n.tr("Localizable", "tk_settings_imprint_legal_termsOfUse_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-terms-e")
  }

  /// www.bit.admin.ch
  public static var tkSettingsImprintPublisherLinkText: String {
    L10n.tr("Localizable", "tk_settings_imprint_publisher_link_text", fallback: "www.bit.admin.ch")
  }

  /// https://www.bit.admin.ch/en
  public static var tkSettingsImprintPublisherLinkValue: String {
    L10n.tr("Localizable", "tk_settings_imprint_publisher_link_value", fallback: "https://www.bit.admin.ch/en")
  }

  /// Issuance, development and operation
  public static var tkSettingsImprintPublisherSectionTitle: String {
    L10n.tr("Localizable", "tk_settings_imprint_publisher_sectionTitle", fallback: "Issuance, development and operation")
  }

  /// Legal notice
  public static var tkSettingsImprintTitle: String {
    L10n.tr("Localizable", "tk_settings_imprint_title", fallback: "Legal notice")
  }

  /// This section provides an overview of the software licenses used in the Swiyu Wallet. The licenses comply with the data protection guidelines of the BIT and the latest security standards. With this list, we aim to ensure transparency for all users of the app.
  /// The licences comply with the FOITT privacy guidelines and the latest security standards. We would like to create transparency for our users with this list.
  public static var tkSettingsLicencesBody: String {
    L10n.tr("Localizable", "tk_settings_licences_body", fallback: "This section provides an overview of the software licenses used in the Swiyu Wallet. The licenses comply with the data protection guidelines of the BIT and the latest security standards. With this list, we aim to ensure transparency for all users of the app.\nThe licences comply with the FOITT privacy guidelines and the latest security standards. We would like to create transparency for our users with this list.")
  }

  /// The app currently does not use any external libraries
  public static var tkSettingsLicencesEmptyState: String {
    L10n.tr("Localizable", "tk_settings_licences_emptyState", fallback: "The app currently does not use any external libraries")
  }

  /// More information
  public static var tkSettingsLicencesLinkText: String {
    L10n.tr("Localizable", "tk_settings_licences_link_text", fallback: "More information")
  }

  /// https://www.eid.admin.ch/en/hilfe-e
  public static var tkSettingsLicencesLinkValue: String {
    L10n.tr("Localizable", "tk_settings_licences_link_value", fallback: "https://www.eid.admin.ch/en/hilfe-e")
  }

  /// -
  public static var tkSettingsLicencesNoVersion: String {
    L10n.tr("Localizable", "tk_settings_licences_noVersion", fallback: "-")
  }

  /// Licences
  public static var tkSettingsLicencesTitle: String {
    L10n.tr("Localizable", "tk_settings_licences_title", fallback: "Licences")
  }

  /// Activity history
  public static var tkSettingsSecurityPrivacyDataProtectionActivityHistory: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_dataProtection_activityHistory", fallback: "Activity history")
  }

  /// Diagnostic data
  public static var tkSettingsSecurityPrivacyDataProtectionDiagnosticData: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_dataProtection_diagnosticData", fallback: "Diagnostic data")
  }

  /// Privacy policy
  public static var tkSettingsSecurityPrivacyDataProtectionPrivacyPolicyLinkText: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_dataProtection_privacyPolicy_link_text", fallback: "Privacy policy")
  }

  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var tkSettingsSecurityPrivacyDataProtectionPrivacyPolicyLinkValue: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_dataProtection_privacyPolicy_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  }

  /// Data protection and privacy
  public static var tkSettingsSecurityPrivacyDataProtectionSectionTitle: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_dataProtection_sectionTitle", fallback: "Data protection and privacy")
  }

  /// Share diagnostic data
  public static var tkSettingsSecurityPrivacyDataProtectionShareDataPrimary: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_dataProtection_shareData_primary", fallback: "Share diagnostic data")
  }

  /// To create an e-ID, we require your consent to the privacy policy
  public static var tkSettingsSecurityPrivacyDataProtectionShareDataSecondary: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_dataProtection_shareData_secondary", fallback: "To create an e-ID, we require your consent to the privacy policy")
  }

  /// Please change password
  public static var tkSettingsSecurityPrivacySecurityChangePassword: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_security_changePassword", fallback: "Please change password")
  }

  /// Security
  public static var tkSettingsSecurityPrivacySecuritySectionTitle: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_security_sectionTitle", fallback: "Security")
  }

  /// Security and data protection - Doublete
  public static var tkSettingsSecurityPrivacyTitle: String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_title", fallback: "Security and data protection - Doublete")
  }

  /// Settings
  public static var tkSettingsTitle: String {
    L10n.tr("Localizable", "tk_settings_title", fallback: "Settings")
  }

  /// Language
  public static var tkSettingsWalletLanguage: String {
    L10n.tr("Localizable", "tk_settings_wallet_language", fallback: "Language")
  }

  /// Wallet
  public static var tkSettingsWalletSectionTitle: String {
    L10n.tr("Localizable", "tk_settings_wallet_sectionTitle", fallback: "Wallet")
  }

  /// Security and data protection
  public static var tkSettingsWalletSecurityPrivacy: String {
    L10n.tr("Localizable", "tk_settings_wallet_securityPrivacy", fallback: "Security and data protection ")
  }

  /// To settings
  public static var tkUnsecuredDeviceButtonSettings: String {
    L10n.tr("Localizable", "tk_unsecuredDevice_button_settings", fallback: "To settings")
  }

  /// Security Notice
  public static var tkUnsecuredDevicePrimary: String {
    L10n.tr("Localizable", "tk_unsecuredDevice_primary", fallback: "Security Notice")
  }

  /// To use this app, your device must be secured with a password. Please enable a screen lock (e.g. PIN, password, or Face/Touch ID) in your mobile device settings.
  /// Please enable a screen lock (e.g., PIN, password, or Face/Touch ID) in your iPhone settings.
  public static var tkUnsecuredDeviceSecondary: String {
    L10n.tr("Localizable", "tk_unsecuredDevice_secondary", fallback: "To use this app, your device must be secured with a password. Please enable a screen lock (e.g. PIN, password, or Face/Touch ID) in your mobile device settings.\nPlease enable a screen lock (e.g., PIN, password, or Face/Touch ID) in your iPhone settings.")
  }

  /// The app can only be used after device security has been enabled.
  public static var tkUnsecuredDeviceTertiary: String {
    L10n.tr("Localizable", "tk_unsecuredDevice_tertiary", fallback: "The app can only be used after device security has been enabled.")
  }

  /// Authorised verifier
  public static var tkVerifierLegitimate: String {
    L10n.tr("Localizable", "tk_verifier_legitimate", fallback: "Authorised verifier")
  }

  /// Not authorised verifier
  public static var tkVerifierNotLegitimate: String {
    L10n.tr("Localizable", "tk_verifier_notLegitimate", fallback: "Not authorised verifier")
  }

  /// Please Request support
  public static var tkVersionEnforcementBlacklistedButton: String {
    L10n.tr("Localizable", "tk_versionEnforcement_blacklisted_button", fallback: "Please Request support ")
  }

  /// This device is not allowed. Get more information on our support website.
  public static var tkVersionEnforcementBlacklistedContent: String {
    L10n.tr("Localizable", "tk_versionEnforcement_blacklisted_content", fallback: "This device is not allowed. Get more information on our support website.")
  }

  /// Unsupported device
  public static var tkVersionEnforcementBlacklistedTitle: String {
    L10n.tr("Localizable", "tk_versionEnforcement_blacklisted_title", fallback: "Unsupported device")
  }

  /// Please update app
  public static var tkVersionEnforcementButton: String {
    L10n.tr("Localizable", "tk_versionEnforcement_button", fallback: "Please update app")
  }

  /// The current swiyu Wallet version is out of date.
  public static var tkVersionEnforcementForcedBody: String {
    L10n.tr("Localizable", "tk_versionEnforcement_forced_body", fallback: "The current swiyu Wallet version is out of date.")
  }

  /// Compulsory update
  public static var tkVersionEnforcementForcedTitle: String {
    L10n.tr("Localizable", "tk_versionEnforcement_forced_title", fallback: "Compulsory update")
  }

  /// Please update later
  public static var tkVersionEnforcementLaterButton: String {
    L10n.tr("Localizable", "tk_versionEnforcement_later_button", fallback: "Please update later")
  }

  /// A new version of swiyu is available for download.
  public static var tkVersionEnforcementOptionalBody: String {
    L10n.tr("Localizable", "tk_versionEnforcement_optional_body", fallback: "A new version of swiyu is available for download.")
  }

  /// Update recommended
  public static var tkVersionEnforcementOptionalTitle: String {
    L10n.tr("Localizable", "tk_versionEnforcement_optional_title", fallback: "Update recommended")
  }

  /// Update in settings
  public static var tkVersionEnforcementSystemUpdateButton: String {
    L10n.tr("Localizable", "tk_versionEnforcement_systemUpdate_button", fallback: "Update in settings")
  }

  /// The current device system version is not supported. Please update your system in the settings.
  public static var tkVersionEnforcementSystemUpdateContent: String {
    L10n.tr("Localizable", "tk_versionEnforcement_systemUpdate_content", fallback: "The current device system version is not supported. Please update your system in the settings.")
  }

  /// System update required
  public static var tkVersionEnforcementSystemUpdateTitle: String {
    L10n.tr("Localizable", "tk_versionEnforcement_systemUpdate_title", fallback: "System update required")
  }

  /// Devices are being loaded…
  public static var tkWalletPairingDevicePairingQRCodeFetchDeviceBody: String {
    L10n.tr("Localizable", "tk_walletPairing_devicePairingQRCode_fetchDevice_body", fallback: "Devices are being loaded…")
  }

  /// The QR code could not be loaded
  public static var tkWalletPairingDevicePairingQRCodeFetchErrorBody: String {
    L10n.tr("Localizable", "tk_walletPairing_devicePairingQRCode_fetchError_body", fallback: "The QR code could not be loaded")
  }

  /// Please try again
  public static var tkWalletPairingDevicePairingQRCodeFetchErrorButton: String {
    L10n.tr("Localizable", "tk_walletPairing_devicePairingQRCode_fetchError_button", fallback: "Please try again")
  }

  /// Please scan the QR code
  public static var tkWalletPairingDevicePairingQRCodePrimary: String {
    L10n.tr("Localizable", "tk_walletPairing_devicePairingQRCode_primary", fallback: "Please scan the QR code")
  }

  /// QR code. Scan this code to pair the device.
  public static var tkWalletPairingDevicePairingQRCodeQrCodeAlt: String {
    L10n.tr("Localizable", "tk_walletPairing_devicePairingQRCode_qrCode_alt", fallback: "QR code. Scan this code to pair the device.")
  }

  /// Please open the swiyu Wallet on the other device, scan the QR code, and wait here until this screen updates.
  public static var tkWalletPairingDevicePairingQRCodeSecondary: String {
    L10n.tr("Localizable", "tk_walletPairing_devicePairingQRCode_secondary", fallback: "Please open the swiyu Wallet on the other device, scan the QR code, and wait here until this screen updates.")
  }

  /// Would you like to activate %@ to unlock the app?
  public static func biometricSetupContent(_ p1: Any) -> String {
    L10n.tr("Localizable", "biometricSetup_content", String(describing: p1), fallback: "Would you like to activate %@ to unlock the app?")
  }

  /// Use %@
  public static func biometricSetupTitle(_ p1: Any) -> String {
    L10n.tr("Localizable", "biometricSetup_title", String(describing: p1), fallback: "Use %@")
  }

  /// %@ is solely registered in the base registry
  public static func tkBadgeInformationInBaseRegistryPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_inBaseRegistry_primary", String(describing: p1), fallback: "%@ is solely registered in the base registry")
  }

  /// Based on this information the Confederation does not know who they are. Improper use of the Infrastructure can be examined.
  ///
  /// Hint: Only share your data if you trust %1$@. For example, if you believe that %1$@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.
  public static func tkBadgeInformationInBaseRegistrySecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_inBaseRegistry_secondary", String(describing: p1), fallback: "Based on this information the Confederation does not know who they are. Improper use of the Infrastructure can be examined.\n\nHint: Only share your data if you trust %1$@. For example, if you believe that %1$@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.")
  }

  /// %@ is registered in the base and trust registry.
  public static func tkBadgeInformationInTrustRegistryPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_inTrustRegistry_primary", String(describing: p1), fallback: "%@ is registered in the base and trust registry.")
  }

  /// The Confederation has verified their entries.
  ///
  /// Hint: Only share your data if you trust %1$@. For example, if you believe that %1$@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.
  public static func tkBadgeInformationInTrustRegistrySecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_inTrustRegistry_secondary", String(describing: p1), fallback: "The Confederation has verified their entries.\n\nHint: Only share your data if you trust %1$@. For example, if you believe that %1$@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.")
  }

  /// %@ is a legitimate issuer of this credential.
  public static func tkBadgeInformationLegitimateIssuerPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_legitimateIssuer_primary", String(describing: p1), fallback: "%@ is a legitimate issuer of this credential.")
  }

  /// %@ is a legitimate verifier of this credential.
  public static func tkBadgeInformationLegitimateVerifierPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_legitimateVerifier_primary", String(describing: p1), fallback: "%@ is a legitimate verifier of this credential.")
  }

  /// Hint: Only share your data if you trust %@. For example, if you believe that %@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.
  public static func tkBadgeInformationNonCompliantHint(_ p1: Any, _ p2: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_nonCompliant_hint", String(describing: p1), String(describing: p2), fallback: "Hint: Only share your data if you trust %@. For example, if you believe that %@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures.")
  }

  /// %@ is not a legitimate verifier of this credential.
  public static func tkBadgeInformationNonCompliantPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_nonCompliant_primary", String(describing: p1), fallback: "%@ is not a legitimate verifier of this credential.")
  }

  /// %@ is registered neither in the base nor the trust registry.
  public static func tkBadgeInformationNotInSystemPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_notInSystem_primary", String(describing: p1), fallback: "%@ is registered neither in the base nor the trust registry.")
  }

  /// The Confederation possesses no information about their trustworthiness.
  ///
  /// Hint: Only share your data if you trust %1$@. For example, if you believe that %1$@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures. An exclusion from the registries is not possible.
  public static func tkBadgeInformationNotInSystemSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_notInSystem_secondary", String(describing: p1), fallback: "The Confederation possesses no information about their trustworthiness.\n\nHint: Only share your data if you trust %1$@. For example, if you believe that %1$@ is requesting too much data, you may file a report. The Federal Office of Justice will then initiate a review procedure and, if necessary, take further measures. An exclusion from the registries is not possible.")
  }

  /// %@ is not a legitimate issuer of this credential.
  public static func tkBadgeInformationNotLegitimateIssuerPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_notLegitimateIssuer_primary", String(describing: p1), fallback: "%@ is not a legitimate issuer of this credential.")
  }

  /// %@ is not a legitimate verifier of this credential.
  public static func tkBadgeInformationNotLegitimateVerifierPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_badgeInformation_notLegitimateVerifier_primary", String(describing: p1), fallback: "%@ is not a legitimate verifier of this credential.")
  }

  /// The password is incorrect. You have %@ attempts remaining.
  public static func tkChangepasswordError1Note2(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_changepassword_error1_note2", String(describing: p1), fallback: "The password is incorrect. You have %@ attempts remaining.")
  }

  /// %d of %d
  public static func tkCredentialIssuanceTypeAvailableCredentialsValue(_ p1: Int, _ p2: Int) -> String {
    L10n.tr("Localizable", "tk_credential_issuanceType_availableCredentials_value", p1, p2, fallback: "%d of %d")
  }

  /// When fewer than %d credentials are available, new ones are generated automatically.
  public static func tkCredentialIssuanceTypeRefreshHint(_ p1: Int) -> String {
    L10n.tr("Localizable", "tk_credential_issuanceType_refreshHint", p1, fallback: "When fewer than %d credentials are available, new ones are generated automatically.")
  }

  /// Valid in %@ days
  public static func tkCredentialStatusNotValidYet(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_credential_status_notValidYet", String(describing: p1), fallback: "Valid in %@ days")
  }

  /// Credential valid in %@ days
  public static func tkCredentialStatusNotValidYetAlt(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_credential_status_notValidYet_alt", String(describing: p1), fallback: "Credential valid in %@ days")
  }

  /// Verification of %@'s identity in progress
  public static func tkEidRequestNotificationAgentReviewPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_agentReview_primary", String(describing: p1), fallback: "Verification of %@'s identity in progress")
  }

  /// AV files for %@ sent
  public static func tkEidRequestNotificationAutoVerificationFilesSubmittedPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_autoVerification_filesSubmitted_primary", String(describing: p1), fallback: "AV files for %@ sent")
  }

  /// The identity verification of %@ was not successful.
  public static func tkEidRequestNotificationDeclinedPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_declined_primary", String(describing: p1), fallback: "The identity verification of %@ was not successful.")
  }

  /// e-ID Order for %@ expired
  public static func tkEidRequestNotificationEidExpiredPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidExpired_primary", String(describing: p1), fallback: "e-ID Order for %@ expired")
  }

  /// The e-ID application for %@ is in the queue
  public static func tkEidRequestNotificationEidProgressPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidProgress_primary", String(describing: p1), fallback: "The e-ID application for %@ is in the queue")
  }

  /// Your application has been successfully submitted. You can continue the application process from %@. You will receive a notification once your application has been processed.
  public static func tkEidRequestNotificationEidProgressSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidProgress_secondary", String(describing: p1), fallback: "Your application has been successfully submitted. You can continue the application process from %@. You will receive a notification once your application has been processed.")
  }

  /// The e-ID application for %@ can be continued
  public static func tkEidRequestNotificationEidReadyPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidReady_primary", String(describing: p1), fallback: "The e-ID application for %@ can be continued")
  }

  /// Please complete the application by %@. After that, the application will be cancelled and you will need to submit a new one.
  public static func tkEidRequestNotificationEidReadySecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidReady_secondary", String(describing: p1), fallback: "Please complete the application by %@. After that, the application will be cancelled and you will need to submit a new one.")
  }

  /// e-ID status for %@ unknown
  public static func tkEidRequestNotificationEidUnknownStatePrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_eidUnknownState_primary", String(describing: p1), fallback: "e-ID status for %@ unknown")
  }

  /// Your e-ID for %@ is now available.
  public static func tkEidRequestNotificationIssuingPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_issuing_primary", String(describing: p1), fallback: "Your e-ID for %@ is now available.")
  }

  /// Please verify your identity by %@, otherwise your order will be canceled.
  ///
  /// Your parents’ or legal guardian’s consent is still missing.
  public static func tkEidRequestNotificationLegalRepresentantPendingConsentReadyForAVSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_legalRepresentantPendingConsent_readyForAV_secondary", String(describing: p1), fallback: "Please verify your identity by %@, otherwise your order will be canceled.\n\nYour parents’ or legal guardian’s consent is still missing.")
  }

  /// Identity verification for %@ is in progress.
  public static func tkEidRequestNotificationReadyForFinalEntitlementCheckPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_notification_readyForFinalEntitlementCheck_primary", String(describing: p1), fallback: "Identity verification for %@ is in progress.")
  }

  /// Code sent to **%@**
  public static func tkEidRequestOtpCodeBodySent(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_otp_code_body_sent", String(describing: p1), fallback: "Code sent to **%@**")
  }

  /// Press to start a %d seconds video recording
  public static func tkEidRequestRecordDocumentButtonInitialStateAlt(_ p1: Int) -> String {
    L10n.tr("Localizable", "tk_eidRequest_recordDocument_buttonInitialState_alt", p1, fallback: "Press to start a %d seconds video recording")
  }

  /// Press to start a %d seconds video recording
  public static func tkEidRequestRecordSelfieButtonInitialStateAlt(_ p1: Int) -> String {
    L10n.tr("Localizable", "tk_eidRequest_recordSelfie_buttonInitialState_alt", p1, fallback: "Press to start a %d seconds video recording")
  }

  /// %@ devices added
  public static func tkEidRequestWalletPairingAdditionalDeviceCounter(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_eidRequest_walletPairing_additionalDevice_counter", String(describing: p1), fallback: "%@ devices added")
  }

  /// Unlock with %@
  public static func tkGlobalLoginfaceidPrimarybutton(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_global_loginfaceid_primarybutton", String(describing: p1), fallback: "Unlock with %@")
  }

  /// Please try again in %@ minutes.
  public static func tkLoginLockedBodyIos(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_locked_body_ios", String(describing: p1), fallback: "Please try again in %@ minutes.")
  }

  /// Please try again in %@ second.
  public static func tkLoginLockedBodySecondsIos(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_locked_body_seconds_ios", String(describing: p1), fallback: "Please try again in %@ second.")
  }

  /// You have %@ attempt(s) remaining
  public static func tkLoginPasswordfailedIosSubtitle(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_passwordfailed_ios_subtitle", String(describing: p1), fallback: "You have %@ attempt(s) remaining")
  }

  /// Character count %@ of %@ characters entered
  public static func tkNonComplianceReportFormDescriptionCharacterCountAlt(_ p1: Any, _ p2: Any) -> String {
    L10n.tr("Localizable", "tk_nonCompliance_report_form_description_characterCount_alt", String(describing: p1), String(describing: p2), fallback: "Character count %@ of %@ characters entered")
  }

  /// Use %@
  public static func tkOnboardingBiometricsPermissionPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermission_primary", String(describing: p1), fallback: "Use %@")
  }

  /// Would you like to use %@ to unlock the app?
  public static func tkOnboardingBiometricsPermissionSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermission_secondary", String(describing: p1), fallback: "Would you like to use %@ to unlock the app?")
  }

  /// If %@ does not work, you can still use your password.
  public static func tkOnboardingBiometricsPermissionTertiary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermission_tertiary", String(describing: p1), fallback: "If %@ does not work, you can still use your password.")
  }

  /// Use %@
  public static func tkOnboardingBiometricsPermissionDisabledPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermissionDisabled_primary", String(describing: p1), fallback: "Use %@")
  }

  /// Do you want to use %@ to unlock the app?
  public static func tkOnboardingBiometricsPermissionDisabledSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermissionDisabled_secondary", String(describing: p1), fallback: "Do you want to use %@ to unlock the app?")
  }

  /// If %@ does not work, you can still use your password.
  public static func tkOnboardingBiometricsPermissionDisabledTertiary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermissionDisabled_tertiary", String(describing: p1), fallback: "If %@ does not work, you can still use your password.")
  }

  /// You have %@ attempt(s) remaining
  public static func tkOnboardingPasswordConfirmationInputErrorNumberOfTriesLeft(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_error_numberOfTriesLeft", String(describing: p1), fallback: "You have %@ attempt(s) remaining")
  }

  /// Deactivate %@
  public static func tkSettingsSecurityPrivacyBiometricsDisablePrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_biometrics_disable_primary", String(describing: p1), fallback: "Deactivate %@")
  }

  /// Unlock with %@
  public static func tkSettingsSecurityPrivacyBiometricsEnablePrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_biometrics_enable_primary", String(describing: p1), fallback: "Unlock with %@")
  }

  /// Unlock with %@
  public static func tkSettingsSecurityPrivacySecurityUnlock(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_security_unlock", String(describing: p1), fallback: "Unlock with %@")
  }

  /// %@ successfully disabled
  public static func tkSettingsSecurityPrivacyStatusDisabled(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_status_disabled", String(describing: p1), fallback: "%@ successfully disabled")
  }

  /// %@ successfully activated
  public static func tkSettingsSecurityPrivacyStatusEnabled(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_settings_securityPrivacy_status_enabled", String(describing: p1), fallback: "%@ successfully activated")
  }

}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  public static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = TranslationHelper.localizeString(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
