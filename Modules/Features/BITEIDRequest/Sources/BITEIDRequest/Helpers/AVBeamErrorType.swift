import BITAVWrapper

// MARK: - AVBeamErrorType

enum AVBeamErrorType {
  case critical
  case error
  case warning
}

// Info: translations are managed through the AVBeamError extension including `title` & `content`: AVBeamLocalization.swift

extension AVBeamError {

  var errorType: AVBeamErrorType {
    switch self {
    case .nfcNotSupported,
         .unsupportedCameraResolution,
         .unsupportedVideoConfiguration:
      return .critical

    case .faceNotRecognized,
         .idBadMrzFields,
         .idExpired,
         .idMatchingFailed,
         .idMismatch,
         .idNoData,
         .idNotDetected,
         .idNotInList,
         .idPageMissing,
         .imageBlurred,
         .imageDocumentTooFar,
         .mrzNotDetected,
         .nfcMoreThanOneTagFound,
         .nfcMutualAuthenticationFailedNotSatisfied,
         .nfcMutualAuthenticationFailedUnknownDeprecated,
         .nfcNotConnected,
         .nfcReadFailed,
         .nfcSessionInvalidated,
         .nfcTagWasLost,
         .nfcTechnicalError,
         .nfcTimeout,
         .nfcUnexpectedException,
         .nfcWrongTag,
         .reflection:
      return .warning

    case .faceCaptureIntegrityCheckFailed,
         .faceFrameSimilarityFailed,
         .faceLayoutValidation,
         .faceLivenessFailed,
         .faceNotVerified,
         .idBadMrzFieldBirthDay,
         .idBadMrzFieldCompositCheckDigit,
         .idBadMrzFieldCountry,
         .idBadMrzFieldDocumentNumber,
         .idBadMrzFieldExpiryDay,
         .idBadMrzFieldFirstName,
         .idBadMrzFieldGender,
         .idBadMrzFieldLastName,
         .idBadMrzFieldNationality,
         .idFaceImageCaptureFailed,
         .idIncompleteData,
         .idMatchingFailedMrz,
         .imageAnomaly,
         .imageFromScreen,
         .imageInjection,
         .imageIsGreyscale,
         .incorrectInput,
         .mrzLayoutValidation,
         .nfcBackendFailedToEncodeFacePhotoAsJpeg,
         .nfcBackendFailedToEncodeSignaturePhotoAsJpeg,
         .nfcBackendSignatureVerifyException,
         .nfcCertificateValidationFailed,
         .nfcClonedChip,
         .nfcInvalidHashesDeprecated,
         .nfcSodVsComInsonsitencyDeprecated,
         .nfcTemperedDataDeprecated,
         .optionalPageMissing,
         .optionalPageNotDetected,
         .specimenDetection:
      return .error

    @unknown default:
      return .error
    }
  }
}
