// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// MARK: - L10n

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// PublicBetaWallet
  public static let appName = L10n.tr("Localizable", "app_name", fallback: "PublicBetaWallet")
  /// Would you like to login faster, activate your biometrics to do so.
  public static let biometricSetupDisabledContent = L10n.tr("Localizable", "biometricSetup _disabled_content", fallback: "Would you like to login faster, activate your biometrics to do so.")
  /// Access your settings and configure your biometrics
  public static let biometricSetupDisabledDetail = L10n.tr("Localizable", "biometricSetup _disabled_detail", fallback: "Access your settings and configure your biometrics")
  /// Biometrics disabled
  public static let biometricSetupDisabledTitle = L10n.tr("Localizable", "biometricSetup_disabled_title", fallback: "Biometrics disabled")
  /// Skip
  public static let biometricSetupDismissButton = L10n.tr("Localizable", "biometricSetup_dismissButton", fallback: "Skip")
  /// Face ID
  public static let biometricSetupFaceidText = L10n.tr("Localizable", "biometricSetup_faceid_text", fallback: "Face ID")
  /// Register biometrics
  public static let biometricSetupNoClass3ToSettingsButton = L10n.tr("Localizable", "biometricSetup_noClass3_toSettingsButton", fallback: "Register biometrics")
  /// You can still log in with your pin, if biometrics are not working
  public static let biometricSetupReason = L10n.tr("Localizable", "biometricSetup_reason", fallback: "You can still log in with your pin, if biometrics are not working")
  /// TouchID
  public static let biometricSetupTouchidText = L10n.tr("Localizable", "biometricSetup_touchid_text", fallback: "TouchID")
  /// QR code invalid
  public static let cameraQrcodeExpiredPrimary = L10n.tr("Localizable", "camera_qrcode_expired_primary", fallback: "QR code invalid")
  /// Light on
  public static let cameraQrcodeLight = L10n.tr("Localizable", "camera_qrcode_light", fallback: "Light on")
  /// Please wait
  public static let cameraQrcodeScannerLoader = L10n.tr("Localizable", "camera_qrcode_scanner_loader", fallback: "Please wait")
  /// Scan QR code
  public static let cameraQrcodeScannerPrimary = L10n.tr("Localizable", "camera_qrcode_scanner_primary", fallback: "Scan QR code")
  /// To identify yourself or add IDs and documents.
  public static let cameraQrcodeScannerSecondary = L10n.tr("Localizable", "camera_qrcode_scanner_secondary", fallback: "To identify yourself or add IDs and documents.")
  /// MISSING: Fortfahren
  public static let cameraPermissionContinueButton = L10n.tr("Localizable", "cameraPermission_continue_button", fallback: "MISSING: Fortfahren")
  /// It seems you denied the access to the camera
  public static let cameraPermissionDeniedPrimary = L10n.tr("Localizable", "cameraPermission_denied_primary", fallback: "It seems you denied the access to the camera")
  /// To be able to scan QRCodes, your camera permission is required
  public static let cameraPermissionDeniedSecondary = L10n.tr("Localizable", "cameraPermission_denied_secondary", fallback: "To be able to scan QRCodes, your camera permission is required")
  /// Open Settings
  public static let cameraPermissionDeniedSettingsButton = L10n.tr("Localizable", "cameraPermission_denied_settingsButton", fallback: "Open Settings")
  /// MISSING: Kamerazugriff
  public static let cameraPermissionPrimary = L10n.tr("Localizable", "cameraPermission_primary", fallback: "MISSING: Kamerazugriff")
  /// MISSING: Erlauben Sie den Zugriff auf die Kamera für das Scannen von QR-Codes um Ausweise zu empfangen oder eine Überprüfung durchzuführen.
  public static let cameraPermissionSecondary = L10n.tr("Localizable", "cameraPermission_secondary", fallback: "MISSING: Erlauben Sie den Zugriff auf die Kamera für das Scannen von QR-Codes um Ausweise zu empfangen oder eine Überprüfung durchzuführen.")
  /// Value:
  public static let cellValueAccessibilityLabel = L10n.tr("Localizable", "cell_value_accessibility_label", fallback: "Value:")
  /// Refuse
  public static let credentialOfferRefuseButton = L10n.tr("Localizable", "credential_offer_refuseButton", fallback: "Refuse")
  /// Data Analysis
  public static let dataAnalysisScreenTitle = L10n.tr("Localizable", "dataAnalysis_screenTitle", fallback: "Data Analysis")
  /// Help us to improve the app by allowing the following anonymised error messages to be made available to the development team:
  ///
  ///
  /// ✓ General error messages
  /// ✓ Communication errors
  /// ✓ App crashes
  ///
  ///
  /// Only anonymised data that does not allow any conclusions to be drawn about you will be analysed.
  public static let dataAnalysisText = L10n.tr("Localizable", "dataAnalysis_text", fallback: "Help us to improve the app by allowing the following anonymised error messages to be made available to the development team:\n\n\n✓ General error messages\n✓ Communication errors\n✓ App crashes\n\n\nOnly anonymised data that does not allow any conclusions to be drawn about you will be analysed.")
  /// Analysis and Improvements
  public static let dataAnalysisTitle = L10n.tr("Localizable", "dataAnalysis_title", fallback: "Analysis and Improvements")
  /// No data found…
  public static let emptyStateEmptyTitle = L10n.tr("Localizable", "emptyState_emptyTitle", fallback: "No data found…")
  /// Oops, something went wrong…
  public static let emptyStateErrorTitle = L10n.tr("Localizable", "emptyState_errorTitle", fallback: "Oops, something went wrong…")
  /// Your internet connection seems off, take a moment to check what's wrong and retry
  public static let emptyStateOfflineMessage = L10n.tr("Localizable", "emptyState_offlineMessage", fallback: "Your internet connection seems off, take a moment to check what's wrong and retry")
  /// Missing internet connection
  public static let emptyStateOfflineTitle = L10n.tr("Localizable", "emptyState_offlineTitle", fallback: "Missing internet connection")
  /// Back
  public static let globalBack = L10n.tr("Localizable", "global_back", fallback: "Back")
  /// Back to the Wallet
  public static let globalBackHome = L10n.tr("Localizable", "global_back_home", fallback: "Back to the Wallet")
  /// Cancel
  public static let globalCancel = L10n.tr("Localizable", "global_cancel", fallback: "Cancel")
  /// Continue
  public static let globalContinue = L10n.tr("Localizable", "global_continue", fallback: "Continue")
  /// Go to settings
  public static let globalErrorNoDevicePinButton = L10n.tr("Localizable", "global_error_no_device_pin_button", fallback: "Go to settings")
  /// Please define a smartphone passcode so that you can use the app.
  public static let globalErrorNoDevicePinMessage = L10n.tr("Localizable", "global_error_no_device_pin_message", fallback: "Please define a smartphone passcode so that you can use the app.")
  /// Missing smartphone code
  public static let globalErrorNoDevicePinTitle = L10n.tr("Localizable", "global_error_no_device_pin_title", fallback: "Missing smartphone code")
  /// App Version
  public static let impressumAppVersion = L10n.tr("Localizable", "impressum_app_version", fallback: "App Version")
  /// Build number
  public static let impressumBuildNumber = L10n.tr("Localizable", "impressum_build_number", fallback: "Build number")
  /// The authors assume no liability whatsoever with regard to the reliability and completeness of the information. References and links to third-party websites are outside our area of responsibility.
  public static let impressumDisclaimerText = L10n.tr("Localizable", "impressum_disclaimer_text", fallback: "The authors assume no liability whatsoever with regard to the reliability and completeness of the information. References and links to third-party websites are outside our area of responsibility.")
  /// Disclaimer
  public static let impressumDisclaimerTitle = L10n.tr("Localizable", "impressum_disclaimer_title", fallback: "Disclaimer")
  /// https://www.github.com/swiyu-admin-ch
  public static let impressumGithubLink = L10n.tr("Localizable", "impressum_github_link", fallback: "https://www.github.com/swiyu-admin-ch")
  /// www.github.com/swiyu-admin-ch
  public static let impressumGithubLinkText = L10n.tr("Localizable", "impressum_github_link_text", fallback: "www.github.com/swiyu-admin-ch")
  /// The swiyu app is open source. Its source code can be viewed on GitHub.
  public static let impressumHeaderText = L10n.tr("Localizable", "impressum_header_text", fallback: "The swiyu app is open source. Its source code can be viewed on GitHub.")
  /// https://www.eid.admin.ch/en/swiyu-terms-e
  public static let impressumLegalsLink = L10n.tr("Localizable", "impressum_legals_link", fallback: "https://www.eid.admin.ch/en/swiyu-terms-e")
  /// Terms of use
  public static let impressumLegalsLinkText = L10n.tr("Localizable", "impressum_legals_link_text", fallback: "Terms of use")
  /// Legals
  public static let impressumLegalsTitle = L10n.tr("Localizable", "impressum_legals_title", fallback: "Legals")
  /// Publisher, implementation and operation
  public static let impressumManagerTitle = L10n.tr("Localizable", "impressum_manager_title", fallback: "Publisher, implementation and operation")
  /// https://www.bit.admin.ch/en
  public static let impressumMoreInformationLink = L10n.tr("Localizable", "impressum_more_information_link", fallback: "https://www.bit.admin.ch/en")
  /// www.bit.admin.ch
  public static let impressumMoreInformationLinkText = L10n.tr("Localizable", "impressum_more_information_link_text", fallback: "www.bit.admin.ch")
  /// More information
  public static let impressumMoreInformationTitle = L10n.tr("Localizable", "impressum_more_information_title", fallback: "More information")
  /// Publication details
  public static let impressumTitle = L10n.tr("Localizable", "impressum_title", fallback: "Publication details")
  /// Our app do not allow jailbroken devices to be used. To prevent potential security leaks, we recommend you to unjailbreak your device.
  public static let jailbreakText = L10n.tr("Localizable", "jailbreak_text", fallback: "Our app do not allow jailbroken devices to be used. To prevent potential security leaks, we recommend you to unjailbreak your device.")
  /// We detected a jailbreak on your system
  public static let jailbreakTitle = L10n.tr("Localizable", "jailbreak_title", fallback: "We detected a jailbreak on your system")
  /// The app currently uses no libraries
  public static let licencesEmptyState = L10n.tr("Localizable", "licences_empty_state", fallback: "The app currently uses no libraries")
  /// https://www.eid.admin.ch/en/help-publicbeta-e
  public static let licencesMoreInformationLink = L10n.tr("Localizable", "licences_more_information_link", fallback: "https://www.eid.admin.ch/en/help-publicbeta-e")
  /// More information
  public static let licencesMoreInformationText = L10n.tr("Localizable", "licences_more_information_text", fallback: "More information")
  /// -
  public static let licencesNoVersion = L10n.tr("Localizable", "licences_no_version", fallback: "-")
  /// Below is the list of software licenses used by this app.
  /// The licenses follow the BIT guidelines for compliance with privacy and the latest security standards. With this list we want to ensure transparency towards the users.
  public static let licencesText = L10n.tr("Localizable", "licences_text", fallback: "Below is the list of software licenses used by this app.\nThe licenses follow the BIT guidelines for compliance with privacy and the latest security standards. With this list we want to ensure transparency towards the users.")
  /// Licences
  public static let licencesTitle = L10n.tr("Localizable", "licences_title", fallback: "Licences")
  /// Continue
  public static let onboardingContinue = L10n.tr("Localizable", "onboarding_continue", fallback: "Continue")
  /// Start tour
  public static let onboardingIntroButtonText = L10n.tr("Localizable", "onboarding_intro_button_text", fallback: "Start tour")
  /// A service of the Swiss Confederation.
  public static let onboardingIntroDetails = L10n.tr("Localizable", "onboarding_intro_details", fallback: "A service of the Swiss Confederation.")
  /// A safe home for your credentials
  public static let onboardingIntroPrimary = L10n.tr("Localizable", "onboarding_intro_primary", fallback: "A safe home for your credentials")
  /// Welcome on the Onboarding of the Public Beta Wallet App. A safe home for your credentials
  public static let onboardingIntroPrimaryAlt = L10n.tr("Localizable", "onboarding_intro_primary_alt", fallback: "Welcome on the Onboarding of the Public Beta Wallet App. A safe home for your credentials")
  /// With publicBeta you always have your certificates at hand.
  public static let onboardingIntroSecondary = L10n.tr("Localizable", "onboarding_intro_secondary", fallback: "With publicBeta you always have your certificates at hand.")
  /// Enter code
  public static let onboardingPinCodeEnterCodeButton = L10n.tr("Localizable", "onboarding_pin_code_enterCodeButton", fallback: "Enter code")
  /// Incorrect password entered too many times. Please set a new password.
  public static let onboardingPinCodeErrorTooManyAttemptsText = L10n.tr("Localizable", "onboarding_pin_code_error_tooManyAttempts_text", fallback: "Incorrect password entered too many times. Please set a new password.")
  /// PIN error
  public static let onboardingPinCodeErrorTooManyAttemptsTitle = L10n.tr("Localizable", "onboarding_pin_code_error_tooManyAttempts_title", fallback: "PIN error")
  /// Unknown error...
  public static let onboardingPinCodeErrorUnknown = L10n.tr("Localizable", "onboarding_pin_code_error_unknown", fallback: "Unknown error...")
  /// Secure your app so that your credentials are protected.
  public static let onboardingPinCodeText = L10n.tr("Localizable", "onboarding_pin_code_text", fallback: "Secure your app so that your credentials are protected.")
  /// Pin Code
  public static let onboardingPinCodeTitle = L10n.tr("Localizable", "onboarding_pin_code_title", fallback: "Pin Code")
  /// Easily provide your credentials
  public static let onboardingPresentPrimary = L10n.tr("Localizable", "onboarding_present_primary", fallback: "Easily provide your credentials")
  /// Receive requests for credentials in the app and answer them immediately. You decide who can see which credential and when.
  public static let onboardingPresentSecondary = L10n.tr("Localizable", "onboarding_present_secondary", fallback: "Receive requests for credentials in the app and answer them immediately. You decide who can see which credential and when.")
  /// Accept
  public static let onboardingPrivacyAcceptLoggingButton = L10n.tr("Localizable", "onboarding_privacy_acceptLoggingButton", fallback: "Accept")
  /// Decline
  public static let onboardingPrivacyDeclineLoggingButton = L10n.tr("Localizable", "onboarding_privacy_declineLoggingButton", fallback: "Decline")
  /// Data protection and security
  public static let onboardingPrivacyLinkText = L10n.tr("Localizable", "onboarding_privacy_link_text", fallback: "Data protection and security")
  /// https://www.eid.admin.ch/en
  public static let onboardingPrivacyLinkValue = L10n.tr("Localizable", "onboarding_privacy_link_value", fallback: "https://www.eid.admin.ch/en")
  /// Help us to improve
  public static let onboardingPrivacyPrimary = L10n.tr("Localizable", "onboarding_privacy_primary", fallback: "Help us to improve")
  /// Allow anonymized usage data to be shared with our development team.
  public static let onboardingPrivacySecondary = L10n.tr("Localizable", "onboarding_privacy_secondary", fallback: "Allow anonymized usage data to be shared with our development team.")
  /// To the app
  public static let onboardingReadyButtonText = L10n.tr("Localizable", "onboarding_ready_buttonText", fallback: "To the app")
  /// Everything is ready
  public static let onboardingReadyPrimary = L10n.tr("Localizable", "onboarding_ready_primary", fallback: "Everything is ready")
  /// The app is ready. You can get more tips on how to use it or read them later in the help section.
  public static let onboardingReadySecondary = L10n.tr("Localizable", "onboarding_ready_secondary", fallback: "The app is ready. You can get more tips on how to use it or read them later in the help section.")
  /// The Swiss Confederation has no access to your data.
  public static let onboardingSecurityDetails = L10n.tr("Localizable", "onboarding_security_details", fallback: "The Swiss Confederation has no access to your data.")
  /// Your data - with you
  public static let onboardingSecurityPrimary = L10n.tr("Localizable", "onboarding_security_primary", fallback: "Your data - with you")
  /// Your credentials are stored exclusively on your device. Only you have access to them.
  public static let onboardingSecuritySecondary = L10n.tr("Localizable", "onboarding_security_secondary", fallback: "Your credentials are stored exclusively on your device. Only you have access to them.")
  /// The verification was canceled and no data was transferred.
  public static let presentationDeclinedMessage = L10n.tr("Localizable", "presentation_declined_message", fallback: "The verification was canceled and no data was transferred.")
  /// Verification was canceled
  public static let presentationDeclinedTitle = L10n.tr("Localizable", "presentation_declined_title", fallback: "Verification was canceled")
  /// Please select the correct credential below and click on it.
  public static let presentationSelectCredentialSubtitle = L10n.tr("Localizable", "presentation_select_credential_subtitle", fallback: "Please select the correct credential below and click on it.")
  /// Which credential must be presented?
  public static let presentationSelectCredentialTitle = L10n.tr("Localizable", "presentation_select_credential_title", fallback: "Which credential must be presented?")
  /// Analysis & Improvements
  public static let securitySettingsAnalysisTitle = L10n.tr("Localizable", "securitySettings_analysisTitle", fallback: "Analysis & Improvements")
  /// Biometrics
  public static let securitySettingsBiometrics = L10n.tr("Localizable", "securitySettings_biometrics", fallback: "Biometrics")
  /// Change password
  public static let securitySettingsChangePin = L10n.tr("Localizable", "securitySettings_changePin", fallback: "Change password")
  /// More information
  public static let securitySettingsDataAnalysis = L10n.tr("Localizable", "securitySettings_dataAnalysis", fallback: "More information")
  /// Privacy statement
  public static let securitySettingsDataProtection = L10n.tr("Localizable", "securitySettings_dataProtection", fallback: "Privacy statement")
  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static let securitySettingsDataProtectionLink = L10n.tr("Localizable", "securitySettings_dataProtectionLink", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  /// Login & Security
  public static let securitySettingsLoginTitle = L10n.tr("Localizable", "securitySettings_loginTitle", fallback: "Login & Security")
  /// Share anonymised error reports
  public static let securitySettingsShareAnalysis = L10n.tr("Localizable", "securitySettings_shareAnalysis", fallback: "Share anonymised error reports")
  /// Help improve the swiyu app by anonymously sharing error reports and crashes – making it even better.
  public static let securitySettingsShareAnalysisText = L10n.tr("Localizable", "securitySettings_shareAnalysis_text", fallback: "Help improve the swiyu app by anonymously sharing error reports and crashes – making it even better.")
  /// Data protection and security
  public static let securitySettingsTitle = L10n.tr("Localizable", "securitySettings_title", fallback: "Data protection and security")
  /// Contact
  public static let settingsContact = L10n.tr("Localizable", "settings_contact", fallback: "Contact")
  /// https://forms.eid.admin.ch
  public static let settingsContactLink = L10n.tr("Localizable", "settings_contactLink", fallback: "https://forms.eid.admin.ch")
  /// Help
  public static let settingsHelp = L10n.tr("Localizable", "settings_help", fallback: "Help")
  /// https://www.eid.admin.ch/en/help-publicbeta-e
  public static let settingsHelpLink = L10n.tr("Localizable", "settings_helpLink", fallback: "https://www.eid.admin.ch/en/help-publicbeta-e")
  /// Publication details
  public static let settingsImpressum = L10n.tr("Localizable", "settings_impressum", fallback: "Publication details")
  /// Language
  public static let settingsLanguage = L10n.tr("Localizable", "settings_language", fallback: "Language")
  /// Licences
  public static let settingsLicences = L10n.tr("Localizable", "settings_licences", fallback: "Licences")
  /// Data protection and security
  public static let settingsSecurity = L10n.tr("Localizable", "settings_security", fallback: "Data protection and security")
  /// Settings
  public static let settingsTitle = L10n.tr("Localizable", "settings_title", fallback: "Settings")
  /// Your settings will be applied, which can take up to 30 seconds.
  public static let storageSetupText = L10n.tr("Localizable", "storageSetup_text", fallback: "Your settings will be applied, which can take up to 30 seconds.")
  /// Applying settings
  public static let storageSetupTitle = L10n.tr("Localizable", "storageSetup_title", fallback: "Applying settings")
  /// Current password
  public static let tkChangepasswordError1Note1 = L10n.tr("Localizable", "tk_changepassword_error1_note1", fallback: "Current password")
  /// Maximum length of 64 characters reached
  public static let tkChangepasswordError2Note2 = L10n.tr("Localizable", "tk_changepassword_error2_note2", fallback: "Maximum length of 64 characters reached")
  /// Confirm new password
  public static let tkChangepasswordError3Note1 = L10n.tr("Localizable", "tk_changepassword_error3_note1", fallback: "Confirm new password")
  /// The passwords do not match. Please try again.
  public static let tkChangepasswordError3Note2 = L10n.tr("Localizable", "tk_changepassword_error3_note2", fallback: "The passwords do not match. Please try again.")
  /// Incorrect password entered too many times. Please set a new password.
  public static let tkChangepasswordError4Notification = L10n.tr("Localizable", "tk_changepassword_error4_notification", fallback: "Incorrect password entered too many times. Please set a new password.\t")
  /// Enter current password
  public static let tkChangepasswordStep1CurrentpasswordAlt = L10n.tr("Localizable", "tk_changepassword_step1_currentpassword_alt", fallback: "Enter current password")
  /// Current password
  public static let tkChangepasswordStep1Note1 = L10n.tr("Localizable", "tk_changepassword_step1_note1", fallback: "Current password")
  /// Password
  public static let tkChangepasswordStep1Note2 = L10n.tr("Localizable", "tk_changepassword_step1_note2", fallback: "Password")
  /// At least 6 characters
  public static let tkChangepasswordStep2Note2 = L10n.tr("Localizable", "tk_changepassword_step2_note2", fallback: "At least 6 characters")
  /// Enter new password with at least six characters
  public static let tkChangepasswordStep2PasswordlengthAlt = L10n.tr("Localizable", "tk_changepassword_step2_passwordlength_alt", fallback: "Enter new password with at least six characters")
  /// Confirm new password
  public static let tkChangepasswordStep3Note1 = L10n.tr("Localizable", "tk_changepassword_step3_note1", fallback: "Confirm new password")
  /// Password successfully changed
  public static let tkChangepasswordSuccessfulNotification = L10n.tr("Localizable", "tk_changepassword_successful_notification", fallback: "Password successfully changed")
  /// Credential
  public static let tkCredentialFallbackTitle = L10n.tr("Localizable", "tk_credential_fallback_title", fallback: "Credential")
  /// Demo
  public static let tkCredentialStatusDemo = L10n.tr("Localizable", "tk_credential_status_demo", fallback: "Demo")
  /// Credential demo
  public static let tkCredentialStatusDemoAlt = L10n.tr("Localizable", "tk_credential_status_demo_alt", fallback: "Credential demo")
  /// Expired
  public static let tkCredentialStatusInvalid = L10n.tr("Localizable", "tk_credential_status_invalid", fallback: "Expired")
  /// Credential expired
  public static let tkCredentialStatusInvalidAlt = L10n.tr("Localizable", "tk_credential_status_invalid_alt", fallback: "Credential expired")
  /// Revoked
  public static let tkCredentialStatusRevoked = L10n.tr("Localizable", "tk_credential_status_revoked", fallback: "Revoked")
  /// Credential revoked
  public static let tkCredentialStatusRevokedAlt = L10n.tr("Localizable", "tk_credential_status_revoked_alt", fallback: "Credential revoked")
  /// Valid soon
  public static let tkCredentialStatusSoon = L10n.tr("Localizable", "tk_credential_status_soon", fallback: "Valid soon")
  /// Credential available soon
  public static let tkCredentialStatusSoonAlt = L10n.tr("Localizable", "tk_credential_status_soon_alt", fallback: "Credential available soon")
  /// Currently locked
  public static let tkCredentialStatusSuspended = L10n.tr("Localizable", "tk_credential_status_suspended", fallback: "Currently locked")
  /// Credential temporarily locked.
  public static let tkCredentialStatusSuspendedAlt = L10n.tr("Localizable", "tk_credential_status_suspended_alt", fallback: "Credential temporarily locked.")
  /// Unknown
  public static let tkCredentialStatusUnknown = L10n.tr("Localizable", "tk_credential_status_unknown", fallback: "Unknown")
  /// Validity status unknown
  public static let tkCredentialStatusUnknownAlt = L10n.tr("Localizable", "tk_credential_status_unknown_alt", fallback: "Validity status unknown")
  /// Valid
  public static let tkCredentialStatusValid = L10n.tr("Localizable", "tk_credential_status_valid", fallback: "Valid")
  /// Credential valid
  public static let tkCredentialStatusValidAlt = L10n.tr("Localizable", "tk_credential_status_valid_alt", fallback: "Credential valid")
  /// This credential, along with all associated data, will be completely deleted from this device.
  public static let tkDisplaydeleteCredentialdeleteBody = L10n.tr("Localizable", "tk_displaydelete_credentialdelete_body", fallback: "This credential, along with all associated data, will be completely deleted from this device.")
  /// Delete credential?
  public static let tkDisplaydeleteCredentialdeleteTitle = L10n.tr("Localizable", "tk_displaydelete_credentialdelete_title", fallback: "Delete credential?")
  /// Delete credential
  public static let tkDisplaydeleteCredentialmenuPrimarybutton = L10n.tr("Localizable", "tk_displaydelete_credentialmenu_primarybutton", fallback: "Delete credential")
  /// Back to top
  public static let tkDisplaydeleteDisplaycredential1Hiddenlink1Text = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_hiddenlink1_text", fallback: "Back to top")
  /// Go to personal details
  public static let tkDisplaydeleteDisplaycredential1Hiddenlink2Text = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_hiddenlink2_text", fallback: "Go to personal details")
  /// Entire history
  public static let tkDisplaydeleteDisplaycredential1Smallbody = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_smallbody", fallback: "Entire history")
  /// History
  public static let tkDisplaydeleteDisplaycredential1Title1 = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title1", fallback: "History")
  /// Details
  public static let tkDisplaydeleteDisplaycredential1Title2 = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title2", fallback: "Details")
  /// Additions
  public static let tkDisplaydeleteDisplaycredential1Title3 = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title3", fallback: "Additions")
  /// Validity
  public static let tkDisplaydeleteDisplaycredential1Title4 = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title4", fallback: "Validity")
  /// Issued by
  public static let tkDisplaydeleteDisplaycredential1Title5 = L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title5", fallback: "Issued by")
  /// Once issued, a credential cannot be changed.
  ///
  /// If you notice an error in your data, please contact the issuer.
  /// They can issue a new, corrected credential.
  public static let tkDisplaydeleteWrongdataBody = L10n.tr("Localizable", "tk_displaydelete_wrongdata_body", fallback: "Once issued, a credential cannot be changed.\n\nIf you notice an error in your data, please contact the issuer.\nThey can issue a new, corrected credential.")
  /// Found any incorrect data?
  public static let tkDisplaydeleteWrongdataNavigationTitle = L10n.tr("Localizable", "tk_displaydelete_wrongdata_navigation_title", fallback: "Found any incorrect data?")
  /// Report incorrect details
  public static let tkDisplaydeleteWrongdataTitle = L10n.tr("Localizable", "tk_displaydelete_wrongdata_title", fallback: "Report incorrect details")
  /// Please try again.
  public static let tkErrorConnectionproblemBody = L10n.tr("Localizable", "tk_error_connectionproblem_body", fallback: "Please try again.")
  /// Connection problems
  public static let tkErrorConnectionproblemTitle = L10n.tr("Localizable", "tk_error_connectionproblem_title", fallback: "Connection problems")
  /// Your swiyu app does not contain any credentials.
  public static let tkErrorEmptywalletBody = L10n.tr("Localizable", "tk_error_emptywallet_body", fallback: "Your swiyu app does not contain any credentials.")
  /// Empty swiyu app
  public static let tkErrorEmptywalletTitle = L10n.tr("Localizable", "tk_error_emptywallet_title", fallback: "Empty swiyu app")
  /// This QR code cannot be used.
  public static let tkErrorInvalidqrcodeBody = L10n.tr("Localizable", "tk_error_invalidqrcode_body", fallback: "This QR code cannot be used.")
  /// Invalid QR code
  public static let tkErrorInvalidqrcodeTitle = L10n.tr("Localizable", "tk_error_invalidqrcode_title", fallback: "Invalid QR code")
  /// This check cannot be perfomed.
  public static let tkErrorInvalidrequestBody = L10n.tr("Localizable", "tk_error_invalidrequest_body", fallback: "This check cannot be perfomed.")
  /// Invalid check
  public static let tkErrorInvalidrequestTitle = L10n.tr("Localizable", "tk_error_invalidrequest_title", fallback: "Invalid check")
  /// This credential cannot be added to the swiyu app.
  public static let tkErrorInvitationcredentialBody = L10n.tr("Localizable", "tk_error_invitationcredential_body", fallback: "This credential cannot be added to the swiyu app.")
  /// Invalid credential
  public static let tkErrorInvitationcredentialTitle = L10n.tr("Localizable", "tk_error_invitationcredential_title", fallback: "Invalid credential")
  /// Your swiyu app does not contain any matching credential.
  public static let tkErrorNosuchcredentialBody = L10n.tr("Localizable", "tk_error_nosuchcredential_body", fallback: "Your swiyu app does not contain any matching credential.")
  /// No matching credential available
  public static let tkErrorNosuchcredentialTitle = L10n.tr("Localizable", "tk_error_nosuchcredential_title", fallback: "No matching credential available")
  /// This issuer is not registered.
  public static let tkErrorNotregisteredBody = L10n.tr("Localizable", "tk_error_notregistered_body", fallback: "This issuer is not registered.")
  /// Unknown issuer
  public static let tkErrorNotregisteredTitle = L10n.tr("Localizable", "tk_error_notregistered_title", fallback: "Unknown issuer")
  /// This QR code is no longer valid, please create a new one.
  public static let tkErrorNotusableBody = L10n.tr("Localizable", "tk_error_notusable_body", fallback: "This QR code is no longer valid, please create a new one.")
  /// QR code no longer valid
  public static let tkErrorNotusableTitle = L10n.tr("Localizable", "tk_error_notusable_title", fallback: "QR code no longer valid")
  /// Beta-ID was added
  public static let tkGetBetaIdAddedNote = L10n.tr("Localizable", "tk_getBetaId_added_note", fallback: "Beta-ID was added")
  /// Would like to issue the following credential:
  public static let tkGetBetaIdApprovalTitle = L10n.tr("Localizable", "tk_getBetaId_approval_title", fallback: "Would like to issue the following credential:")
  /// Via the following link, you will be redirected to an external website where you can create Beta-IDs.
  ///
  /// Afterwards, you can import them and test the swiyu app with them.
  public static let tkGetBetaIdCreateBody = L10n.tr("Localizable", "tk_getBetaId_create_body", fallback: "Via the following link, you will be redirected to an external website where you can create Beta-IDs.\n\nAfterwards, you can import them and test the swiyu app with them.")
  /// Create Beta-ID
  public static let tkGetBetaIdCreateTitle = L10n.tr("Localizable", "tk_getBetaId_create_title", fallback: "Create Beta-ID")
  /// Please try again.
  public static let tkGetBetaIdErrorBody = L10n.tr("Localizable", "tk_getBetaId_error_body", fallback: "Please try again.")
  /// Error code: VXA - 1009
  public static let tkGetBetaIdErrorSmallbody = L10n.tr("Localizable", "tk_getBetaId_error_smallbody", fallback: "Error code: VXA - 1009")
  /// Oops, something went wrong!
  public static let tkGetBetaIdErrorTitle = L10n.tr("Localizable", "tk_getBetaId_error_title", fallback: "Oops, something went wrong!")
  /// Your device does not support Strongbox.
  public static let tkGetBetaIdErrorStrongboxBody = L10n.tr("Localizable", "tk_getBetaId_errorStrongbox_body", fallback: "Your device does not support Strongbox.")
  /// Error code: XYZ - 12345
  public static let tkGetBetaIdErrorStrongboxSmallbody = L10n.tr("Localizable", "tk_getBetaId_errorStrongbox_smallbody", fallback: "Error code: XYZ - 12345")
  /// Strongbox error
  public static let tkGetBetaIdErrorStrongboxTitle = L10n.tr("Localizable", "tk_getBetaId_errorStrongbox_title", fallback: "Strongbox error")
  /// Add a Beta-ID to test the swiyu app.
  public static let tkGetBetaIdFirstUseBody = L10n.tr("Localizable", "tk_getBetaId_firstUse_body", fallback: "Add a Beta-ID to test the swiyu app.")
  /// Wallet empty
  public static let tkGetBetaIdFirstUseTitle = L10n.tr("Localizable", "tk_getBetaId_firstUse_title", fallback: "Wallet empty")
  /// The next step is to check the validity of your ID.
  ///
  /// What types of ID are accepted?
  /// Swiss passport
  /// Swiss ID card
  /// Swiss residence permit
  /// (deepl)
  public static let tkGetEidCheckIdBody = L10n.tr("Localizable", "tk_getEid_checkId_body", fallback: "The next step is to check the validity of your ID.\n\nWhat types of ID are accepted?\nSwiss passport \nSwiss ID card\nSwiss residence permit\n(deepl)")
  /// check ID (deepl)
  public static let tkGetEidCheckIdTitle = L10n.tr("Localizable", "tk_getEid_checkId_title", fallback: "check ID (deepl)")
  /// We attach great importance to the protection of your data and your privacy. To create an e-ID, we require your consent to the data protection declaration.
  public static let tkGetEidDataPrivacyBody = L10n.tr("Localizable", "tk_getEid_dataPrivacy_body", fallback: "We attach great importance to the protection of your data and your privacy. To create an e-ID, we require your consent to the data protection declaration.")
  /// Privacy Statement
  public static let tkGetEidDataPrivacyLinkText = L10n.tr("Localizable", "tk_getEid_dataPrivacy_link_text", fallback: "Privacy Statement")
  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static let tkGetEidDataPrivacyLinkValue = L10n.tr("Localizable", "tk_getEid_dataPrivacy_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  /// Agree and continue
  public static let tkGetEidDataPrivacyPrimaryButton = L10n.tr("Localizable", "tk_getEid_dataPrivacy_primaryButton", fallback: "Agree and continue")
  /// Privacy Statement
  public static let tkGetEidDataPrivacyTitle = L10n.tr("Localizable", "tk_getEid_dataPrivacy_title", fallback: "Privacy Statement")
  /// Please scan the ID again or use a different ID. (deepl)
  public static let tkGetEidGeneralErrorBody = L10n.tr("Localizable", "tk_getEid_generalError_body", fallback: "Please scan the ID again or use a different ID. (deepl)")
  /// An error has occurred (deepl)
  public static let tkGetEidGeneralErrorTitle = L10n.tr("Localizable", "tk_getEid_generalError_title", fallback: "An error has occurred (deepl)")
  /// Finish
  public static let tkGetEidGuardianConsentButtonFinish = L10n.tr("Localizable", "tk_getEid_guardianConsent_button_finish", fallback: "Finish")
  /// Share QR-Code
  public static let tkGetEidGuardianConsentButtonShare = L10n.tr("Localizable", "tk_getEid_guardianConsent_button_share", fallback: "Share QR-Code")
  /// Scan QR Code
  public static let tkGetEidGuardianConsentPrimary = L10n.tr("Localizable", "tk_getEid_guardianConsent_primary", fallback: "Scan QR Code")
  /// QR-Code
  public static let tkGetEidGuardianConsentQrAlt = L10n.tr("Localizable", "tk_getEid_guardianConsent_qr_alt", fallback: "QR-Code")
  /// Try again
  public static let tkGetEidGuardianConsentQrButtonRetry = L10n.tr("Localizable", "tk_getEid_guardianConsent_qr_button_retry", fallback: "Try again")
  /// An error occurred while generating the QR code.
  public static let tkGetEidGuardianConsentQrError = L10n.tr("Localizable", "tk_getEid_guardianConsent_qr_error", fallback: "An error occurred while generating the QR code.")
  /// Your parent or guardian must scan the QR code with their own swiyu app to give consent for you.
  public static let tkGetEidGuardianConsentSecondary = L10n.tr("Localizable", "tk_getEid_guardianConsent_secondary", fallback: "Your parent or guardian must scan the QR code with their own swiyu app to give consent for you.")
  /// Continue as a parent/guardian
  public static let tkGetEidGuardianSelectionButtonContinueAsGuardian = L10n.tr("Localizable", "tk_getEid_guardianSelection_button_continueAsGuardian", fallback: "Continue as a parent/guardian")
  /// Obtain consent
  public static let tkGetEidGuardianSelectionButtonObtainConsent = L10n.tr("Localizable", "tk_getEid_guardianSelection_button_obtainConsent", fallback: "Obtain consent")
  /// We need the consent of the parents or guardian to create this ID.
  public static let tkGetEidGuardianSelectionPrimary = L10n.tr("Localizable", "tk_getEid_guardianSelection_primary", fallback: "We need the consent of the parents or guardian to create this ID.")
  /// How would you like to proceed?
  public static let tkGetEidGuardianSelectionSecondary = L10n.tr("Localizable", "tk_getEid_guardianSelection_secondary", fallback: "How would you like to proceed?")
  /// No
  public static let tkGetEidGuardianshipButtonNo = L10n.tr("Localizable", "tk_getEid_guardianship_button_no", fallback: "No")
  /// Yes
  public static let tkGetEidGuardianshipButtonYes = L10n.tr("Localizable", "tk_getEid_guardianship_button_yes", fallback: "Yes")
  /// Are you under comprehensive guardianship?
  public static let tkGetEidGuardianshipPrimary = L10n.tr("Localizable", "tk_getEid_guardianship_primary", fallback: "Are you under comprehensive guardianship?")
  /// Comprehensive guardianship means that another person (not your parents) makes all important decisions for you.
  public static let tkGetEidGuardianshipSecondary = L10n.tr("Localizable", "tk_getEid_guardianship_secondary", fallback: "Comprehensive guardianship means that another person (not your parents) makes all important decisions for you.")
  /// e-ID bestellen (deepl)
  public static let tkGetEidHomePrimaryButton = L10n.tr("Localizable", "tk_getEid_home_primaryButton", fallback: "e-ID bestellen (deepl)")
  /// First, your ID will be checked. This is followed by an identity check.
  ///
  /// In the best case, it takes about 5 minutes. (deepl)
  public static let tkGetEidIntroBody = L10n.tr("Localizable", "tk_getEid_intro_body", fallback: "First, your ID will be checked. This is followed by an identity check.\n\nIn the best case, it takes about 5 minutes. (deepl)")
  /// Create now (deepl)
  public static let tkGetEidIntroPrimaryButton = L10n.tr("Localizable", "tk_getEid_intro_primaryButton", fallback: "Create now (deepl)")
  /// later (deepl)
  public static let tkGetEidIntroSecondaryButton = L10n.tr("Localizable", "tk_getEid_intro_secondaryButton", fallback: "later (deepl)")
  /// Exceptions
  /// Protecting your identity is our top priority. In rare cases, the identity check requires additional verification. This may result in a waiting period of several days. (deepl)
  public static let tkGetEidIntroSmallBody = L10n.tr("Localizable", "tk_getEid_intro_smallBody", fallback: "Exceptions\nProtecting your identity is our top priority. In rare cases, the identity check requires additional verification. This may result in a waiting period of several days. (deepl)")
  /// Create your e-ID (deepl)
  public static let tkGetEidIntroTitle = L10n.tr("Localizable", "tk_getEid_intro_title", fallback: "Create your e-ID (deepl)")
  /// Close button
  public static let tkGetEidNotificationCloseButton = L10n.tr("Localizable", "tk_getEid_notification_close_button", fallback: "Close button")
  /// You did not fully complete the ordering process. Please restart it to receive your e-ID.
  public static let tkGetEidNotificationEidExpiredSecondary = L10n.tr("Localizable", "tk_getEid_notification_eidExpired_secondary", fallback: "You did not fully complete the ordering process. Please restart it to receive your e-ID.")
  /// Start identification (deepl)
  public static let tkGetEidNotificationEidReadyGreenButton = L10n.tr("Localizable", "tk_getEid_notification_eidReady_greenButton", fallback: "Start identification (deepl)")
  /// Unfortunately, your order cannot be processed immediately due to high demand. You will be notified via the app as soon as it is your turn. This may take a few days. (deepl)
  public static let tkGetEidQueuingBody = L10n.tr("Localizable", "tk_getEid_queuing_body", fallback: "Unfortunately, your order cannot be processed immediately due to high demand. You will be notified via the app as soon as it is your turn. This may take a few days. (deepl)")
  /// Expected date:
  public static let tkGetEidQueuingBody2Ios = L10n.tr("Localizable", "tk_getEid_queuing_body2_ios", fallback: "Expected date:")
  /// processing delay (deepl)
  public static let tkGetEidQueuingTitle = L10n.tr("Localizable", "tk_getEid_queuing_title", fallback: "processing delay (deepl)")
  /// Please have your ID ready and point the camera at the area with the code line.
  /// Allow access to the camera so that the scan can be carried out. (deepl)
  public static let tkGetEidStartScanBody = L10n.tr("Localizable", "tk_getEid_startScan_body", fallback: "Please have your ID ready and point the camera at the area with the code line.\nAllow access to the camera so that the scan can be carried out. (deepl)")
  /// Where can I find the number range? (deepl)
  public static let tkGetEidStartScanLinkText = L10n.tr("Localizable", "tk_getEid_startScan_linkText", fallback: "Where can I find the number range? (deepl)")
  /// Scan number range (deepl)
  public static let tkGetEidStartScanTitle = L10n.tr("Localizable", "tk_getEid_startScan_title", fallback: "Scan number range (deepl)")
  /// Möchten Sie Ihre e-ID auf weiteren Geräten speichern? (deepl)
  public static let tkGetEidWalletPairing1Body = L10n.tr("Localizable", "tk_getEid_walletPairing1_body", fallback: "Möchten Sie Ihre e-ID auf weiteren Geräten speichern? (deepl)")
  /// Nur dieses Gerät (deepl)
  public static let tkGetEidWalletPairing1PrimaryButton = L10n.tr("Localizable", "tk_getEid_walletPairing1_primaryButton", fallback: "Nur dieses Gerät (deepl)")
  /// Weitere Geräte (deepl)
  public static let tkGetEidWalletPairing1SecondaryButton = L10n.tr("Localizable", "tk_getEid_walletPairing1_secondaryButton", fallback: "Weitere Geräte (deepl)")
  /// Hinweis
  /// Aus Sicherheitsgründen können Sie dies nur jetzt festlegen. Nachträglich ist es nicht mehr möglich, Ihre e-ID auf weiteren Geräten zu speichern. (deepl)
  public static let tkGetEidWalletPairing1SmallBody = L10n.tr("Localizable", "tk_getEid_walletPairing1_smallBody", fallback: "Hinweis\nAus Sicherheitsgründen können Sie dies nur jetzt festlegen. Nachträglich ist es nicht mehr möglich, Ihre e-ID auf weiteren Geräten zu speichern. (deepl)")
  /// Weitere Geräte festlegen (deepl)
  public static let tkGetEidWalletPairing1Title = L10n.tr("Localizable", "tk_getEid_walletPairing1_title", fallback: "Weitere Geräte festlegen (deepl)")
  /// Add
  public static let tkGlobalAddPrimarybutton = L10n.tr("Localizable", "tk_global_add_primarybutton", fallback: "Add")
  /// Allow
  public static let tkGlobalAllowPrimarybutton = L10n.tr("Localizable", "tk_global_allow_primarybutton", fallback: "Allow")
  /// Back
  public static let tkGlobalBackAlt = L10n.tr("Localizable", "tk_global_back_alt", fallback: "Back")
  /// https://www.bcs.admin.ch/bcs-web/?lang=EN
  public static let tkGlobalBetaidUrl = L10n.tr("Localizable", "tk_global_betaid_url", fallback: "https://www.bcs.admin.ch/bcs-web/?lang=EN")
  /// Cancel
  public static let tkGlobalCancel = L10n.tr("Localizable", "tk_global_cancel", fallback: "Cancel")
  /// Change password
  public static let tkGlobalChangepassword = L10n.tr("Localizable", "tk_global_changepassword", fallback: "Change password")
  /// Would like to check your age
  public static let tkGlobalCheckage = L10n.tr("Localizable", "tk_global_checkage", fallback: "Would like to check your age")
  /// Done
  public static let tkGlobalClose = L10n.tr("Localizable", "tk_global_close", fallback: "Done")
  /// Close details
  public static let tkGlobalClosedetailsAlt = L10n.tr("Localizable", "tk_global_closedetails_alt", fallback: "Close details")
  /// Close learner's licence
  public static let tkGlobalCloseelfaAlt = L10n.tr("Localizable", "tk_global_closeelfa_alt", fallback: "Close learner's licence")
  /// Close warning
  public static let tkGlobalClosewarningAlt = L10n.tr("Localizable", "tk_global_closewarning_alt", fallback: "Close warning")
  /// Next
  public static let tkGlobalContinue = L10n.tr("Localizable", "tk_global_continue", fallback: "Next")
  /// Credential
  public static let tkGlobalCredential = L10n.tr("Localizable", "tk_global_credential", fallback: "Credential")
  /// Delete
  public static let tkGlobalDelete = L10n.tr("Localizable", "tk_global_delete", fallback: "Delete")
  /// Open details
  public static let tkGlobalDetailsAlt = L10n.tr("Localizable", "tk_global_details_alt", fallback: "Open details")
  /// Enter password
  public static let tkGlobalEnterpassword = L10n.tr("Localizable", "tk_global_enterpassword", fallback: "Enter password")
  /// https://www.bcs.admin.ch/bcs-web/?lang=EN
  public static let tkGlobalGetbetaidLinkValue = L10n.tr("Localizable", "tk_global_getbetaid_link_value", fallback: "https://www.bcs.admin.ch/bcs-web/?lang=EN")
  /// Create Beta-ID
  public static let tkGlobalGetbetaidPrimarybutton = L10n.tr("Localizable", "tk_global_getbetaid_primarybutton", fallback: "Create Beta-ID")
  /// Show password
  public static let tkGlobalInvisibleAlt = L10n.tr("Localizable", "tk_global_invisible_alt", fallback: "Show password")
  /// Login
  public static let tkGlobalLoginPrimarybutton = L10n.tr("Localizable", "tk_global_login_primarybutton", fallback: "Login")
  /// Log in with password
  public static let tkGlobalLoginpasswordSecondarybutton = L10n.tr("Localizable", "tk_global_loginpassword_secondarybutton", fallback: "Log in with password")
  /// Logo
  public static let tkGlobalLogoAlt = L10n.tr("Localizable", "tk_global_logo_alt", fallback: "Logo")
  /// More options
  public static let tkGlobalMoreoptionsAlt = L10n.tr("Localizable", "tk_global_moreoptions_alt", fallback: "More options")
  /// ...
  public static let tkGlobalMoreoptionsSecondarybutton = L10n.tr("Localizable", "tk_global_moreoptions_secondarybutton", fallback: "...")
  /// New password
  public static let tkGlobalNewpassword = L10n.tr("Localizable", "tk_global_newpassword", fallback: "New password")
  /// No thanks
  public static let tkGlobalNo = L10n.tr("Localizable", "tk_global_no", fallback: "No thanks")
  /// n/a
  public static let tkGlobalNotAssigned = L10n.tr("Localizable", "tk_global_notAssigned", fallback: "n/a")
  /// Not verified
  public static let tkGlobalNotVerified = L10n.tr("Localizable", "tk_global_notVerified", fallback: "Not verified")
  /// Scan
  public static let tkGlobalScanPrimarybutton = L10n.tr("Localizable", "tk_global_scan_primarybutton", fallback: "Scan")
  /// Scan
  public static let tkGlobalScanPrimarybuttonAlt = L10n.tr("Localizable", "tk_global_scan_primarybutton_alt", fallback: "Scan")
  /// Scan QR code
  public static let tkGlobalScanqrcode = L10n.tr("Localizable", "tk_global_scanqrcode", fallback: "Scan QR code")
  /// Skip
  public static let tkGlobalSkip = L10n.tr("Localizable", "tk_global_skip", fallback: "Skip")
  /// Go to settings
  public static let tkGlobalTothesettings = L10n.tr("Localizable", "tk_global_tothesettings", fallback: "Go to settings")
  /// Verified
  public static let tkGlobalVerified = L10n.tr("Localizable", "tk_global_verified", fallback: "Verified")
  /// Hide password
  public static let tkGlobalVisibleAlt = L10n.tr("Localizable", "tk_global_visible_alt", fallback: "Hide password")
  /// Warning
  public static let tkGlobalWarningAlt = L10n.tr("Localizable", "tk_global_warning_alt", fallback: "Warning")
  /// Welcome back
  public static let tkGlobalWelcomeback = L10n.tr("Localizable", "tk_global_welcomeback", fallback: "Welcome back")
  /// Report incorrect details
  public static let tkGlobalWrongdata = L10n.tr("Localizable", "tk_global_wrongdata", fallback: "Report incorrect details")
  /// To add IDs and documents, scan the QR code or open the link in the text message.
  public static let tkHomeEmpthyhomeBody = L10n.tr("Localizable", "tk_home_empthyhome_body", fallback: "To add IDs and documents, scan the QR code or open the link in the text message.")
  /// Wallet empty
  public static let tkHomeEmpthyhomeTitle = L10n.tr("Localizable", "tk_home_empthyhome_title", fallback: "Wallet empty")
  /// To add IDs and documents, scan the QR code or open the link in the text message.
  public static let tkHomeFirstuseBody = L10n.tr("Localizable", "tk_home_firstuse_body", fallback: "To add IDs and documents, scan the QR code or open the link in the text message.")
  /// Wallet empty
  public static let tkHomeFirstuseTitle = L10n.tr("Localizable", "tk_home_firstuse_title", fallback: "Wallet empty")
  /// swiyu app start screen
  public static let tkHomeHomescreenAlt = L10n.tr("Localizable", "tk_home_homescreen_alt", fallback: "swiyu app start screen")
  /// Not verified
  public static let tkIssuerNotTrusted = L10n.tr("Localizable", "tk_issuer_notTrusted", fallback: "Not verified")
  /// Verified
  public static let tkIssuerTrusted = L10n.tr("Localizable", "tk_issuer_trusted", fallback: "Verified")
  /// Confirm swiyu app password
  public static let tkLoginConfirmPasswordAlt = L10n.tr("Localizable", "tk_login_confirmPassword_alt", fallback: "Confirm swiyu app password")
  /// Retry
  public static let tkLoginFacenotrecognised1Body = L10n.tr("Localizable", "tk_login_facenotrecognised1_body", fallback: "Retry")
  /// Cancel
  public static let tkLoginFacenotrecognised1Secondarybutton = L10n.tr("Localizable", "tk_login_facenotrecognised1_secondarybutton", fallback: "Cancel")
  /// Face not recognised
  public static let tkLoginFacenotrecognised1Title = L10n.tr("Localizable", "tk_login_facenotrecognised1_title", fallback: "Face not recognised")
  /// Enter password
  public static let tkLoginFacenotrecognised2Body = L10n.tr("Localizable", "tk_login_facenotrecognised2_body", fallback: "Enter password")
  /// Enter password
  public static let tkLoginFacenotrecognised2Primarybutton = L10n.tr("Localizable", "tk_login_facenotrecognised2_primarybutton", fallback: "Enter password")
  /// Please unlock the app to continue.
  public static let tkLoginFailedBody = L10n.tr("Localizable", "tk_login_failed_body", fallback: "Please unlock the app to continue.")
  /// Login
  public static let tkLoginFailedTitle = L10n.tr("Localizable", "tk_login_failed_title", fallback: "Login")
  /// More information
  public static let tkLoginForgottenpasswordAlt = L10n.tr("Localizable", "tk_login_forgottenpassword_alt", fallback: "More information")
  /// Forgotten your password?
  public static let tkLoginLockedSecondarybuttonText = L10n.tr("Localizable", "tk_login_locked_secondarybutton_text", fallback: "Forgotten your password?")
  /// https://www.eid.admin.ch/en/help-publicbeta-e
  public static let tkLoginLockedSecondarybuttonValue = L10n.tr("Localizable", "tk_login_locked_secondarybutton_value", fallback: "https://www.eid.admin.ch/en/help-publicbeta-e")
  /// Sorry, the swiyu app is currently unavailable. Please try again later.
  public static let tkLoginLockedTitle = L10n.tr("Localizable", "tk_login_locked_title", fallback: "Sorry, the swiyu app is currently unavailable. Please try again later.")
  /// Enter swiyu app password
  public static let tkLoginPasswordAlt = L10n.tr("Localizable", "tk_login_password_alt", fallback: "Enter swiyu app password")
  /// Please enter your password:
  public static let tkLoginPasswordBody = L10n.tr("Localizable", "tk_login_password_body", fallback: "Please enter your password:")
  /// Password
  public static let tkLoginPasswordNote = L10n.tr("Localizable", "tk_login_password_note", fallback: "Password")
  /// Password incorrect. Please try again.
  public static let tkLoginPasswordfailedAlt = L10n.tr("Localizable", "tk_login_passwordfailed_alt", fallback: "Password incorrect. Please try again.")
  /// Please enter your password
  public static let tkLoginPasswordfailedBody = L10n.tr("Localizable", "tk_login_passwordfailed_body", fallback: "Please enter your password")
  /// The password is incorrect. Please try again.
  public static let tkLoginPasswordfailedNotification = L10n.tr("Localizable", "tk_login_passwordfailed_notification", fallback: "The password is incorrect. Please try again.")
  /// Login successful. Please wait.
  public static let tkLoginSpinnerAlt = L10n.tr("Localizable", "tk_login_spinner_alt", fallback: "Login successful. Please wait.")
  /// The swiyu app is locked
  public static let tkLoginVariantBody = L10n.tr("Localizable", "tk_login_variant_body", fallback: "The swiyu app is locked")
  /// app crash (deepl)
  public static let tkMenuDiagnosticDataAppCrash = L10n.tr("Localizable", "tk_menu_diagnosticData_appCrash", fallback: "app crash (deepl)")
  /// When sharing diagnostic data, swyiu occasionally sends anonymous, non-personal information. This helps us to continuously improve the app and to fix bugs faster. It is not possible to draw any conclusions about you as a person. (deepl)
  public static let tkMenuDiagnosticDataBody = L10n.tr("Localizable", "tk_menu_diagnosticData_body", fallback: "When sharing diagnostic data, swyiu occasionally sends anonymous, non-personal information. This helps us to continuously improve the app and to fix bugs faster. It is not possible to draw any conclusions about you as a person. (deepl)")
  /// communication error (deepl)
  public static let tkMenuDiagnosticDataCommunicationError = L10n.tr("Localizable", "tk_menu_diagnosticData_communicationError", fallback: "communication error (deepl)")
  /// General error messages (deepl)
  public static let tkMenuDiagnosticDataGeneralError = L10n.tr("Localizable", "tk_menu_diagnosticData_generalError", fallback: "General error messages (deepl)")
  /// diagnostic data (deepl)
  public static let tkMenuDiagnosticDataTitle = L10n.tr("Localizable", "tk_menu_diagnosticData_title", fallback: "diagnostic data (deepl)")
  /// Create Beta-ID
  public static let tkMenuHomeListAdd = L10n.tr("Localizable", "tk_menu_homeList_add", fallback: "Create Beta-ID")
  /// Help & Contact (deepl)
  public static let tkMenuHomeListHelp = L10n.tr("Localizable", "tk_menu_homeList_help", fallback: "Help & Contact (deepl)")
  /// e-ID bestellen (deepl)
  public static let tkMenuHomeListOrderEid = L10n.tr("Localizable", "tk_Menu_HomeList_OrderEid", fallback: "e-ID bestellen (deepl)")
  /// Settings (deepl)
  public static let tkMenuHomeListSettings = L10n.tr("Localizable", "tk_menu_homeList_settings", fallback: "Settings (deepl)")
  /// www.bit.admin.ch
  public static let tkMenuImprintAdminLinkText = L10n.tr("Localizable", "tk_menu_imprint_admin_link_text", fallback: "www.bit.admin.ch")
  /// https://www.bit.admin.ch/en
  public static let tkMenuImprintAdminLinkValue = L10n.tr("Localizable", "tk_menu_imprint_admin_link_value", fallback: "https://www.bit.admin.ch/en")
  /// App Version (deepl)
  public static let tkMenuImprintAppVersion = L10n.tr("Localizable", "tk_menu_imprint_appVersion", fallback: "App Version (deepl)")
  /// Build Nummer
  public static let tkMenuImprintBuildNummer = L10n.tr("Localizable", "tk_menu_imprint_buildNummer", fallback: "Build Nummer")
  /// Federal Finance Administration FFA
  /// Federal Office of Information Technology, Systems and Telecommunication FOITT
  public static let tkMenuImprintDepartmentNote = L10n.tr("Localizable", "tk_menu_imprint_department_note", fallback: "Federal Finance Administration FFA\nFederal Office of Information Technology, Systems and Telecommunication FOITT")
  /// The authors do not accept any liability for the reliability and completeness of the information. References and links to third-party websites are outside our area of responsibility. (deepl)
  public static let tkMenuImprintDisclaimerNote = L10n.tr("Localizable", "tk_menu_imprint_disclaimer_note", fallback: "The authors do not accept any liability for the reliability and completeness of the information. References and links to third-party websites are outside our area of responsibility. (deepl)")
  /// www.github.com/admin-ch
  public static let tkMenuImprintGithubLinkText = L10n.tr("Localizable", "tk_menu_imprint_github_link_text", fallback: "www.github.com/admin-ch")
  /// https://github.com/e-id-admin
  public static let tkMenuImprintGithubLinkValue = L10n.tr("Localizable", "tk_menu_imprint_github_link_value", fallback: "https://github.com/e-id-admin")
  /// swiyu is open-source. Its source code can be viewed on GitHub. (deepl)
  public static let tkMenuImprintNote = L10n.tr("Localizable", "tk_menu_imprint_note", fallback: "swiyu is open-source. Its source code can be viewed on GitHub. (deepl)")
  /// Disclaimer (deepl)
  public static let tkMenuImprintSubtitleDisclaimer = L10n.tr("Localizable", "tk_menu_imprint_subtitle_disclaimer", fallback: "Disclaimer (deepl)")
  /// Legal (deepl)
  public static let tkMenuImprintSubtitleLegal = L10n.tr("Localizable", "tk_menu_imprint_subtitle_legal", fallback: "Legal (deepl)")
  /// Publisher, implementation and operation (deepl)
  public static let tkMenuImprintSubtitlePublisher = L10n.tr("Localizable", "tk_menu_imprint_subtitle_publisher", fallback: "Publisher, implementation and operation (deepl)")
  /// Terms of use
  public static let tkMenuImprintTermsOfUseLinkText = L10n.tr("Localizable", "tk_menu_imprint_termsOfUse_link_text", fallback: "Terms of use")
  /// https://www.eid.admin.ch/en/swiyu-terms-e
  public static let tkMenuImprintTermsOfUseLinkValue = L10n.tr("Localizable", "tk_menu_imprint_termsOfUse_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-terms-e")
  /// Imprint
  public static let tkMenuImprintTitle = L10n.tr("Localizable", "tk_menu_imprint_title", fallback: "Imprint")
  /// Language (deepl)
  public static let tkMenuLanguageTitle = L10n.tr("Localizable", "tk_menu_language_title", fallback: "Language (deepl)")
  /// The following is a list of the software licences used by this app.
  ///
  /// The licences follow the guidelines of the Federal IT Office for compliance with privacy and the latest security standards. With this list, we want to ensure transparency for users.
  public static let tkMenuLicencesBody = L10n.tr("Localizable", "tk_menu_licences_body", fallback: "The following is a list of the software licences used by this app.\n\nThe licences follow the guidelines of the Federal IT Office for compliance with privacy and the latest security standards. With this list, we want to ensure transparency for users.")
  /// Further information (deepl)
  public static let tkMenuLicencesLinkText = L10n.tr("Localizable", "tk_menu_licences_link_text", fallback: "Further information (deepl)")
  /// Licences
  public static let tkMenuLicencesTitle = L10n.tr("Localizable", "tk_menu_licences_title", fallback: "Licences")
  /// Biometric unlocking has been activated.
  public static let tkMenuSecurityPrivacyAndroidStatusActivating = L10n.tr("Localizable", "tk_menu_securityPrivacy_android_status_activating", fallback: "Biometric unlocking has been activated.")
  /// diagnostic data (deepl)
  public static let tkMenuSecurityPrivacyDataProtectionDiagnosticData = L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_diagnosticData", fallback: "diagnostic data (deepl)")
  /// Privacy Statement (deepl)
  public static let tkMenuSecurityPrivacyDataProtectionPrivacyPolicy = L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_privacyPolicy", fallback: "Privacy Statement (deepl)")
  /// Share diagnostic data (deepl)
  public static let tkMenuSecurityPrivacyDataProtectionShareData = L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_shareData", fallback: "Share diagnostic data (deepl)")
  /// Help us improve swyiu by allowing the occasional, anonymous submission of information such as error messages and crashes. (deepl)
  public static let tkMenuSecurityPrivacyDataProtectionShareDataBody = L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_shareData_body", fallback: "Help us improve swyiu by allowing the occasional, anonymous submission of information such as error messages and crashes. (deepl)")
  /// Change password (deepl)
  public static let tkMenuSecurityPrivacySecurityChangePassword = L10n.tr("Localizable", "tk_menu_securityPrivacy_security_changePassword", fallback: "Change password (deepl)")
  /// Password successfully changed
  public static let tkMenuSecurityPrivacyStatusPasswordChangeSuccessful = L10n.tr("Localizable", "tk_menu_securityPrivacy_status_passwordChangeSuccessful", fallback: "Password successfully changed")
  /// Data protection and privacy (deepl)
  public static let tkMenuSecurityPrivacySubtitleDataProtection = L10n.tr("Localizable", "tk_menu_securityPrivacy_subtitle_dataProtection", fallback: "Data protection and privacy (deepl)")
  /// Security
  public static let tkMenuSecurityPrivacySubtitleSecurity = L10n.tr("Localizable", "tk_menu_securityPrivacy_subtitle_security", fallback: "Security")
  /// Security and data protection (deepl)
  public static let tkMenuSecurityPrivacyTitle = L10n.tr("Localizable", "tk_menu_securityPrivacy_title", fallback: "Security and data protection (deepl)")
  /// General (deepl)
  public static let tkMenuSettingSubtitleGeneral = L10n.tr("Localizable", "tk_menu_setting_subtitle_general", fallback: "General (deepl)")
  /// Settings (deepl)
  public static let tkMenuSettingTitle = L10n.tr("Localizable", "tk_menu_setting_title", fallback: "Settings (deepl)")
  /// Share feedback
  public static let tkMenuSettingWalletFeedback = L10n.tr("Localizable", "tk_menu_setting_wallet_feedback", fallback: "Share feedback")
  /// https://findmind.ch/c/feedback_public_beta_en
  public static let tkMenuSettingWalletFeedbackLinkValue = L10n.tr("Localizable", "tk_menu_setting_wallet_feedback_link_value", fallback: "https://findmind.ch/c/feedback_public_beta_en")
  /// Help & Contact (deepl)
  public static let tkMenuSettingWalletHelp = L10n.tr("Localizable", "tk_menu_setting_wallet_help", fallback: "Help & Contact (deepl)")
  /// Imprint (deepl)
  public static let tkMenuSettingWalletImprint = L10n.tr("Localizable", "tk_menu_setting_wallet_imprint", fallback: "Imprint (deepl)")
  /// Language (deepl)
  public static let tkMenuSettingWalletLanguage = L10n.tr("Localizable", "tk_menu_setting_wallet_language", fallback: "Language (deepl)")
  /// German (deepl)
  public static let tkMenuSettingWalletLanguageChoiceDe = L10n.tr("Localizable", "tk_menu_setting_wallet_languageChoiceDe", fallback: "German (deepl)")
  /// Licences (deepl)
  public static let tkMenuSettingWalletLicences = L10n.tr("Localizable", "tk_menu_setting_wallet_licences", fallback: "Licences (deepl)")
  /// Security and data protection
  public static let tkMenuSettingWalletSecurity = L10n.tr("Localizable", "tk_menu_setting_wallet_security", fallback: "Security and data protection")
  /// Share feedback
  public static let tkMenuSetupMenuFeedback = L10n.tr("Localizable", "tk_menu_setup_menu_feedback", fallback: "Share feedback")
  /// Wallet
  public static let tkMenuSetupSubtitleWallet = L10n.tr("Localizable", "tk_menu_setup_subtitle_wallet", fallback: "Wallet")
  /// Allow
  public static let tkOnboardingAnalyticsButtonPrimary = L10n.tr("Localizable", "tk_onboarding_analytics_button_primary", fallback: "Allow")
  /// Do not allow
  public static let tkOnboardingAnalyticsButtonSecondary = L10n.tr("Localizable", "tk_onboarding_analytics_button_secondary", fallback: "Do not allow")
  /// Contribute anonymously to improving the app
  public static let tkOnboardingAnalyticsPrimary = L10n.tr("Localizable", "tk_onboarding_analytics_primary", fallback: "Contribute anonymously to improving the app")
  /// Take advantage of an app tailored to your needs. Do you want to share your anonymous user data with the development team in return?
  public static let tkOnboardingAnalyticsSecondary = L10n.tr("Localizable", "tk_onboarding_analytics_secondary", fallback: "Take advantage of an app tailored to your needs. Do you want to share your anonymous user data with the development team in return?")
  /// Link to exit swiyu app
  public static let tkOnboardingAnalyticsTertiaryLinkAlt = L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_alt", fallback: "Link to exit swiyu app")
  /// Data protection and security
  public static let tkOnboardingAnalyticsTertiaryLinkText = L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_text", fallback: "Data protection and security")
  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static let tkOnboardingAnalyticsTertiaryLinkValue = L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e")
  /// Yes please
  public static let tkOnboardingBiometricsPermissionButtonPrimary = L10n.tr("Localizable", "tk_onboarding_biometricsPermission_button_primary", fallback: "Yes please")
  /// You can still log in with your password, if biometrics are not working
  public static let tkOnboardingBiometricsPermissionReason = L10n.tr("Localizable", "tk_onboarding_biometricsPermission_reason", fallback: "You can still log in with your password, if biometrics are not working")
  /// Go to settings
  public static let tkOnboardingBiometricsPermissionDisabledButtonPrimary = L10n.tr("Localizable", "tk_onboarding_biometricsPermissionDisabled_button_primary", fallback: "Go to settings")
  /// Password must be at least 6 characters
  public static let tkOnboardingCharactersSubtitle = L10n.tr("Localizable", "tk_onboarding_characters_subtitle", fallback: "Password must be at least 6 characters")
  /// Confirm password
  public static let tkOnboardingConfirmNote = L10n.tr("Localizable", "tk_onboarding_confirm_note", fallback: "Confirm password")
  /// All done!
  public static let tkOnboardingDonePrimary = L10n.tr("Localizable", "tk_onboarding_done_primary", fallback: "All done!")
  /// Your swiyu app now has optimal protection against unauthorised access.
  public static let tkOnboardingDoneSecondary = L10n.tr("Localizable", "tk_onboarding_done_secondary", fallback: "Your swiyu app now has optimal protection against unauthorised access.")
  /// Try again
  public static let tkOnboardingDoneErrorButtonPrimary = L10n.tr("Localizable", "tk_onboarding_doneError_button_primary", fallback: "Try again")
  /// Something has gone wrong
  public static let tkOnboardingDoneErrorPrimary = L10n.tr("Localizable", "tk_onboarding_doneError_primary", fallback: "Something has gone wrong")
  /// We cannot setup the app at the moment. Please try again.
  public static let tkOnboardingDoneErrorSecondary = L10n.tr("Localizable", "tk_onboarding_doneError_secondary", fallback: "We cannot setup the app at the moment. Please try again.")
  /// Never forget your ID again
  public static let tkOnboardingIntroductionStepNeverForgetPrimary = L10n.tr("Localizable", "tk_onboarding_introductionStep_neverForget_primary", fallback: "Never forget your ID again")
  /// Thanks to the swiyu app, you always have your ID with you on your mobile phone.
  public static let tkOnboardingIntroductionStepNeverForgetSecondary = L10n.tr("Localizable", "tk_onboarding_introductionStep_neverForget_secondary", fallback: "Thanks to the swiyu app, you always have your ID with you on your mobile phone.")
  /// Start
  public static let tkOnboardingIntroductionStepSecurityButtonPrimary = L10n.tr("Localizable", "tk_onboarding_introductionStep_security_button_primary", fallback: "Start")
  /// Storing digital IDs securely
  public static let tkOnboardingIntroductionStepSecurityPrimary = L10n.tr("Localizable", "tk_onboarding_introductionStep_security_primary", fallback: "Storing digital IDs securely")
  /// Welcome to the onboarding for the swiyu app.
  public static let tkOnboardingIntroductionStepSecurityScreenAlt = L10n.tr("Localizable", "tk_onboarding_introductionStep_security_screen_alt", fallback: "Welcome to the onboarding for the swiyu app.")
  /// Your ID data is encrypted and stored locally in the swiyu app on your mobile phone.
  public static let tkOnboardingIntroductionStepSecuritySecondary = L10n.tr("Localizable", "tk_onboarding_introductionStep_security_secondary", fallback: "Your ID data is encrypted and stored locally in the swiyu app on your mobile phone.")
  /// Your data belongs to you
  public static let tkOnboardingIntroductionStepYourDataPrimary = L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_primary", fallback: "Your data belongs to you")
  /// You have control over who can check your ID data, and when. No access without permission.
  public static let tkOnboardingIntroductionStepYourDataSecondary = L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_secondary", fallback: "You have control over who can check your ID data, and when. No access without permission.")
  /// Learn more about SSI technology
  public static let tkOnboardingIntroductionStepYourDataTertiaryLinkText = L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_text", fallback: "Learn more about SSI technology")
  /// Link to exit swiyu app
  public static let tkOnboardingIntroductionStepYourDataTertiaryLinkTextAlt = L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_text_alt", fallback: "Link to exit swiyu app")
  /// https://www.eid.admin.ch/en/technology
  public static let tkOnboardingIntroductionStepYourDataTertiaryLinkValue = L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_value", fallback: "https://www.eid.admin.ch/en/technology")
  /// Please confirm the password
  public static let tkOnboardingNopasswordmismatchAlt = L10n.tr("Localizable", "tk_onboarding_nopasswordmismatch_alt", fallback: "Please confirm the password")
  /// The passwords do not match. Please try again.
  public static let tkOnboardingNopasswordmismatchNotification = L10n.tr("Localizable", "tk_onboarding_nopasswordmismatch_notification", fallback: "The passwords do not match. Please try again.")
  /// Please enter your password
  public static let tkOnboardingPasswordErrorEmpty = L10n.tr("Localizable", "tk_onboarding_password_error_empty", fallback: "Please enter your password")
  /// Password mismatch
  public static let tkOnboardingPasswordErrorMismatch = L10n.tr("Localizable", "tk_onboarding_password_error_mismatch", fallback: "Password mismatch")
  /// Enter swiyu app password
  public static let tkOnboardingPasswordInputAlt = L10n.tr("Localizable", "tk_onboarding_password_input_alt", fallback: "Enter swiyu app password")
  /// Password
  public static let tkOnboardingPasswordInputPlaceholder = L10n.tr("Localizable", "tk_onboarding_password_input_placeholder", fallback: "Password")
  /// Password must be at least 6 characters
  public static let tkOnboardingPasswordInputSubtitle = L10n.tr("Localizable", "tk_onboarding_password_input_subtitle", fallback: "Password must be at least 6 characters")
  /// Password
  public static let tkOnboardingPasswordPlaceholder = L10n.tr("Localizable", "tk_onboarding_password_placeholder", fallback: "Password")
  /// Enter password
  public static let tkOnboardingPasswordTitle = L10n.tr("Localizable", "tk_onboarding_password_title", fallback: "Enter password")
  /// Enter swiyu app password
  public static let tkOnboardingPasswordConfirmationInputAlt = L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_alt", fallback: "Enter swiyu app password")
  /// The password is incorrect. Please try again.
  public static let tkOnboardingPasswordConfirmationInputErrorWrongPassword = L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_error_wrongPassword", fallback: "The password is incorrect. Please try again.")
  /// Password
  public static let tkOnboardingPasswordConfirmationInputPlaceholder = L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_placeholder", fallback: "Password")
  /// Confirm password
  public static let tkOnboardingPasswordConfirmationTitle = L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_title", fallback: "Confirm password")
  /// Create password
  public static let tkOnboardingPassworderrorPrimarybutton = L10n.tr("Localizable", "tk_onboarding_passworderror_primarybutton", fallback: "Create password")
  /// Failed to set up the password
  public static let tkOnboardingPassworderrorTitle = L10n.tr("Localizable", "tk_onboarding_passworderror_title", fallback: "Failed to set up the password")
  /// Enter password
  public static let tkOnboardingPasswordIntroductionButtonPrimary = L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_button_primary", fallback: "Enter password")
  /// Incorrect password entered too many times. Please set a new password.
  public static let tkOnboardingPasswordIntroductionErrorTooManyAttempts = L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_error_tooManyAttempts", fallback: "Incorrect password entered too many times. Please set a new password.")
  /// Secure the app with a password
  public static let tkOnboardingPasswordIntroductionPrimary = L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_primary", fallback: "Secure the app with a password")
  /// Protect your app from unauthorised access.
  public static let tkOnboardingPasswordIntroductionSecondary = L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_secondary", fallback: "Protect your app from unauthorised access.")
  /// Password must be at least 6 characters
  public static let tkOnboardingPasswordlengthNotification = L10n.tr("Localizable", "tk_onboarding_passwordlength_notification", fallback: "Password must be at least 6 characters")
  /// Please wait a moment...
  public static let tkOnboardingSetupPrimary = L10n.tr("Localizable", "tk_onboarding_setup_primary", fallback: "Please wait a moment...")
  /// Your settings are being applied. This may take up to 30 seconds.
  public static let tkOnboardingSetupSecondary = L10n.tr("Localizable", "tk_onboarding_setup_secondary", fallback: "Your settings are being applied. This may take up to 30 seconds.")
  /// Sorry, the swiyu app cannot currently be loaded. Please try again.
  public static let tkOnboardingSomethingwentwrongBody = L10n.tr("Localizable", "tk_onboarding_somethingwentwrong_body", fallback: "Sorry, the swiyu app cannot currently be loaded. Please try again.")
  /// Try again
  public static let tkOnboardingSomethingwentwrongPrimarybutton = L10n.tr("Localizable", "tk_onboarding_somethingwentwrong_primarybutton", fallback: "Try again")
  /// Something went wrong
  public static let tkOnboardingSomethingwentwrongTitle = L10n.tr("Localizable", "tk_onboarding_somethingwentwrong_title", fallback: "Something went wrong")
  /// Requested data
  public static let tkPresentApprovalTitle = L10n.tr("Localizable", "tk_present_approval_title", fallback: "Requested data")
  /// Select ID or document
  public static let tkPresentCompatibleCredentialsPrimary = L10n.tr("Localizable", "tk_present_compatibleCredentials_primary", fallback: "Select ID or document")
  /// Sorry, no details could be sent
  public static let tkPresentNoinformationprovidedTitle = L10n.tr("Localizable", "tk_present_noinformationprovided_title", fallback: "Sorry, no details could be sent")
  /// Aborted verification
  public static let tkPresentResultCanceledVerificationPrimary = L10n.tr("Localizable", "tk_present_result_canceledVerification_primary", fallback: "Aborted verification")
  /// The verification was canceled and no data was transferred.
  public static let tkPresentResultCanceledVerificationSecondary = L10n.tr("Localizable", "tk_present_result_canceledVerification_secondary", fallback: "The verification was canceled and no data was transferred.")
  /// Confirmation
  public static let tkPresentResultConfirmAlt = L10n.tr("Localizable", "tk_present_result_confirm_alt", fallback: "Confirmation")
  /// Data was not transmitted
  public static let tkPresentResultDeclinedPrimary = L10n.tr("Localizable", "tk_present_result_declined_primary", fallback: "Data was not transmitted")
  /// Try again
  public static let tkPresentResultErrorButtonRetry = L10n.tr("Localizable", "tk_present_result_error_button_retry", fallback: "Try again")
  /// Oops, something went wrong!
  public static let tkPresentResultErrorPrimary = L10n.tr("Localizable", "tk_present_result_error_primary", fallback: "Oops, something went wrong!")
  /// Please try again
  public static let tkPresentResultErrorSecondary = L10n.tr("Localizable", "tk_present_result_error_secondary", fallback: "Please try again")
  /// Verification of the transmitted data failed.
  public static let tkPresentResultInvalidCredentialPrimary = L10n.tr("Localizable", "tk_present_result_invalidCredential_primary", fallback: "Verification of the transmitted data failed.")
  /// Please check the validity of your credential.
  public static let tkPresentResultInvalidCredentialSecondary = L10n.tr("Localizable", "tk_present_result_invalidCredential_secondary", fallback: "Please check the validity of your credential.")
  /// Your details have been successfully checked.
  public static let tkPresentResultSuccessPrimary = L10n.tr("Localizable", "tk_present_result_success_primary", fallback: "Your details have been successfully checked.")
  /// Required credential available
  public static let tkPresentResultSuccessPrimary2 = L10n.tr("Localizable", "tk_present_result_success_primary2", fallback: "Required credential available")
  /// Warning
  public static let tkPresentResultWarningAlt = L10n.tr("Localizable", "tk_present_result_warning_alt", fallback: "Warning")
  /// Would like to check your credential
  public static let tkPresentReviewCredentialSectionPrimary = L10n.tr("Localizable", "tk_present_review_credential_section_primary", fallback: "Would like to check your credential")
  /// Please wait
  public static let tkPresentReviewLoading = L10n.tr("Localizable", "tk_present_review_loading", fallback: "Please wait")
  /// Please wait. Your data are being sent.
  public static let tkPresentReviewLoadingAlt = L10n.tr("Localizable", "tk_present_review_loading_alt", fallback: "Please wait. Your data are being sent.")
  /// Allow
  public static let tkPresentReviewPrimaryButton = L10n.tr("Localizable", "tk_present_review_primaryButton", fallback: "Allow")
  /// Share information
  public static let tkPresentReviewPrimaryButtonAlt = L10n.tr("Localizable", "tk_present_review_primaryButton_alt", fallback: "Share information")
  /// Decline
  public static let tkPresentReviewSecondaryButton = L10n.tr("Localizable", "tk_present_review_secondaryButton", fallback: "Decline")
  /// Deny
  public static let tkPresentReviewSecondaryButtonAlt = L10n.tr("Localizable", "tk_present_review_secondaryButton_alt", fallback: "Deny")
  /// Unknown verifier
  public static let tkPresentVerifierNameUnknown = L10n.tr("Localizable", "tk_present_verifier_name_unknown", fallback: "Unknown verifier")
  /// Close QR code scanner
  public static let tkQrscannerButtonCloseAlt = L10n.tr("Localizable", "tk_qrscanner_button_close_alt", fallback: "Close QR code scanner")
  /// This QR code has already been used. Please request a new QR code.
  public static let tkQrscannerInvalidcodeBody = L10n.tr("Localizable", "tk_qrscanner_invalidcode_body", fallback: "This QR code has already been used. Please request a new QR code.")
  /// Was the QR code used without your knowledge?
  public static let tkQrscannerInvalidcodeLinkText = L10n.tr("Localizable", "tk_qrscanner_invalidcode_link_text", fallback: "Was the QR code used without your knowledge?")
  /// https://www.eid.admin.ch/en
  public static let tkQrscannerInvalidcodeLinkValue = L10n.tr("Localizable", "tk_qrscanner_invalidcode_link_value", fallback: "https://www.eid.admin.ch/en")
  /// QR code no longer valid
  public static let tkQrscannerInvalidcodeTitle = L10n.tr("Localizable", "tk_qrscanner_invalidcode_title", fallback: "QR code no longer valid")
  /// Flashlight off. Double tap to turn on
  public static let tkQrscannerLightoffLabel = L10n.tr("Localizable", "tk_qrscanner_lightoff_label", fallback: "Flashlight off. Double tap to turn on")
  /// Flashlight on. Double tap to turn off
  public static let tkQrscannerLightonLabel = L10n.tr("Localizable", "tk_qrscanner_lighton_label", fallback: "Flashlight on. Double tap to turn off")
  /// Turn light on
  public static let tkQrscannerLightonTitle = L10n.tr("Localizable", "tk_qrscanner_lighton_title", fallback: "Turn light on")
  /// More light needed
  public static let tkQrscannerMorelightneededTitle = L10n.tr("Localizable", "tk_qrscanner_morelightneeded_title", fallback: "More light needed")
  /// QR code scanned
  public static let tkQrscannerProcessingAlt = L10n.tr("Localizable", "tk_qrscanner_processing_alt", fallback: "QR code scanned")
  /// To identify yourself or add IDs and documents.
  public static let tkQrscannerScanningBody = L10n.tr("Localizable", "tk_qrscanner_scanning_body", fallback: "To identify yourself or add IDs and documents.")
  /// Scan QR code
  public static let tkQrscannerScanningTitle = L10n.tr("Localizable", "tk_qrscanner_scanning_title", fallback: "Scan QR code")
  /// Go to details
  public static let tkReceiveApprovalHiddenlinkText = L10n.tr("Localizable", "tk_receive_approval_hiddenlink_text", fallback: "Go to details")
  /// Would like to issue the following credential:
  public static let tkReceiveApprovalSubtitle = L10n.tr("Localizable", "tk_receive_approval_subtitle", fallback: "Would like to issue the following credential:")
  /// The camera is an important function. Without a camera, you cannot receive IDs and documents or identify yourself.
  public static let tkReceiveCameraaccessneeded1Body = L10n.tr("Localizable", "tk_receive_cameraaccessneeded1_body", fallback: "The camera is an important function. Without a camera, you cannot receive IDs and documents or identify yourself.")
  /// Allow access to camera
  public static let tkReceiveCameraaccessneeded1Title = L10n.tr("Localizable", "tk_receive_cameraaccessneeded1_title", fallback: "Allow access to camera")
  /// Camera access has expired. Please allow access again.
  public static let tkReceiveCameraaccessneeded2Body = L10n.tr("Localizable", "tk_receive_cameraaccessneeded2_body", fallback: "Camera access has expired. Please allow access again.")
  /// Allow access to camera
  public static let tkReceiveCameraaccessneeded2Title = L10n.tr("Localizable", "tk_receive_cameraaccessneeded2_title", fallback: "Allow access to camera")
  /// Please go to Settings and allow access.
  ///
  /// Without a camera, you cannot receive IDs and documents or identify yourself.
  public static let tkReceiveCameraaccessneeded3Body = L10n.tr("Localizable", "tk_receive_cameraaccessneeded3_body", fallback: "Please go to Settings and allow access.\n\nWithout a camera, you cannot receive IDs and documents or identify yourself.")
  /// Allow access to camera
  public static let tkReceiveCameraaccessneeded3Title = L10n.tr("Localizable", "tk_receive_cameraaccessneeded3_title", fallback: "Allow access to camera")
  /// The swiyu app wants to access your camera
  public static let tkReceiveCameraaccessneeded4Title = L10n.tr("Localizable", "tk_receive_cameraaccessneeded4_title", fallback: "The swiyu app wants to access your camera")
  /// Add
  public static let tkReceiveCredentialOfferButtonAccept = L10n.tr("Localizable", "tk_receive_credentialOffer_button_accept", fallback: "Add")
  /// Decline
  public static let tkReceiveCredentialOfferButtonDecline = L10n.tr("Localizable", "tk_receive_credentialOffer_button_decline", fallback: "Decline")
  /// Details
  public static let tkReceiveCredentialOfferContentSectionPrimary = L10n.tr("Localizable", "tk_receive_credentialOffer_contentSection_primary", fallback: "Details")
  /// Would like to issue the following credential:
  public static let tkReceiveCredentialOfferHeaderSectionSecondary = L10n.tr("Localizable", "tk_receive_credentialOffer_headerSection_secondary", fallback: "Would like to issue the following credential:")
  /// Found any incorrect data?
  public static let tkReceiveCredentialOfferWrongDataPrimary = L10n.tr("Localizable", "tk_receive_credentialOffer_wrongData_primary", fallback: "Found any incorrect data?")
  /// Once issued, a credential cannot be changed.
  ///
  /// If you notice an error in your data, please contact the issuer.
  /// They can issue a new, corrected credential.
  public static let tkReceiveCredentialOfferWrongDataSecondary = L10n.tr("Localizable", "tk_receive_credentialOffer_wrongData_secondary", fallback: "Once issued, a credential cannot be changed.\n\nIf you notice an error in your data, please contact the issuer.\nThey can issue a new, corrected credential.")
  /// Report incorrect details
  public static let tkReceiveCredentialOfferWrongDataSectionCellPrimary = L10n.tr("Localizable", "tk_receive_credentialOffer_wrongDataSection_cell_primary", fallback: "Report incorrect details")
  /// Decline credential?
  public static let tkReceiveDeclineOfferPrimary = L10n.tr("Localizable", "tk_receive_declineOffer_primary", fallback: "Decline credential?")
  /// Decline credential
  public static let tkReceiveDeclineOfferPrimaryButton = L10n.tr("Localizable", "tk_receive_declineOffer_primaryButton", fallback: "Decline credential")
  /// If you decline the credential now, it will immediately become invalid.
  ///
  /// You must then request a new credential.
  public static let tkReceiveDeclineOfferSecondary = L10n.tr("Localizable", "tk_receive_declineOffer_secondary", fallback: "If you decline the credential now, it will immediately become invalid.\n\nYou must then request a new credential.")
  /// Credential declined
  public static let tkReceiveDeny2Title = L10n.tr("Localizable", "tk_receive_deny2_title", fallback: "Credential declined")
  /// Report incorrect details
  public static let tkReceiveIncorrectdataTitle = L10n.tr("Localizable", "tk_receive_incorrectdata_title", fallback: "Report incorrect details")
  /// Camera searching for QR code
  public static let tkReceiveScanningAlt = L10n.tr("Localizable", "tk_receive_scanning_alt", fallback: "Camera searching for QR code")
  /// No QR code found. Try to reposition the camera.
  public static let tkReceiveScanningNotfoundAlt = L10n.tr("Localizable", "tk_receive_scanning_notfound_alt", fallback: "No QR code found. Try to reposition the camera.")
  /// Please define a smartphone passcode so that you can use the app.
  public static let tkUnsafedeviceUnsafeBody = L10n.tr("Localizable", "tk_unsafedevice_unsafe_body", fallback: "Please define a smartphone passcode so that you can use the app.")
  /// Go to settings
  public static let tkUnsafedeviceUnsafePrimaryButton = L10n.tr("Localizable", "tk_unsafedevice_unsafe_primaryButton", fallback: "Go to settings")
  ///
  public static let tkUnsafedeviceUnsafeSmallbody = L10n.tr("Localizable", "tk_unsafedevice_unsafe_smallbody", fallback: " ")
  /// Missing smartphone code
  public static let tkUnsafedeviceUnsafeTitle = L10n.tr("Localizable", "tk_unsafedevice_unsafe_title", fallback: "Missing smartphone code")
  /// Update app
  public static let versionEnforcementButton = L10n.tr("Localizable", "version_enforcement_button", fallback: "Update app")
  /// https://apps.apple.com/ch/app/swiyu/id6737259614
  public static let versionEnforcementStoreLink = L10n.tr("Localizable", "version_enforcement_store_link", fallback: "https://apps.apple.com/ch/app/swiyu/id6737259614")

  /// Would you like to activate %@ to unlock the app?
  public static func biometricSetupContent(_ p1: Any) -> String {
    L10n.tr("Localizable", "biometricSetup _content", String(describing: p1), fallback: "Would you like to activate %@ to unlock the app?")
  }

  /// You can continue to use your code if the %@ does not work.
  public static func biometricSetupDetail(_ p1: Any) -> String {
    L10n.tr("Localizable", "biometricSetup _detail", String(describing: p1), fallback: "You can continue to use your code if the %@ does not work.")
  }

  /// With %@
  public static func biometricSetupActionButton(_ p1: Any) -> String {
    L10n.tr("Localizable", "biometricSetup_actionButton", String(describing: p1), fallback: "With %@")
  }

  /// %@, Double Tap to close
  public static func biometricSetupErrorAltText(_ p1: Any) -> String {
    L10n.tr("Localizable", "biometricSetup_error_altText", String(describing: p1), fallback: "%@, Double Tap to close")
  }

  /// Use %@
  public static func biometricSetupTitle(_ p1: Any) -> String {
    L10n.tr("Localizable", "biometricSetup_title", String(describing: p1), fallback: "Use %@")
  }

  /// %@, Double Tap to close
  public static func onboardingPinCodeErrorAltText(_ p1: Any) -> String {
    L10n.tr("Localizable", "onboarding_pin_code_error_altText", String(describing: p1), fallback: "%@, Double Tap to close")
  }

  /// The password is incorrect. You have %@ attempts remaining.
  public static func tkChangepasswordError1IosNote2(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_changepassword_error1_ios_note2", String(describing: p1), fallback: "The password is incorrect. You have %@ attempts remaining.")
  }

  /// Valid in %@ days
  public static func tkCredentialStatusNotValidYet(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_credential_status_notValidYet", String(describing: p1), fallback: "Valid in %@ days")
  }

  /// Credential valid in %@ days
  public static func tkCredentialStatusNotValidYetAlt(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_credential_status_notValidYet_alt", String(describing: p1), fallback: "Credential valid in %@ days")
  }

  /// e-ID Order for %@ expired
  public static func tkGetEidNotificationEidExpiredPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_getEid_notification_eidExpired_primary", String(describing: p1), fallback: "e-ID Order for %@ expired")
  }

  /// e-ID for %@ in progress (deepl)
  public static func tkGetEidNotificationEidProgressPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_getEid_notification_eidProgress_primary", String(describing: p1), fallback: "e-ID for %@ in progress (deepl)")
  }

  /// Your e-ID will probably be ready on %@. We will notify you as soon as it is ready.  (deepl)
  public static func tkGetEidNotificationEidProgressSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_getEid_notification_eidProgress_secondary", String(describing: p1), fallback: "Your e-ID will probably be ready on %@. We will notify you as soon as it is ready.  (deepl)")
  }

  /// e-ID ready for %@ (deepl)
  public static func tkGetEidNotificationEidReadyPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_getEid_notification_eidReady_primary", String(describing: p1), fallback: "e-ID ready for %@ (deepl)")
  }

  /// Your e-ID is ready. Please start the identification process by %@ at the latest. (deepl)
  public static func tkGetEidNotificationEidReadySecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_getEid_notification_eidReady_secondary", String(describing: p1), fallback: "Your e-ID is ready. Please start the identification process by %@ at the latest. (deepl)")
  }

  /// Unlock with %@
  public static func tkGlobalLoginfaceidPrimarybutton(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_global_loginfaceid_primarybutton", String(describing: p1), fallback: "Unlock with %@")
  }

  /// You have %@ attempt(s) remaining
  public static func tkGlobalTryIos(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_global_try_ios", String(describing: p1), fallback: "You have %@ attempt(s) remaining")
  }

  /// Content list contains %s@ credential(s)
  public static func tkHomeHomeIosAlt(_ p1: UnsafePointer<CChar>) -> String {
    L10n.tr("Localizable", "tk_home_home_ios_alt", p1, fallback: "Content list contains %s@ credential(s)")
  }

  /// Try again with %@
  public static func tkLoginFacenotrecognised1Primarybutton(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_facenotrecognised1_primarybutton", String(describing: p1), fallback: "Try again with %@")
  }

  /// Please try again in %@ minutes.
  public static func tkLoginLockedBodyIos(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_locked_body_ios", String(describing: p1), fallback: "Please try again in %@ minutes.")
  }

  /// Please try again in %@ second.
  public static func tkLoginLockedBodySecondsIos(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_locked_body_seconds_ios", String(describing: p1), fallback: "Please try again in %@ second.")
  }

  /// Please try again in %@ seconds
  public static func tkLoginLockedSeconds(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_locked_seconds", String(describing: p1), fallback: "Please try again in %@ seconds")
  }

  /// Unlock swiyu app with %@
  public static func tkLoginPasswordFaceidAlt(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_password_faceid_alt", String(describing: p1), fallback: "Unlock swiyu app with %@")
  }

  /// You have %@ attempt(s) remaining
  public static func tkLoginPasswordfailedIosSubtitle(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_login_passwordfailed_ios_subtitle", String(describing: p1), fallback: "You have %@ attempt(s) remaining")
  }

  /// Enter your swiyu password to activate %@. (deepl)
  public static func tkMenuActivatingBiometricsIosBody(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_activatingBiometrics_ios_body", String(describing: p1), fallback: "Enter your swiyu password to activate %@. (deepl)")
  }

  /// Unlock with %@
  public static func tkMenuActivatingBiometricsIosTitle(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_activatingBiometrics_ios_title", String(describing: p1), fallback: "Unlock with %@")
  }

  /// Enter your swiyu password to disable %@. (deepl)
  public static func tkMenuDeactivatingBiometricsIosNote(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_deactivatingBiometrics_ios_note", String(describing: p1), fallback: "Enter your swiyu password to disable %@. (deepl)")
  }

  /// Deactivate %@
  public static func tkMenuDeactivatingBiometricsIosTitle(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_deactivatingBiometrics_ios_title", String(describing: p1), fallback: "Deactivate %@")
  }

  /// %@ successfully activated
  public static func tkMenuSecurityPrivacyIosStatusActivating(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_securityPrivacy_ios_status_activating", String(describing: p1), fallback: "%@ successfully activated")
  }

  /// %@ successfully disabled
  public static func tkMenuSecurityPrivacyIosStatusDeactivating(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_securityPrivacy_ios_status_deactivating", String(describing: p1), fallback: "%@ successfully disabled")
  }

  /// %@ is not activated on this device. Go to the device settings to activate biometrics. (deepl)
  public static func tkMenuSecurityPrivacyMenuIosUnlockBody(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_securityPrivacy_menu_ios_unlock_body", String(describing: p1), fallback: "%@ is not activated on this device. Go to the device settings to activate biometrics. (deepl)")
  }

  /// Unlock with %@ (deepl)
  public static func tkMenuSecurityPrivacySecurityIosUnlock(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_securityPrivacy_security_ios_unlock", String(describing: p1), fallback: "Unlock with %@ (deepl)")
  }

  /// %@
  public static func tkOnboardingBiometricios4Title(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricios4_title", String(describing: p1), fallback: "%@")
  }

  /// Use %@
  public static func tkOnboardingBiometricsPermissionPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermission_primary", String(describing: p1), fallback: "Use %@")
  }

  /// Do you want to use %@ to unlock the app?
  public static func tkOnboardingBiometricsPermissionSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_biometricsPermission_secondary", String(describing: p1), fallback: "Do you want to use %@ to unlock the app?")
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

  /// %@ characters entered
  public static func tkOnboardingCodeIosAlt(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_code_ios_alt", String(describing: p1), fallback: "%@ characters entered")
  }

  /// Password is too short, minimum %@ characters
  public static func tkOnboardingPasswordErrorTooShort(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_password_error_too_short", String(describing: p1), fallback: "Password is too short, minimum %@ characters")
  }

  /// You have %@ attempt(s) remaining
  public static func tkOnboardingPasswordConfirmationInputErrorNumberOfTriesLeft(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_error_numberOfTriesLeft", String(describing: p1), fallback: "You have %@ attempt(s) remaining")
  }

  /// Would like to read %@ detail(s)
  public static func tkPresentReviewClaimsSectionPrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_present_review_claims_section_primary", String(describing: p1), fallback: "Would like to read %@ detail(s)")
  }

  /// wants to issue %@ credential
  public static func tkReceiveApprovalIosSubtitle(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_receive_approval_ios_subtitle", String(describing: p1), fallback: "wants to issue %@ credential")
  }

}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}

// swiftlint:enable convenience_type
