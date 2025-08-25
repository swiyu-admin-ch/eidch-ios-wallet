// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// MARK: - L10n

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
public enum L10n {
  /// PublicBetaWallet
  public static var appName: String { L10n.tr("Localizable", "app_name", fallback: "PublicBetaWallet") }
  /// Would you like to login faster, activate your biometrics to do so.
  public static var biometricSetupDisabledContent: String { L10n.tr("Localizable", "biometricSetup _disabled_content", fallback: "Would you like to login faster, activate your biometrics to do so.") }
  /// Access your settings and configure your biometrics
  public static var biometricSetupDisabledDetail: String { L10n.tr("Localizable", "biometricSetup _disabled_detail", fallback: "Access your settings and configure your biometrics") }
  /// Biometrics disabled
  public static var biometricSetupDisabledTitle: String { L10n.tr("Localizable", "biometricSetup_disabled_title", fallback: "Biometrics disabled") }
  /// Skip
  public static var biometricSetupDismissButton: String { L10n.tr("Localizable", "biometricSetup_dismissButton", fallback: "Skip") }
  /// Face ID
  public static var biometricSetupFaceidText: String { L10n.tr("Localizable", "biometricSetup_faceid_text", fallback: "Face ID") }
  /// Register biometrics
  public static var biometricSetupNoClass3ToSettingsButton: String { L10n.tr("Localizable", "biometricSetup_noClass3_toSettingsButton", fallback: "Register biometrics") }
  /// You can still log in with your pin, if biometrics are not working
  public static var biometricSetupReason: String { L10n.tr("Localizable", "biometricSetup_reason", fallback: "You can still log in with your pin, if biometrics are not working") }
  /// TouchID
  public static var biometricSetupTouchidText: String { L10n.tr("Localizable", "biometricSetup_touchid_text", fallback: "TouchID") }
  /// MISSING: Fortfahren
  public static var cameraPermissionContinueButton: String { L10n.tr("Localizable", "cameraPermission_continue_button", fallback: "MISSING: Fortfahren") }
  /// It seems you denied the access to the camera
  public static var cameraPermissionDeniedPrimary: String { L10n.tr("Localizable", "cameraPermission_denied_primary", fallback: "It seems you denied the access to the camera") }
  /// To be able to scan QRCodes, your camera permission is required
  public static var cameraPermissionDeniedSecondary: String { L10n.tr("Localizable", "cameraPermission_denied_secondary", fallback: "To be able to scan QRCodes, your camera permission is required") }
  /// Open Settings
  public static var cameraPermissionDeniedSettingsButton: String { L10n.tr("Localizable", "cameraPermission_denied_settingsButton", fallback: "Open Settings") }
  /// MISSING: Kamerazugriff
  public static var cameraPermissionPrimary: String { L10n.tr("Localizable", "cameraPermission_primary", fallback: "MISSING: Kamerazugriff") }
  /// MISSING: Erlauben Sie den Zugriff auf die Kamera für das Scannen von QR-Codes um Ausweise zu empfangen oder eine Überprüfung durchzuführen.
  public static var cameraPermissionSecondary: String { L10n.tr("Localizable", "cameraPermission_secondary", fallback: "MISSING: Erlauben Sie den Zugriff auf die Kamera für das Scannen von QR-Codes um Ausweise zu empfangen oder eine Überprüfung durchzuführen.") }
  /// Value:
  public static var cellValueAccessibilityLabel: String { L10n.tr("Localizable", "cell_value_accessibility_label", fallback: "Value:") }
  /// Refuse
  public static var credentialOfferRefuseButton: String { L10n.tr("Localizable", "credential_offer_refuseButton", fallback: "Refuse") }
  /// Data Analysis
  public static var dataAnalysisScreenTitle: String { L10n.tr("Localizable", "dataAnalysis_screenTitle", fallback: "Data Analysis") }
  /// Help us to improve the app by allowing the following anonymised error messages to be made available to the development team:
  ///
  ///
  /// ✓ General error messages
  /// ✓ Communication errors
  /// ✓ App crashes
  ///
  ///
  /// Only anonymised data that does not allow any conclusions to be drawn about you will be analysed.
  public static var dataAnalysisText: String { L10n.tr("Localizable", "dataAnalysis_text", fallback: "Help us to improve the app by allowing the following anonymised error messages to be made available to the development team:\n\n\n✓ General error messages\n✓ Communication errors\n✓ App crashes\n\n\nOnly anonymised data that does not allow any conclusions to be drawn about you will be analysed.") }
  /// Analysis and Improvements
  public static var dataAnalysisTitle: String { L10n.tr("Localizable", "dataAnalysis_title", fallback: "Analysis and Improvements") }
  /// No data found…
  public static var emptyStateEmptyTitle: String { L10n.tr("Localizable", "emptyState_emptyTitle", fallback: "No data found…") }
  /// Oops, something went wrong…
  public static var emptyStateErrorTitle: String { L10n.tr("Localizable", "emptyState_errorTitle", fallback: "Oops, something went wrong…") }
  /// Your internet connection seems off, take a moment to check what's wrong and retry
  public static var emptyStateOfflineMessage: String { L10n.tr("Localizable", "emptyState_offlineMessage", fallback: "Your internet connection seems off, take a moment to check what's wrong and retry") }
  /// Missing internet connection
  public static var emptyStateOfflineTitle: String { L10n.tr("Localizable", "emptyState_offlineTitle", fallback: "Missing internet connection") }
  /// Back
  public static var globalBack: String { L10n.tr("Localizable", "global_back", fallback: "Back") }
  /// Back to the Wallet
  public static var globalBackHome: String { L10n.tr("Localizable", "global_back_home", fallback: "Back to the Wallet") }
  /// Cancel
  public static var globalCancel: String { L10n.tr("Localizable", "global_cancel", fallback: "Cancel") }
  /// Continue
  public static var globalContinue: String { L10n.tr("Localizable", "global_continue", fallback: "Continue") }
  /// Go to settings
  public static var globalErrorNoDevicePinButton: String { L10n.tr("Localizable", "global_error_no_device_pin_button", fallback: "Go to settings") }
  /// Please define a smartphone passcode so that you can use the app.
  public static var globalErrorNoDevicePinMessage: String { L10n.tr("Localizable", "global_error_no_device_pin_message", fallback: "Please define a smartphone passcode so that you can use the app.") }
  /// Missing smartphone code
  public static var globalErrorNoDevicePinTitle: String { L10n.tr("Localizable", "global_error_no_device_pin_title", fallback: "Missing smartphone code") }
  /// App Version
  public static var impressumAppVersion: String { L10n.tr("Localizable", "impressum_app_version", fallback: "App Version") }
  /// Build number
  public static var impressumBuildNumber: String { L10n.tr("Localizable", "impressum_build_number", fallback: "Build number") }
  /// The authors assume no liability whatsoever with regard to the reliability and completeness of the information. References and links to third-party websites are outside our area of responsibility.
  public static var impressumDisclaimerText: String { L10n.tr("Localizable", "impressum_disclaimer_text", fallback: "The authors assume no liability whatsoever with regard to the reliability and completeness of the information. References and links to third-party websites are outside our area of responsibility.") }
  /// Disclaimer
  public static var impressumDisclaimerTitle: String { L10n.tr("Localizable", "impressum_disclaimer_title", fallback: "Disclaimer") }
  /// https://www.github.com/swiyu-admin-ch
  public static var impressumGithubLink: String { L10n.tr("Localizable", "impressum_github_link", fallback: "https://www.github.com/swiyu-admin-ch") }
  /// www.github.com/swiyu-admin-ch
  public static var impressumGithubLinkText: String { L10n.tr("Localizable", "impressum_github_link_text", fallback: "www.github.com/swiyu-admin-ch") }
  /// The swiyu app is open source. Its source code can be viewed on GitHub.
  public static var impressumHeaderText: String { L10n.tr("Localizable", "impressum_header_text", fallback: "The swiyu app is open source. Its source code can be viewed on GitHub.") }
  /// https://www.eid.admin.ch/en/swiyu-terms-e
  public static var impressumLegalsLink: String { L10n.tr("Localizable", "impressum_legals_link", fallback: "https://www.eid.admin.ch/en/swiyu-terms-e") }
  /// Terms of use
  public static var impressumLegalsLinkText: String { L10n.tr("Localizable", "impressum_legals_link_text", fallback: "Terms of use") }
  /// Legals
  public static var impressumLegalsTitle: String { L10n.tr("Localizable", "impressum_legals_title", fallback: "Legals") }
  /// Publisher, implementation and operation
  public static var impressumManagerTitle: String { L10n.tr("Localizable", "impressum_manager_title", fallback: "Publisher, implementation and operation") }
  /// https://www.bit.admin.ch/en
  public static var impressumMoreInformationLink: String { L10n.tr("Localizable", "impressum_more_information_link", fallback: "https://www.bit.admin.ch/en") }
  /// www.bit.admin.ch
  public static var impressumMoreInformationLinkText: String { L10n.tr("Localizable", "impressum_more_information_link_text", fallback: "www.bit.admin.ch") }
  /// More information
  public static var impressumMoreInformationTitle: String { L10n.tr("Localizable", "impressum_more_information_title", fallback: "More information") }
  /// Publication details
  public static var impressumTitle: String { L10n.tr("Localizable", "impressum_title", fallback: "Publication details") }
  /// Our app do not allow jailbroken devices to be used. To prevent potential security leaks, we recommend you to unjailbreak your device.
  public static var jailbreakText: String { L10n.tr("Localizable", "jailbreak_text", fallback: "Our app do not allow jailbroken devices to be used. To prevent potential security leaks, we recommend you to unjailbreak your device.") }
  /// We detected a jailbreak on your system
  public static var jailbreakTitle: String { L10n.tr("Localizable", "jailbreak_title", fallback: "We detected a jailbreak on your system") }
  /// The app currently uses no libraries
  public static var licencesEmptyState: String { L10n.tr("Localizable", "licences_empty_state", fallback: "The app currently uses no libraries") }
  /// https://www.eid.admin.ch/en/help-publicbeta-e
  public static var licencesMoreInformationLink: String { L10n.tr("Localizable", "licences_more_information_link", fallback: "https://www.eid.admin.ch/en/help-publicbeta-e") }
  /// More information
  public static var licencesMoreInformationText: String { L10n.tr("Localizable", "licences_more_information_text", fallback: "More information") }
  /// -
  public static var licencesNoVersion: String { L10n.tr("Localizable", "licences_no_version", fallback: "-") }
  /// Below is the list of software licenses used by this app.
  /// The licenses follow the BIT guidelines for compliance with privacy and the latest security standards. With this list we want to ensure transparency towards the users.
  public static var licencesText: String { L10n.tr("Localizable", "licences_text", fallback: "Below is the list of software licenses used by this app.\nThe licenses follow the BIT guidelines for compliance with privacy and the latest security standards. With this list we want to ensure transparency towards the users.") }
  /// Licences
  public static var licencesTitle: String { L10n.tr("Localizable", "licences_title", fallback: "Licences") }
  /// Continue
  public static var onboardingContinue: String { L10n.tr("Localizable", "onboarding_continue", fallback: "Continue") }
  /// Start tour
  public static var onboardingIntroButtonText: String { L10n.tr("Localizable", "onboarding_intro_button_text", fallback: "Start tour") }
  /// A service of the Swiss Confederation.
  public static var onboardingIntroDetails: String { L10n.tr("Localizable", "onboarding_intro_details", fallback: "A service of the Swiss Confederation.") }
  /// A safe home for your credentials
  public static var onboardingIntroPrimary: String { L10n.tr("Localizable", "onboarding_intro_primary", fallback: "A safe home for your credentials") }
  /// Welcome on the Onboarding of the Public Beta Wallet App. A safe home for your credentials
  public static var onboardingIntroPrimaryAlt: String { L10n.tr("Localizable", "onboarding_intro_primary_alt", fallback: "Welcome on the Onboarding of the Public Beta Wallet App. A safe home for your credentials") }
  /// With publicBeta you always have your certificates at hand.
  public static var onboardingIntroSecondary: String { L10n.tr("Localizable", "onboarding_intro_secondary", fallback: "With publicBeta you always have your certificates at hand.") }
  /// Enter code
  public static var onboardingPinCodeEnterCodeButton: String { L10n.tr("Localizable", "onboarding_pin_code_enterCodeButton", fallback: "Enter code") }
  /// Incorrect password entered too many times. Please set a new password.
  public static var onboardingPinCodeErrorTooManyAttemptsText: String { L10n.tr("Localizable", "onboarding_pin_code_error_tooManyAttempts_text", fallback: "Incorrect password entered too many times. Please set a new password.") }
  /// PIN error
  public static var onboardingPinCodeErrorTooManyAttemptsTitle: String { L10n.tr("Localizable", "onboarding_pin_code_error_tooManyAttempts_title", fallback: "PIN error") }
  /// Unknown error...
  public static var onboardingPinCodeErrorUnknown: String { L10n.tr("Localizable", "onboarding_pin_code_error_unknown", fallback: "Unknown error...") }
  /// Secure your app so that your credentials are protected.
  public static var onboardingPinCodeText: String { L10n.tr("Localizable", "onboarding_pin_code_text", fallback: "Secure your app so that your credentials are protected.") }
  /// Pin Code
  public static var onboardingPinCodeTitle: String { L10n.tr("Localizable", "onboarding_pin_code_title", fallback: "Pin Code") }
  /// Easily provide your credentials
  public static var onboardingPresentPrimary: String { L10n.tr("Localizable", "onboarding_present_primary", fallback: "Easily provide your credentials") }
  /// Receive requests for credentials in the app and answer them immediately. You decide who can see which credential and when.
  public static var onboardingPresentSecondary: String { L10n.tr("Localizable", "onboarding_present_secondary", fallback: "Receive requests for credentials in the app and answer them immediately. You decide who can see which credential and when.") }
  /// Accept
  public static var onboardingPrivacyAcceptLoggingButton: String { L10n.tr("Localizable", "onboarding_privacy_acceptLoggingButton", fallback: "Accept") }
  /// Decline
  public static var onboardingPrivacyDeclineLoggingButton: String { L10n.tr("Localizable", "onboarding_privacy_declineLoggingButton", fallback: "Decline") }
  /// Data protection and security
  public static var onboardingPrivacyLinkText: String { L10n.tr("Localizable", "onboarding_privacy_link_text", fallback: "Data protection and security") }
  /// https://www.eid.admin.ch/en
  public static var onboardingPrivacyLinkValue: String { L10n.tr("Localizable", "onboarding_privacy_link_value", fallback: "https://www.eid.admin.ch/en") }
  /// Help us to improve
  public static var onboardingPrivacyPrimary: String { L10n.tr("Localizable", "onboarding_privacy_primary", fallback: "Help us to improve") }
  /// Allow anonymized usage data to be shared with our development team.
  public static var onboardingPrivacySecondary: String { L10n.tr("Localizable", "onboarding_privacy_secondary", fallback: "Allow anonymized usage data to be shared with our development team.") }
  /// To the app
  public static var onboardingReadyButtonText: String { L10n.tr("Localizable", "onboarding_ready_buttonText", fallback: "To the app") }
  /// Everything is ready
  public static var onboardingReadyPrimary: String { L10n.tr("Localizable", "onboarding_ready_primary", fallback: "Everything is ready") }
  /// The app is ready. You can get more tips on how to use it or read them later in the help section.
  public static var onboardingReadySecondary: String { L10n.tr("Localizable", "onboarding_ready_secondary", fallback: "The app is ready. You can get more tips on how to use it or read them later in the help section.") }
  /// The Swiss Confederation has no access to your data.
  public static var onboardingSecurityDetails: String { L10n.tr("Localizable", "onboarding_security_details", fallback: "The Swiss Confederation has no access to your data.") }
  /// Your data - with you
  public static var onboardingSecurityPrimary: String { L10n.tr("Localizable", "onboarding_security_primary", fallback: "Your data - with you") }
  /// Your credentials are stored exclusively on your device. Only you have access to them.
  public static var onboardingSecuritySecondary: String { L10n.tr("Localizable", "onboarding_security_secondary", fallback: "Your credentials are stored exclusively on your device. Only you have access to them.") }
  /// The verification was canceled and no data was transferred.
  public static var presentationDeclinedMessage: String { L10n.tr("Localizable", "presentation_declined_message", fallback: "The verification was canceled and no data was transferred.") }
  /// Verification was canceled
  public static var presentationDeclinedTitle: String { L10n.tr("Localizable", "presentation_declined_title", fallback: "Verification was canceled") }
  /// Please select the correct credential below and click on it.
  public static var presentationSelectCredentialSubtitle: String { L10n.tr("Localizable", "presentation_select_credential_subtitle", fallback: "Please select the correct credential below and click on it.") }
  /// Which credential must be presented?
  public static var presentationSelectCredentialTitle: String { L10n.tr("Localizable", "presentation_select_credential_title", fallback: "Which credential must be presented?") }
  /// Analysis & Improvements
  public static var securitySettingsAnalysisTitle: String { L10n.tr("Localizable", "securitySettings_analysisTitle", fallback: "Analysis & Improvements") }
  /// Biometrics
  public static var securitySettingsBiometrics: String { L10n.tr("Localizable", "securitySettings_biometrics", fallback: "Biometrics") }
  /// Change password
  public static var securitySettingsChangePin: String { L10n.tr("Localizable", "securitySettings_changePin", fallback: "Change password") }
  /// More information
  public static var securitySettingsDataAnalysis: String { L10n.tr("Localizable", "securitySettings_dataAnalysis", fallback: "More information") }
  /// Privacy statement
  public static var securitySettingsDataProtection: String { L10n.tr("Localizable", "securitySettings_dataProtection", fallback: "Privacy statement") }
  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var securitySettingsDataProtectionLink: String { L10n.tr("Localizable", "securitySettings_dataProtectionLink", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e") }
  /// Login & Security
  public static var securitySettingsLoginTitle: String { L10n.tr("Localizable", "securitySettings_loginTitle", fallback: "Login & Security") }
  /// Share anonymised error reports
  public static var securitySettingsShareAnalysis: String { L10n.tr("Localizable", "securitySettings_shareAnalysis", fallback: "Share anonymised error reports") }
  /// Help improve the swiyu app by anonymously sharing error reports and crashes – making it even better.
  public static var securitySettingsShareAnalysisText: String { L10n.tr("Localizable", "securitySettings_shareAnalysis_text", fallback: "Help improve the swiyu app by anonymously sharing error reports and crashes – making it even better.") }
  /// Data protection and security
  public static var securitySettingsTitle: String { L10n.tr("Localizable", "securitySettings_title", fallback: "Data protection and security") }
  /// Contact
  public static var settingsContact: String { L10n.tr("Localizable", "settings_contact", fallback: "Contact") }
  /// https://forms.eid.admin.ch
  public static var settingsContactLink: String { L10n.tr("Localizable", "settings_contactLink", fallback: "https://forms.eid.admin.ch") }
  /// Help
  public static var settingsHelp: String { L10n.tr("Localizable", "settings_help", fallback: "Help") }
  /// https://www.eid.admin.ch/en/help-publicbeta-e
  public static var settingsHelpLink: String { L10n.tr("Localizable", "settings_helpLink", fallback: "https://www.eid.admin.ch/en/help-publicbeta-e") }
  /// Publication details
  public static var settingsImpressum: String { L10n.tr("Localizable", "settings_impressum", fallback: "Publication details") }
  /// Language
  public static var settingsLanguage: String { L10n.tr("Localizable", "settings_language", fallback: "Language") }
  /// Licences
  public static var settingsLicences: String { L10n.tr("Localizable", "settings_licences", fallback: "Licences") }
  /// Data protection and security
  public static var settingsSecurity: String { L10n.tr("Localizable", "settings_security", fallback: "Data protection and security") }
  /// Settings
  public static var settingsTitle: String { L10n.tr("Localizable", "settings_title", fallback: "Settings") }
  /// Your settings will be applied, which can take up to 30 seconds.
  public static var storageSetupText: String { L10n.tr("Localizable", "storageSetup_text", fallback: "Your settings will be applied, which can take up to 30 seconds.") }
  /// Applying settings
  public static var storageSetupTitle: String { L10n.tr("Localizable", "storageSetup_title", fallback: "Applying settings") }
  /// Current password
  public static var tkChangepasswordError1Note1: String { L10n.tr("Localizable", "tk_changepassword_error1_note1", fallback: "Current password") }
  /// Maximum length of 64 characters reached
  public static var tkChangepasswordError2Note2: String { L10n.tr("Localizable", "tk_changepassword_error2_note2", fallback: "Maximum length of 64 characters reached") }
  /// Confirm new password
  public static var tkChangepasswordError3Note1: String { L10n.tr("Localizable", "tk_changepassword_error3_note1", fallback: "Confirm new password") }
  /// The passwords do not match. Please try again.
  public static var tkChangepasswordError3Note2: String { L10n.tr("Localizable", "tk_changepassword_error3_note2", fallback: "The passwords do not match. Please try again.") }
  /// Incorrect password entered too many times. Please set a new password.
  public static var tkChangepasswordError4Notification: String { L10n.tr("Localizable", "tk_changepassword_error4_notification", fallback: "Incorrect password entered too many times. Please set a new password.\t") }
  /// Enter current password
  public static var tkChangepasswordStep1CurrentpasswordAlt: String { L10n.tr("Localizable", "tk_changepassword_step1_currentpassword_alt", fallback: "Enter current password") }
  /// Current password
  public static var tkChangepasswordStep1Note1: String { L10n.tr("Localizable", "tk_changepassword_step1_note1", fallback: "Current password") }
  /// Password
  public static var tkChangepasswordStep1Note2: String { L10n.tr("Localizable", "tk_changepassword_step1_note2", fallback: "Password") }
  /// At least 6 characters
  public static var tkChangepasswordStep2Note2: String { L10n.tr("Localizable", "tk_changepassword_step2_note2", fallback: "At least 6 characters") }
  /// Enter new password with at least six characters
  public static var tkChangepasswordStep2PasswordlengthAlt: String { L10n.tr("Localizable", "tk_changepassword_step2_passwordlength_alt", fallback: "Enter new password with at least six characters") }
  /// Confirm new password
  public static var tkChangepasswordStep3Note1: String { L10n.tr("Localizable", "tk_changepassword_step3_note1", fallback: "Confirm new password") }
  /// Password successfully changed
  public static var tkChangepasswordSuccessfulNotification: String { L10n.tr("Localizable", "tk_changepassword_successful_notification", fallback: "Password successfully changed") }
  /// Credential
  public static var tkCredentialFallbackTitle: String { L10n.tr("Localizable", "tk_credential_fallback_title", fallback: "Credential") }
  /// Demo
  public static var tkCredentialStatusDemo: String { L10n.tr("Localizable", "tk_credential_status_demo", fallback: "Demo") }
  /// Credential demo
  public static var tkCredentialStatusDemoAlt: String { L10n.tr("Localizable", "tk_credential_status_demo_alt", fallback: "Credential demo") }
  /// Expired
  public static var tkCredentialStatusInvalid: String { L10n.tr("Localizable", "tk_credential_status_invalid", fallback: "Expired") }
  /// Credential expired
  public static var tkCredentialStatusInvalidAlt: String { L10n.tr("Localizable", "tk_credential_status_invalid_alt", fallback: "Credential expired") }
  /// Revoked
  public static var tkCredentialStatusRevoked: String { L10n.tr("Localizable", "tk_credential_status_revoked", fallback: "Revoked") }
  /// Credential revoked
  public static var tkCredentialStatusRevokedAlt: String { L10n.tr("Localizable", "tk_credential_status_revoked_alt", fallback: "Credential revoked") }
  /// Valid soon
  public static var tkCredentialStatusSoon: String { L10n.tr("Localizable", "tk_credential_status_soon", fallback: "Valid soon") }
  /// Credential available soon
  public static var tkCredentialStatusSoonAlt: String { L10n.tr("Localizable", "tk_credential_status_soon_alt", fallback: "Credential available soon") }
  /// Currently locked
  public static var tkCredentialStatusSuspended: String { L10n.tr("Localizable", "tk_credential_status_suspended", fallback: "Currently locked") }
  /// Credential temporarily locked.
  public static var tkCredentialStatusSuspendedAlt: String { L10n.tr("Localizable", "tk_credential_status_suspended_alt", fallback: "Credential temporarily locked.") }
  /// Unknown
  public static var tkCredentialStatusUnknown: String { L10n.tr("Localizable", "tk_credential_status_unknown", fallback: "Unknown") }
  /// Validity status unknown
  public static var tkCredentialStatusUnknownAlt: String { L10n.tr("Localizable", "tk_credential_status_unknown_alt", fallback: "Validity status unknown") }
  /// Valid
  public static var tkCredentialStatusValid: String { L10n.tr("Localizable", "tk_credential_status_valid", fallback: "Valid") }
  /// Credential valid
  public static var tkCredentialStatusValidAlt: String { L10n.tr("Localizable", "tk_credential_status_valid_alt", fallback: "Credential valid") }
  /// This credential, along with all associated data, will be completely deleted from this device.
  public static var tkDisplaydeleteCredentialdeleteBody: String { L10n.tr("Localizable", "tk_displaydelete_credentialdelete_body", fallback: "This credential, along with all associated data, will be completely deleted from this device.") }
  /// Delete credential?
  public static var tkDisplaydeleteCredentialdeleteTitle: String { L10n.tr("Localizable", "tk_displaydelete_credentialdelete_title", fallback: "Delete credential?") }
  /// Delete credential
  public static var tkDisplaydeleteCredentialmenuPrimarybutton: String { L10n.tr("Localizable", "tk_displaydelete_credentialmenu_primarybutton", fallback: "Delete credential") }
  /// Back to top
  public static var tkDisplaydeleteDisplaycredential1Hiddenlink1Text: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_hiddenlink1_text", fallback: "Back to top") }
  /// Go to personal details
  public static var tkDisplaydeleteDisplaycredential1Hiddenlink2Text: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_hiddenlink2_text", fallback: "Go to personal details") }
  /// Entire history
  public static var tkDisplaydeleteDisplaycredential1Smallbody: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_smallbody", fallback: "Entire history") }
  /// History
  public static var tkDisplaydeleteDisplaycredential1Title1: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title1", fallback: "History") }
  /// Details
  public static var tkDisplaydeleteDisplaycredential1Title2: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title2", fallback: "Details") }
  /// Additions
  public static var tkDisplaydeleteDisplaycredential1Title3: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title3", fallback: "Additions") }
  /// Validity
  public static var tkDisplaydeleteDisplaycredential1Title4: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title4", fallback: "Validity") }
  /// Issued by
  public static var tkDisplaydeleteDisplaycredential1Title5: String { L10n.tr("Localizable", "tk_displaydelete_displaycredential1_title5", fallback: "Issued by") }
  /// Once issued, a credential cannot be changed.
  ///
  /// If you notice an error in your data, please contact the issuer.
  /// They can issue a new, corrected credential.
  public static var tkDisplaydeleteWrongdataBody: String { L10n.tr("Localizable", "tk_displaydelete_wrongdata_body", fallback: "Once issued, a credential cannot be changed.\n\nIf you notice an error in your data, please contact the issuer.\nThey can issue a new, corrected credential.") }
  /// Found any incorrect data?
  public static var tkDisplaydeleteWrongdataNavigationTitle: String { L10n.tr("Localizable", "tk_displaydelete_wrongdata_navigation_title", fallback: "Found any incorrect data?") }
  /// Report incorrect details
  public static var tkDisplaydeleteWrongdataTitle: String { L10n.tr("Localizable", "tk_displaydelete_wrongdata_title", fallback: "Report incorrect details") }
  /// Continue (deepl)
  public static var tkEidRequestAttestationButtonPrimary: String { L10n.tr("Localizable", "tk_eidRequest_attestation_button_primary", fallback: "Continue (deepl)") }
  /// One moment - Verifying compatibility (deepl)
  public static var tkEidRequestAttestationPrimary: String { L10n.tr("Localizable", "tk_eidRequest_attestation_primary", fallback: "One moment - Verifying compatibility (deepl)") }
  /// We’re checking if your device meets the safety and performance requirements. (deepl)
  public static var tkEidRequestAttestationSecondary: String { L10n.tr("Localizable", "tk_eidRequest_attestation_secondary", fallback: "We’re checking if your device meets the safety and performance requirements. (deepl)") }
  /// Etwas ist schiefgelaufen.
  public static var tkEidRequestAttestationUnknownErrorPrimary: String { L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_primary", fallback: "Etwas ist schiefgelaufen.") }
  /// Wiederholen
  public static var tkEidRequestAttestationUnknownErrorPrimaryButton: String { L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_primary_button", fallback: "Wiederholen") }
  /// Bitte versuchen Sie es erneut.
  public static var tkEidRequestAttestationUnknownErrorSecondary: String { L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_secondary", fallback: "Bitte versuchen Sie es erneut.") }
  /// Abbrechen
  public static var tkEidRequestAttestationUnknownErrorSecondaryButton: String { L10n.tr("Localizable", "tk_eidRequest_attestationUnknownError_secondary_button", fallback: "Abbrechen") }
  /// Start
  public static var tkEidRequestAutoVerificationIdentityCheckButton: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_button", fallback: "Start") }
  /// Verification of your identity
  public static var tkEidRequestAutoVerificationIdentityCheckPrimary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_primary", fallback: "Verification of your identity") }
  /// Please have your ID ready. A short video of your face and the ID will be recorded.
  public static var tkEidRequestAutoVerificationIdentityCheckSecondary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_secondary", fallback: "Please have your ID ready. A short video of your face and the ID will be recorded.") }
  /// Please do not cancel the process, otherwise all the information will be lost.
  public static var tkEidRequestAutoVerificationIdentityCheckTertiary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_tertiary", fallback: "Please do not cancel the process, otherwise all the information will be lost.") }
  /// Tip
  public static var tkEidRequestAutoVerificationIdentityCheckTertiaryTip: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationIdentityCheck_tertiary_tip", fallback: "Tip") }
  /// Confirm your identity – Record a short video
  public static var tkEidRequestAutoVerificationIntroSelfieVideoPrimary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationIntroSelfieVideo_primary", fallback: "Confirm your identity – Record a short video") }
  /// A short video of your face helps confirm your identity. When you are ready, press 'Record' and look into the camera. Make sure your face is well lit and clearly visible.
  public static var tkEidRequestAutoVerificationIntroSelfieVideoSecondary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationIntroSelfieVideo_secondary", fallback: "A short video of your face helps confirm your identity. When you are ready, press 'Record' and look into the camera. Make sure your face is well lit and clearly visible.") }
  /// Start
  public static var tkEidRequestAutoVerificationWelcomeButton: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_button", fallback: "Start") }
  /// Welcome back – Final verification of your e-ID
  public static var tkEidRequestAutoVerificationWelcomePrimary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_primary", fallback: "Welcome back – Final verification of your e-ID") }
  /// The next steps is to make sure that you really are the person who has the ID. Therefore, have your ID ready. We will make a video recording of it and a selfie from you.
  public static var tkEidRequestAutoVerificationWelcomeSecondary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_secondary", fallback: "The next steps is to make sure that you really are the person who has the ID. Therefore, have your ID ready. We will make a video recording of it and a selfie from you.") }
  /// Please take a few minutes and do not cancel the process, otherwise all the information will be lost.
  public static var tkEidRequestAutoVerificationWelcomeTertiary: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_tertiary", fallback: "Please take a few minutes and do not cancel the process, otherwise all the information will be lost.") }
  /// Tip
  public static var tkEidRequestAutoVerificationWelcomeTertiaryTip: String { L10n.tr("Localizable", "tk_eidRequest_autoVerificationWelcome_tertiary_tip", fallback: "Tip") }
  /// Apple attestation service error
  public static var tkEidRequestClientAttestationDeviceCheckErrorBody: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_error_body", fallback: "Apple attestation service error") }
  /// Something went wrong with Apple attestations service
  public static var tkEidRequestClientAttestationDeviceCheckErrorTitle: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_error_title", fallback: "Something went wrong with Apple attestations service") }
  /// Timeout from apple service. try again later.
  public static var tkEidRequestClientAttestationDeviceCheckTimeoutBody: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_timeout_body", fallback: "Timeout from apple service. try again later.") }
  /// the Apple attestations service can't be reached
  public static var tkEidRequestClientAttestationDeviceCheckTimeoutTitle: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_deviceCheck_timeout_title", fallback: "the Apple attestations service can't be reached") }
  /// Storage level error
  public static var tkEidRequestClientAttestationNotSupportedBody: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_notSupported_body", fallback: "Storage level error") }
  /// Storage level not sufficient
  public static var tkEidRequestClientAttestationNotSupportedTitle: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_notSupported_title", fallback: "Storage level not sufficient") }
  /// e-ID request preparation error
  public static var tkEidRequestClientAttestationServiceErrorBody: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_service_error_body", fallback: "e-ID request preparation error") }
  /// Something went wrong in the preparation of the e-ID request
  public static var tkEidRequestClientAttestationServiceErrorTitle: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestation_service_error_title", fallback: "Something went wrong in the preparation of the e-ID request") }
  /// https://www.eid.admin.ch/
  public static var tkEidRequestClientAttestationErrorHelpLink: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_help_link", fallback: "https://www.eid.admin.ch/") }
  /// Diese Wallet-App wird nicht unterstützt
  public static var tkEidRequestClientAttestationErrorPrimary: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_primary", fallback: "Diese Wallet-App wird nicht unterstützt") }
  /// swiyu App herunterladen
  public static var tkEidRequestClientAttestationErrorPrimaryButton: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_primary_button", fallback: "swiyu App herunterladen") }
  /// Bitte verwenden Sie die offizielle swiyu App oder eine andere Wallet-App, die kompatibel ist.
  public static var tkEidRequestClientAttestationErrorSecondary: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_secondary", fallback: "Bitte verwenden Sie die offizielle swiyu App oder eine andere Wallet-App, die kompatibel ist.") }
  /// Schliessen
  public static var tkEidRequestClientAttestationErrorSecondaryButton: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_secondary_button", fallback: "Schliessen") }
  /// Hilfe & FAQ
  public static var tkEidRequestClientAttestationErrorTertiary: String { L10n.tr("Localizable", "tk_eidRequest_clientAttestationError_tertiary", fallback: "Hilfe & FAQ") }
  /// Swiss ID Card
  public static var tkEidRequestDocumentSelectionIdCard: String { L10n.tr("Localizable", "tk_eidRequest_documentSelection_idCard", fallback: "Swiss ID Card") }
  /// Swiss Passport
  public static var tkEidRequestDocumentSelectionPassport: String { L10n.tr("Localizable", "tk_eidRequest_documentSelection_passport", fallback: "Swiss Passport") }
  /// Choose your document
  public static var tkEidRequestDocumentSelectionPrimary: String { L10n.tr("Localizable", "tk_eidRequest_documentSelection_primary", fallback: "Choose your document") }
  /// Swiss Resident Permit
  public static var tkEidRequestDocumentSelectionResidentPermit: String { L10n.tr("Localizable", "tk_eidRequest_documentSelection_residentPermit", fallback: "Swiss Resident Permit") }
  /// Select one of the listed documents to proof your eligibility. Only original and valid documents will be accepted.
  public static var tkEidRequestDocumentSelectionSecondary: String { L10n.tr("Localizable", "tk_eidRequest_documentSelection_secondary", fallback: "Select one of the listed documents to proof your eligibility. Only original and valid documents will be accepted.") }
  /// https://www.eid.admin.ch/
  public static var tkEidRequestKeyAttestationErrorHelpLink: String { L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_help_link", fallback: "https://www.eid.admin.ch/") }
  /// Dieses Gerät wird leider nicht unterstützt
  public static var tkEidRequestKeyAttestationErrorPrimary: String { L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_primary", fallback: "Dieses Gerät wird leider nicht unterstützt") }
  /// Schliessen
  public static var tkEidRequestKeyAttestationErrorPrimaryButton: String { L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_primary_button", fallback: "Schliessen") }
  /// Zur Sicherheit müssen bestimmte technische Voraussetzungen erfüllt sein. Mit diesem Gerät ist das leider nicht möglich.
  public static var tkEidRequestKeyAttestationErrorSecondary: String { L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_secondary", fallback: "Zur Sicherheit müssen bestimmte technische Voraussetzungen erfüllt sein. Mit diesem Gerät ist das leider nicht möglich.") }
  /// Hilfe & FAQ
  public static var tkEidRequestKeyAttestationErrorTertiary: String { L10n.tr("Localizable", "tk_eidRequest_keyAttestationError_tertiary", fallback: "Hilfe & FAQ") }
  /// Scan the front side of your document
  public static var tkEidRequestMrzScannerNotificationRectoPrimary: String { L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_recto_primary", fallback: "Scan the front side of your document") }
  /// Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.
  public static var tkEidRequestMrzScannerNotificationRectoSecondary: String { L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_recto_secondary", fallback: "Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.") }
  /// Scan the back side of your document
  public static var tkEidRequestMrzScannerNotificationVersoPrimary: String { L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_verso_primary", fallback: "Scan the back side of your document") }
  /// Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.
  public static var tkEidRequestMrzScannerNotificationVersoSecondary: String { L10n.tr("Localizable", "tk_eidRequest_mrzScanner_notification_verso_secondary", fallback: "Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.") }
  /// Recto
  public static var tkEidRequestMrzScannerRecto: String { L10n.tr("Localizable", "tk_eidRequest_mrzScanner_recto", fallback: "Recto") }
  /// Verso
  public static var tkEidRequestMrzScannerVerso: String { L10n.tr("Localizable", "tk_eidRequest_mrzScanner_verso", fallback: "Verso") }
  /// Scan the front side of your document
  public static var tkEidRequestRecordDocumentNotificationRectoPrimary: String { L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_recto_primary", fallback: "Scan the front side of your document") }
  /// Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.
  public static var tkEidRequestRecordDocumentNotificationRectoSecondary: String { L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_recto_secondary", fallback: "Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.") }
  /// Scan the back side of your document
  public static var tkEidRequestRecordDocumentNotificationVersoPrimary: String { L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_verso_primary", fallback: "Scan the back side of your document") }
  /// Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.
  public static var tkEidRequestRecordDocumentNotificationVersoSecondary: String { L10n.tr("Localizable", "tk_eidRequest_recordDocument_notification_verso_secondary", fallback: "Place your document on a flat surface and position the front side in the frame. Make sure you have enough light.") }
  /// Recto
  public static var tkEidRequestRecordDocumentRecto: String { L10n.tr("Localizable", "tk_eidRequest_recordDocument_recto", fallback: "Recto") }
  /// Verso
  public static var tkEidRequestRecordDocumentVerso: String { L10n.tr("Localizable", "tk_eidRequest_recordDocument_verso", fallback: "Verso") }
  /// Record your selfie
  public static var tkEidRequestRecordSelfieNotificationPrimary: String { L10n.tr("Localizable", "tk_eidRequest_recordSelfie_notification_primary", fallback: "Record your selfie") }
  /// Position your face within the frame. Stand in front of a neutral background where there is sufficient light.
  public static var tkEidRequestRecordSelfieNotificationSecondary: String { L10n.tr("Localizable", "tk_eidRequest_recordSelfie_notification_secondary", fallback: "Position your face within the frame. Stand in front of a neutral background where there is sufficient light.") }
  /// Record Selfie
  public static var tkEidRequestRecordSelfieTitle: String { L10n.tr("Localizable", "tk_eidRequest_recordSelfie_title", fallback: "Record Selfie") }
  /// Initializing Environment...
  public static var tkEidRequestSdkInitializationPrimary: String { L10n.tr("Localizable", "tk_eidRequest_sdk_initialization_primary", fallback: "Initializing Environment...") }
  /// Please try again.
  public static var tkErrorConnectionproblemBody: String { L10n.tr("Localizable", "tk_error_connectionproblem_body", fallback: "Please try again.") }
  /// Connection problems
  public static var tkErrorConnectionproblemTitle: String { L10n.tr("Localizable", "tk_error_connectionproblem_title", fallback: "Connection problems") }
  /// Your swiyu app does not contain any credentials.
  public static var tkErrorEmptywalletBody: String { L10n.tr("Localizable", "tk_error_emptywallet_body", fallback: "Your swiyu app does not contain any credentials.") }
  /// Empty swiyu app
  public static var tkErrorEmptywalletTitle: String { L10n.tr("Localizable", "tk_error_emptywallet_title", fallback: "Empty swiyu app") }
  /// This QR code cannot be used.
  public static var tkErrorInvalidqrcodeBody: String { L10n.tr("Localizable", "tk_error_invalidqrcode_body", fallback: "This QR code cannot be used.") }
  /// Invalid QR code
  public static var tkErrorInvalidqrcodeTitle: String { L10n.tr("Localizable", "tk_error_invalidqrcode_title", fallback: "Invalid QR code") }
  /// This check cannot be perfomed.
  public static var tkErrorInvalidrequestBody: String { L10n.tr("Localizable", "tk_error_invalidrequest_body", fallback: "This check cannot be perfomed.") }
  /// Invalid check
  public static var tkErrorInvalidrequestTitle: String { L10n.tr("Localizable", "tk_error_invalidrequest_title", fallback: "Invalid check") }
  /// This credential cannot be added to the swiyu app.
  public static var tkErrorInvitationcredentialBody: String { L10n.tr("Localizable", "tk_error_invitationcredential_body", fallback: "This credential cannot be added to the swiyu app.") }
  /// Invalid credential
  public static var tkErrorInvitationcredentialTitle: String { L10n.tr("Localizable", "tk_error_invitationcredential_title", fallback: "Invalid credential") }
  /// Your swiyu app does not contain any matching credential.
  public static var tkErrorNosuchcredentialBody: String { L10n.tr("Localizable", "tk_error_nosuchcredential_body", fallback: "Your swiyu app does not contain any matching credential.") }
  /// No matching credential available
  public static var tkErrorNosuchcredentialTitle: String { L10n.tr("Localizable", "tk_error_nosuchcredential_title", fallback: "No matching credential available") }
  /// This issuer is not registered.
  public static var tkErrorNotregisteredBody: String { L10n.tr("Localizable", "tk_error_notregistered_body", fallback: "This issuer is not registered.") }
  /// Unknown issuer
  public static var tkErrorNotregisteredTitle: String { L10n.tr("Localizable", "tk_error_notregistered_title", fallback: "Unknown issuer") }
  /// This QR code is no longer valid, please create a new one.
  public static var tkErrorNotusableBody: String { L10n.tr("Localizable", "tk_error_notusable_body", fallback: "This QR code is no longer valid, please create a new one.") }
  /// QR code no longer valid
  public static var tkErrorNotusableTitle: String { L10n.tr("Localizable", "tk_error_notusable_title", fallback: "QR code no longer valid") }
  /// Beta-ID was added
  public static var tkGetBetaIdAddedNote: String { L10n.tr("Localizable", "tk_getBetaId_added_note", fallback: "Beta-ID was added") }
  /// Would like to issue the following credential:
  public static var tkGetBetaIdApprovalTitle: String { L10n.tr("Localizable", "tk_getBetaId_approval_title", fallback: "Would like to issue the following credential:") }
  /// Via the following link, you will be redirected to an external website where you can create Beta-IDs.
  ///
  /// Afterwards, you can import them and test the swiyu app with them.
  public static var tkGetBetaIdCreateBody: String { L10n.tr("Localizable", "tk_getBetaId_create_body", fallback: "Via the following link, you will be redirected to an external website where you can create Beta-IDs.\n\nAfterwards, you can import them and test the swiyu app with them.") }
  /// Create Beta-ID
  public static var tkGetBetaIdCreateTitle: String { L10n.tr("Localizable", "tk_getBetaId_create_title", fallback: "Create Beta-ID") }
  /// Please try again.
  public static var tkGetBetaIdErrorBody: String { L10n.tr("Localizable", "tk_getBetaId_error_body", fallback: "Please try again.") }
  /// Error code: VXA - 1009
  public static var tkGetBetaIdErrorSmallbody: String { L10n.tr("Localizable", "tk_getBetaId_error_smallbody", fallback: "Error code: VXA - 1009") }
  /// Oops, something went wrong!
  public static var tkGetBetaIdErrorTitle: String { L10n.tr("Localizable", "tk_getBetaId_error_title", fallback: "Oops, something went wrong!") }
  /// Your device does not support Strongbox.
  public static var tkGetBetaIdErrorStrongboxBody: String { L10n.tr("Localizable", "tk_getBetaId_errorStrongbox_body", fallback: "Your device does not support Strongbox.") }
  /// Error code: XYZ - 12345
  public static var tkGetBetaIdErrorStrongboxSmallbody: String { L10n.tr("Localizable", "tk_getBetaId_errorStrongbox_smallbody", fallback: "Error code: XYZ - 12345") }
  /// Strongbox error
  public static var tkGetBetaIdErrorStrongboxTitle: String { L10n.tr("Localizable", "tk_getBetaId_errorStrongbox_title", fallback: "Strongbox error") }
  /// Add a Beta-ID to test the swiyu app.
  public static var tkGetBetaIdFirstUseBody: String { L10n.tr("Localizable", "tk_getBetaId_firstUse_body", fallback: "Add a Beta-ID to test the swiyu app.") }
  /// Wallet empty
  public static var tkGetBetaIdFirstUseTitle: String { L10n.tr("Localizable", "tk_getBetaId_firstUse_title", fallback: "Wallet empty") }
  /// The validity of your identity document is checked first. To do this, allow access to the camera for the scanning process.
  /// Which identity documents can be used?
  /// Swiss passport
  /// Swiss ID card
  /// Swiss foreign national identity card
  ///
  public static var tkGetEidCheckIdBody: String { L10n.tr("Localizable", "tk_getEid_checkId_body", fallback: "The validity of your identity document is checked first. To do this, allow access to the camera for the scanning process.\nWhich identity documents can be used?\nSwiss passport\nSwiss ID card\nSwiss foreign national identity card\n") }
  /// Identity document check
  public static var tkGetEidCheckIdTitle: String { L10n.tr("Localizable", "tk_getEid_checkId_title", fallback: "Identity document check") }
  /// Your request is in the queue.
  public static var tkGetEidConsentOkAvQueuePrimary: String { L10n.tr("Localizable", "tk_getEid_consentOk_avQueue_primary", fallback: "Your request is in the queue.") }
  /// Your electronic identity is currently in the queue.
  ///
  /// As soon as it’s your turn, you will receive a notification via the app.
  public static var tkGetEidConsentOkAvQueueSecondary: String { L10n.tr("Localizable", "tk_getEid_consentOk_avQueue_secondary", fallback: "Your electronic identity is currently in the queue.\n\nAs soon as it’s your turn, you will receive a notification via the app.") }
  /// We attach great importance to the protection of your data and your privacy. To create an e-ID, we require your consent to the data protection declaration.
  public static var tkGetEidDataPrivacyBody: String { L10n.tr("Localizable", "tk_getEid_dataPrivacy_body", fallback: "We attach great importance to the protection of your data and your privacy. To create an e-ID, we require your consent to the data protection declaration.") }
  /// Privacy Statement
  public static var tkGetEidDataPrivacyLinkText: String { L10n.tr("Localizable", "tk_getEid_dataPrivacy_link_text", fallback: "Privacy Statement") }
  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var tkGetEidDataPrivacyLinkValue: String { L10n.tr("Localizable", "tk_getEid_dataPrivacy_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e") }
  /// Agree and continue
  public static var tkGetEidDataPrivacyPrimaryButton: String { L10n.tr("Localizable", "tk_getEid_dataPrivacy_primaryButton", fallback: "Agree and continue") }
  /// Privacy Statement
  public static var tkGetEidDataPrivacyTitle: String { L10n.tr("Localizable", "tk_getEid_dataPrivacy_title", fallback: "Privacy Statement") }
  /// Please scan the identity document again or choose another one.
  public static var tkGetEidGeneralErrorBody: String { L10n.tr("Localizable", "tk_getEid_generalError_body", fallback: "Please scan the identity document again or choose another one.") }
  /// An error has occurred
  public static var tkGetEidGeneralErrorTitle: String { L10n.tr("Localizable", "tk_getEid_generalError_title", fallback: "An error has occurred") }
  /// Finish
  public static var tkGetEidGuardianConsentButtonFinish: String { L10n.tr("Localizable", "tk_getEid_guardianConsent_button_finish", fallback: "Finish") }
  /// Share QR-Code
  public static var tkGetEidGuardianConsentButtonShare: String { L10n.tr("Localizable", "tk_getEid_guardianConsent_button_share", fallback: "Share QR-Code") }
  /// Scan QR Code
  public static var tkGetEidGuardianConsentPrimary: String { L10n.tr("Localizable", "tk_getEid_guardianConsent_primary", fallback: "Scan QR Code") }
  /// QR Code. Elternteil oder Beistand diesen Code scannen lassen oder teilen (deepl)
  public static var tkGetEidGuardianConsentQrAlt: String { L10n.tr("Localizable", "tk_getEid_guardianConsent_qr_alt", fallback: "QR Code. Elternteil oder Beistand diesen Code scannen lassen oder teilen (deepl)") }
  /// Try again
  public static var tkGetEidGuardianConsentQrButtonRetry: String { L10n.tr("Localizable", "tk_getEid_guardianConsent_qr_button_retry", fallback: "Try again") }
  /// An error occurred while generating the QR code.
  public static var tkGetEidGuardianConsentQrError: String { L10n.tr("Localizable", "tk_getEid_guardianConsent_qr_error", fallback: "An error occurred while generating the QR code.") }
  /// Your parent or guardian must scan the QR code with their own swiyu app to give consent for you.
  public static var tkGetEidGuardianConsentSecondary: String { L10n.tr("Localizable", "tk_getEid_guardianConsent_secondary", fallback: "Your parent or guardian must scan the QR code with their own swiyu app to give consent for you.") }
  /// Continue as a parent/guardian
  public static var tkGetEidGuardianSelectionButtonContinueAsGuardian: String { L10n.tr("Localizable", "tk_getEid_guardianSelection_button_continueAsGuardian", fallback: "Continue as a parent/guardian") }
  /// Obtain consent
  public static var tkGetEidGuardianSelectionButtonObtainConsent: String { L10n.tr("Localizable", "tk_getEid_guardianSelection_button_obtainConsent", fallback: "Obtain consent") }
  /// We need the consent of the parents or guardian to create this ID.
  public static var tkGetEidGuardianSelectionPrimary: String { L10n.tr("Localizable", "tk_getEid_guardianSelection_primary", fallback: "We need the consent of the parents or guardian to create this ID.") }
  /// How would you like to proceed?
  public static var tkGetEidGuardianSelectionSecondary: String { L10n.tr("Localizable", "tk_getEid_guardianSelection_secondary", fallback: "How would you like to proceed?") }
  /// No
  public static var tkGetEidGuardianshipButtonNo: String { L10n.tr("Localizable", "tk_getEid_guardianship_button_no", fallback: "No") }
  /// Yes
  public static var tkGetEidGuardianshipButtonYes: String { L10n.tr("Localizable", "tk_getEid_guardianship_button_yes", fallback: "Yes") }
  /// Are you under comprehensive guardianship?
  public static var tkGetEidGuardianshipPrimary: String { L10n.tr("Localizable", "tk_getEid_guardianship_primary", fallback: "Are you under comprehensive guardianship?") }
  /// Comprehensive guardianship means that another person (not your parents) makes all important decisions for you.
  public static var tkGetEidGuardianshipSecondary: String { L10n.tr("Localizable", "tk_getEid_guardianship_secondary", fallback: "Comprehensive guardianship means that another person (not your parents) makes all important decisions for you.") }
  /// e-ID bestellen (deepl)
  public static var tkGetEidHomePrimaryButton: String { L10n.tr("Localizable", "tk_getEid_home_primaryButton", fallback: "e-ID bestellen (deepl)") }
  /// First your identity document will be checked. Then your identity will be verified.
  /// It takes about 5 minutes.
  public static var tkGetEidIntroBody: String { L10n.tr("Localizable", "tk_getEid_intro_body", fallback: "First your identity document will be checked. Then your identity will be verified.\nIt takes about 5 minutes.") }
  /// Order now
  public static var tkGetEidIntroPrimaryButton: String { L10n.tr("Localizable", "tk_getEid_intro_primaryButton", fallback: "Order now") }
  /// Later
  public static var tkGetEidIntroSecondaryButton: String { L10n.tr("Localizable", "tk_getEid_intro_secondaryButton", fallback: "Later") }
  /// Exceptions
  /// Protecting your identity is our top priority. In rare cases, we may need to carry out an additional check to verify your identity. This can take several days more.
  ///
  public static var tkGetEidIntroSmallBody: String { L10n.tr("Localizable", "tk_getEid_intro_smallBody", fallback: "Exceptions\nProtecting your identity is our top priority. In rare cases, we may need to carry out an additional check to verify your identity. This can take several days more.\n") }
  /// How to order your e-ID
  public static var tkGetEidIntroTitle: String { L10n.tr("Localizable", "tk_getEid_intro_title", fallback: "How to order your e-ID") }
  /// Consent has been provided, you can start now with the verification process.
  public static var tkGetEidLegalRepresentantGivenConsentReadyForAVPrimary: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantGivenConsent_readyForAV_primary", fallback: "Consent has been provided, you can start now with the verification process.") }
  /// Please have a valid ID ready.
  public static var tkGetEidLegalRepresentantGivenConsentReadyForAVSecondary: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantGivenConsent_readyForAV_secondary", fallback: "Please have a valid ID ready.") }
  /// Order has expired.
  public static var tkGetEidLegalRepresentantPendingConsentExpiredPrimary: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_expired_primary", fallback: "Order has expired.") }
  /// Unfortunately, your ordering deadline has expired.
  ///
  /// Reason: Your legal representative did not approve the order.
  ///
  /// You can place a new order at any time.
  public static var tkGetEidLegalRepresentantPendingConsentExpiredSecondary: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_expired_secondary", fallback: "Unfortunately, your ordering deadline has expired.\n\nReason: Your legal representative did not approve the order.\n\nYou can place a new order at any time.") }
  /// Consent is missing, your e-ID is in the queue.
  public static var tkGetEidLegalRepresentantPendingConsentInQueuePrimary: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_inQueue_primary", fallback: "Consent is missing, your e-ID is in the queue.") }
  /// Your electronic identity is currently in the queue.
  ///
  /// As soon as it’s your turn, you will receive a notification via the app.
  ///
  /// Your parents’ or legal guardian’s consent is still missing.
  public static var tkGetEidLegalRepresentantPendingConsentInQueueSecondary: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_inQueue_secondary", fallback: "Your electronic identity is currently in the queue.\n\nAs soon as it’s your turn, you will receive a notification via the app.\n\nYour parents’ or legal guardian’s consent is still missing.") }
  /// Consent is pending.
  public static var tkGetEidLegalRepresentantPendingConsentReadyForAVPrimary: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_readyForAV_primary", fallback: "Consent is pending.") }
  /// Please verify your identity by
  public static var tkGetEidLegalRepresentantPendingConsentReadyForAVSecondaryPrefix: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_readyForAV_secondary_prefix", fallback: "Please verify your identity by ") }
  /// , otherwise your order will be canceled.
  ///
  /// Your parents’ or legal guardian’s consent is still missing. You need to obtain the consent first in order to proceed.
  public static var tkGetEidLegalRepresentantPendingConsentReadyForAVSecondarySuffix: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_readyForAV_secondary_suffix", fallback: ", otherwise your order will be canceled.\n\nYour parents’ or legal guardian’s consent is still missing. You need to obtain the consent first in order to proceed.") }
  /// Start
  public static var tkGetEidLegalRepresentantPendingConsentStartButton: String { L10n.tr("Localizable", "tk_getEid_legalRepresentantPendingConsent_start_button", fallback: "Start") }
  /// Close button
  public static var tkGetEidNotificationCloseButton: String { L10n.tr("Localizable", "tk_getEid_notification_close_button", fallback: "Close button") }
  /// You did not fully complete the ordering process. Please restart it to receive your e-ID.
  public static var tkGetEidNotificationEidExpiredSecondary: String { L10n.tr("Localizable", "tk_getEid_notification_eidExpired_secondary", fallback: "You did not fully complete the ordering process. Please restart it to receive your e-ID.") }
  /// Start identification
  public static var tkGetEidNotificationEidReadyGreenButton: String { L10n.tr("Localizable", "tk_getEid_notification_eidReady_greenButton", fallback: "Start identification") }
  /// Press to refresh
  public static var tkGetEidNotificationEidUnknownStateButton: String { L10n.tr("Localizable", "tk_getEid_notification_eidUnknownState_button:", fallback: "Press to refresh") }
  /// Unable to retrieve the status status of your e-ID order.
  public static var tkGetEidNotificationEidUnknownStateSecondary: String { L10n.tr("Localizable", "tk_getEid_notification_eidUnknownState_secondary", fallback: "Unable to retrieve the status status of your e-ID order.") }
  /// Obtain consent
  public static var tkGetEidNotificationLegalRepresentantPendingConsentInQueueButton: String { L10n.tr("Localizable", "tk_getEid_notification_legalRepresentantPendingConsent_inQueue_button", fallback: "Obtain consent") }
  /// Obtain consent
  public static var tkGetEidNotificationLegalRepresentantPendingConsentInQueuePrimary: String { L10n.tr("Localizable", "tk_getEid_notification_legalRepresentantPendingConsent_inQueue_primary", fallback: "Obtain consent") }
  /// Your electronic identity is currently in the queue. Your parents’ or legal guardian’s consent is still missing.
  public static var tkGetEidNotificationLegalRepresentantPendingConsentInQueueSecondary: String { L10n.tr("Localizable", "tk_getEid_notification_legalRepresentantPendingConsent_inQueue_secondary", fallback: "Your electronic identity is currently in the queue. Your parents’ or legal guardian’s consent is still missing.") }
  /// Obtain consent
  public static var tkGetEidNotificationLegalRepresentantPendingConsentReadyForAVButton: String { L10n.tr("Localizable", "tk_getEid_notification_legalRepresentantPendingConsent_readyForAV_button", fallback: "Obtain consent") }
  /// Obtain consent
  public static var tkGetEidNotificationLegalRepresentantPendingConsentReadyForAVPrimary: String { L10n.tr("Localizable", "tk_getEid_notification_legalRepresentantPendingConsent_readyForAV_primary", fallback: "Obtain consent") }
  /// We have received your request. Unfortunately, your order can't be processed immediately due to high demand.
  ///
  /// As soon as it is your turn, you will receive a message via the app.
  public static var tkGetEidQueuingBody: String { L10n.tr("Localizable", "tk_getEid_queuing_body", fallback: "We have received your request. Unfortunately, your order can't be processed immediately due to high demand. \n\nAs soon as it is your turn, you will receive a message via the app.") }
  /// Estimated time:
  public static var tkGetEidQueuingBody2Ios: String { L10n.tr("Localizable", "tk_getEid_queuing_body2_ios", fallback: "Estimated time:") }
  /// In Queue for Processing
  public static var tkGetEidQueuingTitle: String { L10n.tr("Localizable", "tk_getEid_queuing_title", fallback: "In Queue for Processing") }
  /// Please have your ID ready and point the camera at the area with the code line.
  /// Allow access to the camera so that the scan can be carried out. (deepl)
  public static var tkGetEidStartScanBody: String { L10n.tr("Localizable", "tk_getEid_startScan_body", fallback: "Please have your ID ready and point the camera at the area with the code line.\nAllow access to the camera so that the scan can be carried out. (deepl)") }
  /// Where can I find the number range? (deepl)
  public static var tkGetEidStartScanLinkText: String { L10n.tr("Localizable", "tk_getEid_startScan_linkText", fallback: "Where can I find the number range? (deepl)") }
  /// Scan number range (deepl)
  public static var tkGetEidStartScanTitle: String { L10n.tr("Localizable", "tk_getEid_startScan_title", fallback: "Scan number range (deepl)") }
  /// Get your devices and set up your e-ID on this or additional devices.
  ///
  /// You won't be able to add other devices once you continue.
  public static var tkGetEidWalletPairing1Body: String { L10n.tr("Localizable", "tk_getEid_walletPairing1_body", fallback: "Get your devices and set up your e-ID on this or additional devices.\n\nYou won't be able to add other devices once you continue.") }
  /// No, just this one
  public static var tkGetEidWalletPairing1PrimaryButton: String { L10n.tr("Localizable", "tk_getEid_walletPairing1_primaryButton", fallback: "No, just this one") }
  /// Yes, add other devices
  public static var tkGetEidWalletPairing1SecondaryButton: String { L10n.tr("Localizable", "tk_getEid_walletPairing1_secondaryButton", fallback: "Yes, add other devices") }
  /// Hinweis
  /// Aus Sicherheitsgründen können Sie dies nur jetzt festlegen. Nachträglich ist es nicht mehr möglich, Ihre e-ID auf weiteren Geräten zu speichern. (deepl)
  public static var tkGetEidWalletPairing1SmallBody: String { L10n.tr("Localizable", "tk_getEid_walletPairing1_smallBody", fallback: "Hinweis\nAus Sicherheitsgründen können Sie dies nur jetzt festlegen. Nachträglich ist es nicht mehr möglich, Ihre e-ID auf weiteren Geräten zu speichern. (deepl)") }
  /// Would you like to use your e-ID on multiple devices?
  public static var tkGetEidWalletPairing1Title: String { L10n.tr("Localizable", "tk_getEid_walletPairing1_title", fallback: "Would you like to use your e-ID on multiple devices?") }
  /// Add
  public static var tkGlobalAddPrimarybutton: String { L10n.tr("Localizable", "tk_global_add_primarybutton", fallback: "Add") }
  /// Allow
  public static var tkGlobalAllowPrimarybutton: String { L10n.tr("Localizable", "tk_global_allow_primarybutton", fallback: "Allow") }
  /// Back
  public static var tkGlobalBackAlt: String { L10n.tr("Localizable", "tk_global_back_alt", fallback: "Back") }
  /// https://www.bcs.admin.ch/bcs-web/?lang=EN
  public static var tkGlobalBetaidUrl: String { L10n.tr("Localizable", "tk_global_betaid_url", fallback: "https://www.bcs.admin.ch/bcs-web/?lang=EN") }
  /// Cancel
  public static var tkGlobalCancel: String { L10n.tr("Localizable", "tk_global_cancel", fallback: "Cancel") }
  /// Change password
  public static var tkGlobalChangepassword: String { L10n.tr("Localizable", "tk_global_changepassword", fallback: "Change password") }
  /// Would like to check your age
  public static var tkGlobalCheckage: String { L10n.tr("Localizable", "tk_global_checkage", fallback: "Would like to check your age") }
  /// Done
  public static var tkGlobalClose: String { L10n.tr("Localizable", "tk_global_close", fallback: "Done") }
  /// Close details
  public static var tkGlobalClosedetailsAlt: String { L10n.tr("Localizable", "tk_global_closedetails_alt", fallback: "Close details") }
  /// Close learner's licence
  public static var tkGlobalCloseelfaAlt: String { L10n.tr("Localizable", "tk_global_closeelfa_alt", fallback: "Close learner's licence") }
  /// Close warning
  public static var tkGlobalClosewarningAlt: String { L10n.tr("Localizable", "tk_global_closewarning_alt", fallback: "Close warning") }
  /// Next
  public static var tkGlobalContinue: String { L10n.tr("Localizable", "tk_global_continue", fallback: "Next") }
  /// Credential
  public static var tkGlobalCredential: String { L10n.tr("Localizable", "tk_global_credential", fallback: "Credential") }
  /// Delete
  public static var tkGlobalDelete: String { L10n.tr("Localizable", "tk_global_delete", fallback: "Delete") }
  /// Open details
  public static var tkGlobalDetailsAlt: String { L10n.tr("Localizable", "tk_global_details_alt", fallback: "Open details") }
  /// Create a password
  public static var tkGlobalEnterpassword: String { L10n.tr("Localizable", "tk_global_enterpassword", fallback: "Create a password") }
  /// https://www.bcs.admin.ch/bcs-web/?lang=EN
  public static var tkGlobalGetbetaidLinkValue: String { L10n.tr("Localizable", "tk_global_getbetaid_link_value", fallback: "https://www.bcs.admin.ch/bcs-web/?lang=EN") }
  /// Create Beta-ID
  public static var tkGlobalGetbetaidPrimarybutton: String { L10n.tr("Localizable", "tk_global_getbetaid_primarybutton", fallback: "Create Beta-ID") }
  /// Show password
  public static var tkGlobalInvisibleAlt: String { L10n.tr("Localizable", "tk_global_invisible_alt", fallback: "Show password") }
  /// Login
  public static var tkGlobalLoginPrimarybutton: String { L10n.tr("Localizable", "tk_global_login_primarybutton", fallback: "Login") }
  /// Log in with password
  public static var tkGlobalLoginpasswordSecondarybutton: String { L10n.tr("Localizable", "tk_global_loginpassword_secondarybutton", fallback: "Log in with password") }
  /// Logo
  public static var tkGlobalLogoAlt: String { L10n.tr("Localizable", "tk_global_logo_alt", fallback: "Logo") }
  /// More options
  public static var tkGlobalMoreoptionsAlt: String { L10n.tr("Localizable", "tk_global_moreoptions_alt", fallback: "More options") }
  /// ...
  public static var tkGlobalMoreoptionsSecondarybutton: String { L10n.tr("Localizable", "tk_global_moreoptions_secondarybutton", fallback: "...") }
  /// New password
  public static var tkGlobalNewpassword: String { L10n.tr("Localizable", "tk_global_newpassword", fallback: "New password") }
  /// No thanks
  public static var tkGlobalNo: String { L10n.tr("Localizable", "tk_global_no", fallback: "No thanks") }
  /// n/a (missing information)
  public static var tkGlobalNotAssigned: String { L10n.tr("Localizable", "tk_global_notAssigned", fallback: "n/a (missing information)") }
  /// Not verified
  public static var tkGlobalNotVerified: String { L10n.tr("Localizable", "tk_global_notVerified", fallback: "Not verified") }
  /// Please wait
  public static var tkGlobalPleasewait: String { L10n.tr("Localizable", "tk_global_pleasewait", fallback: "Please wait") }
  /// Scan
  public static var tkGlobalScanPrimarybutton: String { L10n.tr("Localizable", "tk_global_scan_primarybutton", fallback: "Scan") }
  /// Scan
  public static var tkGlobalScanPrimarybuttonAlt: String { L10n.tr("Localizable", "tk_global_scan_primarybutton_alt", fallback: "Scan") }
  /// Scan QR code
  public static var tkGlobalScanqrcode: String { L10n.tr("Localizable", "tk_global_scanqrcode", fallback: "Scan QR code") }
  /// Skip
  public static var tkGlobalSkip: String { L10n.tr("Localizable", "tk_global_skip", fallback: "Skip") }
  /// https://apps.apple.com/ch/app/swiyu/id6737259614
  public static var tkGlobalStoreLink: String { L10n.tr("Localizable", "tk_global_store_link", fallback: "https://apps.apple.com/ch/app/swiyu/id6737259614") }
  /// Go to settings
  public static var tkGlobalTothesettings: String { L10n.tr("Localizable", "tk_global_tothesettings", fallback: "Go to settings") }
  /// Verified
  public static var tkGlobalVerified: String { L10n.tr("Localizable", "tk_global_verified", fallback: "Verified") }
  /// Hide password
  public static var tkGlobalVisibleAlt: String { L10n.tr("Localizable", "tk_global_visible_alt", fallback: "Hide password") }
  /// Warning
  public static var tkGlobalWarningAlt: String { L10n.tr("Localizable", "tk_global_warning_alt", fallback: "Warning") }
  /// Welcome back
  public static var tkGlobalWelcomeback: String { L10n.tr("Localizable", "tk_global_welcomeback", fallback: "Welcome back") }
  /// Report incorrect details
  public static var tkGlobalWrongdata: String { L10n.tr("Localizable", "tk_global_wrongdata", fallback: "Report incorrect details") }
  /// To add IDs and documents, scan the QR code or open the link in the text message.
  public static var tkHomeEmpthyhomeBody: String { L10n.tr("Localizable", "tk_home_empthyhome_body", fallback: "To add IDs and documents, scan the QR code or open the link in the text message.") }
  /// Wallet empty
  public static var tkHomeEmpthyhomeTitle: String { L10n.tr("Localizable", "tk_home_empthyhome_title", fallback: "Wallet empty") }
  /// To add IDs and documents, scan the QR code or open the link in the text message.
  public static var tkHomeFirstuseBody: String { L10n.tr("Localizable", "tk_home_firstuse_body", fallback: "To add IDs and documents, scan the QR code or open the link in the text message.") }
  /// Wallet empty
  public static var tkHomeFirstuseTitle: String { L10n.tr("Localizable", "tk_home_firstuse_title", fallback: "Wallet empty") }
  /// swiyu app start screen
  public static var tkHomeHomescreenAlt: String { L10n.tr("Localizable", "tk_home_homescreen_alt", fallback: "swiyu app start screen") }
  /// Not verified
  public static var tkIssuerNotTrusted: String { L10n.tr("Localizable", "tk_issuer_notTrusted", fallback: "Not verified") }
  /// Verified
  public static var tkIssuerTrusted: String { L10n.tr("Localizable", "tk_issuer_trusted", fallback: "Verified") }
  /// Confirm swiyu app password
  public static var tkLoginConfirmPasswordAlt: String { L10n.tr("Localizable", "tk_login_confirmPassword_alt", fallback: "Confirm swiyu app password") }
  /// Retry
  public static var tkLoginFacenotrecognised1Body: String { L10n.tr("Localizable", "tk_login_facenotrecognised1_body", fallback: "Retry") }
  /// Cancel
  public static var tkLoginFacenotrecognised1Secondarybutton: String { L10n.tr("Localizable", "tk_login_facenotrecognised1_secondarybutton", fallback: "Cancel") }
  /// Face not recognised
  public static var tkLoginFacenotrecognised1Title: String { L10n.tr("Localizable", "tk_login_facenotrecognised1_title", fallback: "Face not recognised") }
  /// Enter password
  public static var tkLoginFacenotrecognised2Body: String { L10n.tr("Localizable", "tk_login_facenotrecognised2_body", fallback: "Enter password") }
  /// Enter password
  public static var tkLoginFacenotrecognised2Primarybutton: String { L10n.tr("Localizable", "tk_login_facenotrecognised2_primarybutton", fallback: "Enter password") }
  /// Please unlock the app to continue.
  public static var tkLoginFailedBody: String { L10n.tr("Localizable", "tk_login_failed_body", fallback: "Please unlock the app to continue.") }
  /// Login
  public static var tkLoginFailedTitle: String { L10n.tr("Localizable", "tk_login_failed_title", fallback: "Login") }
  /// More information
  public static var tkLoginForgottenpasswordAlt: String { L10n.tr("Localizable", "tk_login_forgottenpassword_alt", fallback: "More information") }
  /// Forgotten your password?
  public static var tkLoginLockedSecondarybuttonText: String { L10n.tr("Localizable", "tk_login_locked_secondarybutton_text", fallback: "Forgotten your password?") }
  /// https://www.eid.admin.ch/en/help-publicbeta-e
  public static var tkLoginLockedSecondarybuttonValue: String { L10n.tr("Localizable", "tk_login_locked_secondarybutton_value", fallback: "https://www.eid.admin.ch/en/help-publicbeta-e") }
  /// Sorry, the swiyu app is currently unavailable. Please try again later.
  public static var tkLoginLockedTitle: String { L10n.tr("Localizable", "tk_login_locked_title", fallback: "Sorry, the swiyu app is currently unavailable. Please try again later.") }
  /// Enter swiyu app password
  public static var tkLoginPasswordAlt: String { L10n.tr("Localizable", "tk_login_password_alt", fallback: "Enter swiyu app password") }
  /// Please enter your password:
  public static var tkLoginPasswordBody: String { L10n.tr("Localizable", "tk_login_password_body", fallback: "Please enter your password:") }
  /// Password
  public static var tkLoginPasswordNote: String { L10n.tr("Localizable", "tk_login_password_note", fallback: "Password") }
  /// Password incorrect. Please try again.
  public static var tkLoginPasswordfailedAlt: String { L10n.tr("Localizable", "tk_login_passwordfailed_alt", fallback: "Password incorrect. Please try again.") }
  /// Please enter your password
  public static var tkLoginPasswordfailedBody: String { L10n.tr("Localizable", "tk_login_passwordfailed_body", fallback: "Please enter your password") }
  /// The password is incorrect. Please try again.
  public static var tkLoginPasswordfailedNotification: String { L10n.tr("Localizable", "tk_login_passwordfailed_notification", fallback: "The password is incorrect. Please try again.") }
  /// Login successful. Please wait.
  public static var tkLoginSpinnerAlt: String { L10n.tr("Localizable", "tk_login_spinner_alt", fallback: "Login successful. Please wait.") }
  /// The swiyu app is locked
  public static var tkLoginVariantBody: String { L10n.tr("Localizable", "tk_login_variant_body", fallback: "The swiyu app is locked") }
  /// App crashes
  public static var tkMenuDiagnosticDataAppCrash: String { L10n.tr("Localizable", "tk_menu_diagnosticData_appCrash", fallback: "App crashes") }
  /// When sharing diagnostic data, the swiyu app occasionally sends anonymous, non-personal information. This data helps us to continuously improve the app and fix errors more quickly. It cannot be traced back to you personally.
  ///
  /// Information transmitted anonymously includes:
  ///
  public static var tkMenuDiagnosticDataBody: String { L10n.tr("Localizable", "tk_menu_diagnosticData_body", fallback: "When sharing diagnostic data, the swiyu app occasionally sends anonymous, non-personal information. This data helps us to continuously improve the app and fix errors more quickly. It cannot be traced back to you personally.\n\nInformation transmitted anonymously includes:\n") }
  /// Communication error
  public static var tkMenuDiagnosticDataCommunicationError: String { L10n.tr("Localizable", "tk_menu_diagnosticData_communicationError", fallback: "Communication error") }
  /// Communication errors
  public static var tkMenuDiagnosticDataGeneralError: String { L10n.tr("Localizable", "tk_menu_diagnosticData_generalError", fallback: "Communication errors") }
  /// Diagnostic data
  public static var tkMenuDiagnosticDataTitle: String { L10n.tr("Localizable", "tk_menu_diagnosticData_title", fallback: "Diagnostic data") }
  /// Create Beta-ID
  public static var tkMenuHomeListAdd: String { L10n.tr("Localizable", "tk_menu_homeList_add", fallback: "Create Beta-ID") }
  /// Help & Contact
  public static var tkMenuHomeListHelp: String { L10n.tr("Localizable", "tk_menu_homeList_help", fallback: "Help & Contact") }
  /// e-ID bestellen (deepl)
  public static var tkMenuHomeListOrderEid: String { L10n.tr("Localizable", "tk_Menu_HomeList_OrderEid", fallback: "e-ID bestellen (deepl)") }
  /// Settings (deepl)
  public static var tkMenuHomeListSettings: String { L10n.tr("Localizable", "tk_menu_homeList_settings", fallback: "Settings (deepl)") }
  /// www.bit.admin.ch
  public static var tkMenuImprintAdminLinkText: String { L10n.tr("Localizable", "tk_menu_imprint_admin_link_text", fallback: "www.bit.admin.ch") }
  /// https://www.bit.admin.ch/en
  public static var tkMenuImprintAdminLinkValue: String { L10n.tr("Localizable", "tk_menu_imprint_admin_link_value", fallback: "https://www.bit.admin.ch/en") }
  /// App Version (deepl)
  public static var tkMenuImprintAppVersion: String { L10n.tr("Localizable", "tk_menu_imprint_appVersion", fallback: "App Version (deepl)") }
  /// Build Nummer
  public static var tkMenuImprintBuildNummer: String { L10n.tr("Localizable", "tk_menu_imprint_buildNummer", fallback: "Build Nummer") }
  /// Federal Department of Finance FDF
  /// Federal Office of Information Technology, Systems and Telecommunication FOITT
  public static var tkMenuImprintDepartmentNote: String { L10n.tr("Localizable", "tk_menu_imprint_department_note", fallback: "Federal Department of Finance FDF\nFederal Office of Information Technology, Systems and Telecommunication FOITT") }
  /// The authors accept no liability for the reliability and completeness of the information. We are not responsible for references and links to third-party websites.
  public static var tkMenuImprintDisclaimerNote: String { L10n.tr("Localizable", "tk_menu_imprint_disclaimer_note", fallback: "The authors accept no liability for the reliability and completeness of the information. We are not responsible for references and links to third-party websites.") }
  /// www.github.com/admin-ch
  public static var tkMenuImprintGithubLinkText: String { L10n.tr("Localizable", "tk_menu_imprint_github_link_text", fallback: "www.github.com/admin-ch") }
  /// https://github.com/e-id-admin
  public static var tkMenuImprintGithubLinkValue: String { L10n.tr("Localizable", "tk_menu_imprint_github_link_value", fallback: "https://github.com/e-id-admin") }
  /// The swiyu app is open source. Its source code can be viewed on GitHub.
  public static var tkMenuImprintNote: String { L10n.tr("Localizable", "tk_menu_imprint_note", fallback: "The swiyu app is open source. Its source code can be viewed on GitHub.") }
  /// Disclaimer
  public static var tkMenuImprintSubtitleDisclaimer: String { L10n.tr("Localizable", "tk_menu_imprint_subtitle_disclaimer", fallback: "Disclaimer") }
  /// Legal aspects
  public static var tkMenuImprintSubtitleLegal: String { L10n.tr("Localizable", "tk_menu_imprint_subtitle_legal", fallback: "Legal aspects") }
  /// Issuer, implementation and operation
  public static var tkMenuImprintSubtitlePublisher: String { L10n.tr("Localizable", "tk_menu_imprint_subtitle_publisher", fallback: "Issuer, implementation and operation") }
  /// Terms of use
  public static var tkMenuImprintTermsOfUseLinkText: String { L10n.tr("Localizable", "tk_menu_imprint_termsOfUse_link_text", fallback: "Terms of use") }
  /// https://www.eid.admin.ch/en/swiyu-terms-e
  public static var tkMenuImprintTermsOfUseLinkValue: String { L10n.tr("Localizable", "tk_menu_imprint_termsOfUse_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-terms-e") }
  /// Legal notice
  public static var tkMenuImprintTitle: String { L10n.tr("Localizable", "tk_menu_imprint_title", fallback: "Legal notice") }
  /// Language
  public static var tkMenuLanguageTitle: String { L10n.tr("Localizable", "tk_menu_language_title", fallback: "Language") }
  /// Here you will find an overview of the software licences used by the swiyu app.
  /// The licences comply with the FOITT privacy guidelines and the latest security standards. We would like to create transparency for our users with this list.
  public static var tkMenuLicencesBody: String { L10n.tr("Localizable", "tk_menu_licences_body", fallback: "Here you will find an overview of the software licences used by the swiyu app.\nThe licences comply with the FOITT privacy guidelines and the latest security standards. We would like to create transparency for our users with this list.") }
  /// Further information (deepl)
  public static var tkMenuLicencesLinkText: String { L10n.tr("Localizable", "tk_menu_licences_link_text", fallback: "Further information (deepl)") }
  /// Licences
  public static var tkMenuLicencesTitle: String { L10n.tr("Localizable", "tk_menu_licences_title", fallback: "Licences") }
  /// Biometric unlocking has been enabled.
  public static var tkMenuSecurityPrivacyAndroidStatusActivating: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_android_status_activating", fallback: "Biometric unlocking has been enabled.") }
  /// diagnostic data (deepl)
  public static var tkMenuSecurityPrivacyDataProtectionDiagnosticData: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_diagnosticData", fallback: "diagnostic data (deepl)") }
  /// Privacy Statement
  public static var tkMenuSecurityPrivacyDataProtectionPrivacyPolicy: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_privacyPolicy", fallback: "Privacy Statement") }
  /// Share diagnostic data
  public static var tkMenuSecurityPrivacyDataProtectionShareData: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_shareData", fallback: "Share diagnostic data") }
  /// Help us make the swiyu app even better by anonymously sharing error messages and crashes.
  public static var tkMenuSecurityPrivacyDataProtectionShareDataBody: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_dataProtection_shareData_body", fallback: "Help us make the swiyu app even better by anonymously sharing error messages and crashes.") }
  /// Change password (deepl)
  public static var tkMenuSecurityPrivacySecurityChangePassword: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_security_changePassword", fallback: "Change password (deepl)") }
  /// Password successfully changed
  public static var tkMenuSecurityPrivacyStatusPasswordChangeSuccessful: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_status_passwordChangeSuccessful", fallback: "Password successfully changed") }
  /// Data protection and privacy
  public static var tkMenuSecurityPrivacySubtitleDataProtection: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_subtitle_dataProtection", fallback: "Data protection and privacy") }
  /// Security
  public static var tkMenuSecurityPrivacySubtitleSecurity: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_subtitle_security", fallback: "Security") }
  /// Security and data protection (deepl)
  public static var tkMenuSecurityPrivacyTitle: String { L10n.tr("Localizable", "tk_menu_securityPrivacy_title", fallback: "Security and data protection (deepl)") }
  /// General
  public static var tkMenuSettingSubtitleGeneral: String { L10n.tr("Localizable", "tk_menu_setting_subtitle_general", fallback: "General") }
  /// Settings (deepl)
  public static var tkMenuSettingTitle: String { L10n.tr("Localizable", "tk_menu_setting_title", fallback: "Settings (deepl)") }
  /// Give feedback
  public static var tkMenuSettingWalletFeedback: String { L10n.tr("Localizable", "tk_menu_setting_wallet_feedback", fallback: "Give feedback") }
  /// https://findmind.ch/c/feedback_public_beta_en
  public static var tkMenuSettingWalletFeedbackLinkValue: String { L10n.tr("Localizable", "tk_menu_setting_wallet_feedback_link_value", fallback: "https://findmind.ch/c/feedback_public_beta_en") }
  /// Help & Contact (deepl)
  public static var tkMenuSettingWalletHelp: String { L10n.tr("Localizable", "tk_menu_setting_wallet_help", fallback: "Help & Contact (deepl)") }
  /// Legal notice
  public static var tkMenuSettingWalletImprint: String { L10n.tr("Localizable", "tk_menu_setting_wallet_imprint", fallback: "Legal notice") }
  /// Language
  public static var tkMenuSettingWalletLanguage: String { L10n.tr("Localizable", "tk_menu_setting_wallet_language", fallback: "Language") }
  /// German
  public static var tkMenuSettingWalletLanguageChoiceDe: String { L10n.tr("Localizable", "tk_menu_setting_wallet_languageChoiceDe", fallback: "German") }
  /// Licences
  public static var tkMenuSettingWalletLicences: String { L10n.tr("Localizable", "tk_menu_setting_wallet_licences", fallback: "Licences") }
  /// Security and data protection
  public static var tkMenuSettingWalletSecurity: String { L10n.tr("Localizable", "tk_menu_setting_wallet_security", fallback: "Security and data protection") }
  /// Share feedback
  public static var tkMenuSetupMenuFeedback: String { L10n.tr("Localizable", "tk_menu_setup_menu_feedback", fallback: "Share feedback") }
  /// Wallet
  public static var tkMenuSetupSubtitleWallet: String { L10n.tr("Localizable", "tk_menu_setup_subtitle_wallet", fallback: "Wallet") }
  /// Allow
  public static var tkOnboardingAnalyticsButtonPrimary: String { L10n.tr("Localizable", "tk_onboarding_analytics_button_primary", fallback: "Allow") }
  /// Do not allow
  public static var tkOnboardingAnalyticsButtonSecondary: String { L10n.tr("Localizable", "tk_onboarding_analytics_button_secondary", fallback: "Do not allow") }
  /// Contribute anonymously to improving the app
  public static var tkOnboardingAnalyticsPrimary: String { L10n.tr("Localizable", "tk_onboarding_analytics_primary", fallback: "Contribute anonymously to improving the app") }
  /// Take advantage of an app tailored to your needs. Do you want to share your anonymous user data with the development team in return?
  public static var tkOnboardingAnalyticsSecondary: String { L10n.tr("Localizable", "tk_onboarding_analytics_secondary", fallback: "Take advantage of an app tailored to your needs. Do you want to share your anonymous user data with the development team in return?") }
  /// Link to exit swiyu app
  public static var tkOnboardingAnalyticsTertiaryLinkAlt: String { L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_alt", fallback: "Link to exit swiyu app") }
  /// Data protection and security
  public static var tkOnboardingAnalyticsTertiaryLinkText: String { L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_text", fallback: "Data protection and security") }
  /// https://www.eid.admin.ch/en/swiyu-privacy-e
  public static var tkOnboardingAnalyticsTertiaryLinkValue: String { L10n.tr("Localizable", "tk_onboarding_analytics_tertiary_link_value", fallback: "https://www.eid.admin.ch/en/swiyu-privacy-e") }
  /// Yes please
  public static var tkOnboardingBiometricsPermissionButtonPrimary: String { L10n.tr("Localizable", "tk_onboarding_biometricsPermission_button_primary", fallback: "Yes please") }
  /// You can still log in with your password, if biometrics are not working
  public static var tkOnboardingBiometricsPermissionReason: String { L10n.tr("Localizable", "tk_onboarding_biometricsPermission_reason", fallback: "You can still log in with your password, if biometrics are not working") }
  /// Go to settings
  public static var tkOnboardingBiometricsPermissionDisabledButtonPrimary: String { L10n.tr("Localizable", "tk_onboarding_biometricsPermissionDisabled_button_primary", fallback: "Go to settings") }
  /// Password must be at least 6 characters
  public static var tkOnboardingCharactersSubtitle: String { L10n.tr("Localizable", "tk_onboarding_characters_subtitle", fallback: "Password must be at least 6 characters") }
  /// Confirm password
  public static var tkOnboardingConfirmNote: String { L10n.tr("Localizable", "tk_onboarding_confirm_note", fallback: "Confirm password") }
  /// All done!
  public static var tkOnboardingDonePrimary: String { L10n.tr("Localizable", "tk_onboarding_done_primary", fallback: "All done!") }
  /// Your swiyu app now has optimal protection against unauthorised access.
  public static var tkOnboardingDoneSecondary: String { L10n.tr("Localizable", "tk_onboarding_done_secondary", fallback: "Your swiyu app now has optimal protection against unauthorised access.") }
  /// Try again
  public static var tkOnboardingDoneErrorButtonPrimary: String { L10n.tr("Localizable", "tk_onboarding_doneError_button_primary", fallback: "Try again") }
  /// Something has gone wrong
  public static var tkOnboardingDoneErrorPrimary: String { L10n.tr("Localizable", "tk_onboarding_doneError_primary", fallback: "Something has gone wrong") }
  /// We cannot setup the app at the moment. Please try again.
  public static var tkOnboardingDoneErrorSecondary: String { L10n.tr("Localizable", "tk_onboarding_doneError_secondary", fallback: "We cannot setup the app at the moment. Please try again.") }
  /// Never forget your ID again
  public static var tkOnboardingIntroductionStepNeverForgetPrimary: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_neverForget_primary", fallback: "Never forget your ID again") }
  /// Thanks to the swiyu app, you always have your ID with you on your mobile phone.
  public static var tkOnboardingIntroductionStepNeverForgetSecondary: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_neverForget_secondary", fallback: "Thanks to the swiyu app, you always have your ID with you on your mobile phone.") }
  /// Start
  public static var tkOnboardingIntroductionStepSecurityButtonPrimary: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_security_button_primary", fallback: "Start") }
  /// Storing digital IDs securely
  public static var tkOnboardingIntroductionStepSecurityPrimary: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_security_primary", fallback: "Storing digital IDs securely") }
  /// Welcome to the onboarding for the swiyu app.
  public static var tkOnboardingIntroductionStepSecurityScreenAlt: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_security_screen_alt", fallback: "Welcome to the onboarding for the swiyu app.") }
  /// Your ID data is encrypted and stored locally in the swiyu app on your mobile phone.
  public static var tkOnboardingIntroductionStepSecuritySecondary: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_security_secondary", fallback: "Your ID data is encrypted and stored locally in the swiyu app on your mobile phone.") }
  /// Your data belongs to you
  public static var tkOnboardingIntroductionStepYourDataPrimary: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_primary", fallback: "Your data belongs to you") }
  /// You have control over who can check your ID data, and when. No access without permission.
  public static var tkOnboardingIntroductionStepYourDataSecondary: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_secondary", fallback: "You have control over who can check your ID data, and when. No access without permission.") }
  /// Learn more about SSI technology
  public static var tkOnboardingIntroductionStepYourDataTertiaryLinkText: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_text", fallback: "Learn more about SSI technology") }
  /// Link to exit swiyu app
  public static var tkOnboardingIntroductionStepYourDataTertiaryLinkTextAlt: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_text_alt", fallback: "Link to exit swiyu app") }
  /// https://www.eid.admin.ch/en/technology
  public static var tkOnboardingIntroductionStepYourDataTertiaryLinkValue: String { L10n.tr("Localizable", "tk_onboarding_introductionStep_yourData_tertiary_link_value", fallback: "https://www.eid.admin.ch/en/technology") }
  /// Please confirm the password
  public static var tkOnboardingNopasswordmismatchAlt: String { L10n.tr("Localizable", "tk_onboarding_nopasswordmismatch_alt", fallback: "Please confirm the password") }
  /// The passwords do not match. Please try again.
  public static var tkOnboardingNopasswordmismatchNotification: String { L10n.tr("Localizable", "tk_onboarding_nopasswordmismatch_notification", fallback: "The passwords do not match. Please try again.") }
  /// Please enter your password
  public static var tkOnboardingPasswordErrorEmpty: String { L10n.tr("Localizable", "tk_onboarding_password_error_empty", fallback: "Please enter your password") }
  /// Password mismatch
  public static var tkOnboardingPasswordErrorMismatch: String { L10n.tr("Localizable", "tk_onboarding_password_error_mismatch", fallback: "Password mismatch") }
  /// Enter swiyu app password
  public static var tkOnboardingPasswordInputAlt: String { L10n.tr("Localizable", "tk_onboarding_password_input_alt", fallback: "Enter swiyu app password") }
  /// Password
  public static var tkOnboardingPasswordInputPlaceholder: String { L10n.tr("Localizable", "tk_onboarding_password_input_placeholder", fallback: "Password") }
  /// Password must be at least 6 characters
  public static var tkOnboardingPasswordInputSubtitle: String { L10n.tr("Localizable", "tk_onboarding_password_input_subtitle", fallback: "Password must be at least 6 characters") }
  /// Password
  public static var tkOnboardingPasswordPlaceholder: String { L10n.tr("Localizable", "tk_onboarding_password_placeholder", fallback: "Password") }
  /// Enter password
  public static var tkOnboardingPasswordTitle: String { L10n.tr("Localizable", "tk_onboarding_password_title", fallback: "Enter password") }
  /// Enter swiyu app password
  public static var tkOnboardingPasswordConfirmationInputAlt: String { L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_alt", fallback: "Enter swiyu app password") }
  /// The password is incorrect. Please try again.
  public static var tkOnboardingPasswordConfirmationInputErrorWrongPassword: String { L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_error_wrongPassword", fallback: "The password is incorrect. Please try again.") }
  /// Password
  public static var tkOnboardingPasswordConfirmationInputPlaceholder: String { L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_input_placeholder", fallback: "Password") }
  /// Confirm password
  public static var tkOnboardingPasswordConfirmationTitle: String { L10n.tr("Localizable", "tk_onboarding_passwordConfirmation_title", fallback: "Confirm password") }
  /// Create password
  public static var tkOnboardingPassworderrorPrimarybutton: String { L10n.tr("Localizable", "tk_onboarding_passworderror_primarybutton", fallback: "Create password") }
  /// Failed to set up the password
  public static var tkOnboardingPassworderrorTitle: String { L10n.tr("Localizable", "tk_onboarding_passworderror_title", fallback: "Failed to set up the password") }
  /// Create password
  public static var tkOnboardingPasswordIntroductionButtonPrimary: String { L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_button_primary", fallback: "Create password") }
  /// Incorrect password entered too many times. Please set a new password.
  public static var tkOnboardingPasswordIntroductionErrorTooManyAttempts: String { L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_error_tooManyAttempts", fallback: "Incorrect password entered too many times. Please set a new password.") }
  /// Secure the app with a password
  public static var tkOnboardingPasswordIntroductionPrimary: String { L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_primary", fallback: "Secure the app with a password") }
  /// Protect your app from unauthorised access.
  public static var tkOnboardingPasswordIntroductionSecondary: String { L10n.tr("Localizable", "tk_onboarding_passwordIntroduction_secondary", fallback: "Protect your app from unauthorised access.") }
  /// Password must be at least 6 characters
  public static var tkOnboardingPasswordlengthNotification: String { L10n.tr("Localizable", "tk_onboarding_passwordlength_notification", fallback: "Password must be at least 6 characters") }
  /// Please wait a moment...
  public static var tkOnboardingSetupPrimary: String { L10n.tr("Localizable", "tk_onboarding_setup_primary", fallback: "Please wait a moment...") }
  /// Your settings are being applied. This may take up to 30 seconds.
  public static var tkOnboardingSetupSecondary: String { L10n.tr("Localizable", "tk_onboarding_setup_secondary", fallback: "Your settings are being applied. This may take up to 30 seconds.") }
  /// Sorry, the swiyu app cannot currently be loaded. Please try again.
  public static var tkOnboardingSomethingwentwrongBody: String { L10n.tr("Localizable", "tk_onboarding_somethingwentwrong_body", fallback: "Sorry, the swiyu app cannot currently be loaded. Please try again.") }
  /// Try again
  public static var tkOnboardingSomethingwentwrongPrimarybutton: String { L10n.tr("Localizable", "tk_onboarding_somethingwentwrong_primarybutton", fallback: "Try again") }
  /// Something went wrong
  public static var tkOnboardingSomethingwentwrongTitle: String { L10n.tr("Localizable", "tk_onboarding_somethingwentwrong_title", fallback: "Something went wrong") }
  /// Requested data
  public static var tkPresentApprovalTitle: String { L10n.tr("Localizable", "tk_present_approval_title", fallback: "Requested data") }
  /// Select ID or document
  public static var tkPresentCompatibleCredentialsPrimary: String { L10n.tr("Localizable", "tk_present_compatibleCredentials_primary", fallback: "Select ID or document") }
  /// Sorry, no details could be sent
  public static var tkPresentNoinformationprovidedTitle: String { L10n.tr("Localizable", "tk_present_noinformationprovided_title", fallback: "Sorry, no details could be sent") }
  /// Verification cancelled
  public static var tkPresentResultCanceledVerificationPrimary: String { L10n.tr("Localizable", "tk_present_result_canceledVerification_primary", fallback: "Verification cancelled") }
  /// No data was transmitted.
  public static var tkPresentResultCanceledVerificationSecondary: String { L10n.tr("Localizable", "tk_present_result_canceledVerification_secondary", fallback: "No data was transmitted.") }
  /// Confirmation
  public static var tkPresentResultConfirmAlt: String { L10n.tr("Localizable", "tk_present_result_confirm_alt", fallback: "Confirmation") }
  /// Data was not transmitted
  public static var tkPresentResultDeclinedPrimary: String { L10n.tr("Localizable", "tk_present_result_declined_primary", fallback: "Data was not transmitted") }
  /// Try again
  public static var tkPresentResultErrorButtonRetry: String { L10n.tr("Localizable", "tk_present_result_error_button_retry", fallback: "Try again") }
  /// Oops, something went wrong!
  public static var tkPresentResultErrorPrimary: String { L10n.tr("Localizable", "tk_present_result_error_primary", fallback: "Oops, something went wrong!") }
  /// Please try again
  public static var tkPresentResultErrorSecondary: String { L10n.tr("Localizable", "tk_present_result_error_secondary", fallback: "Please try again") }
  /// Verification of the transmitted data failed.
  public static var tkPresentResultInvalidCredentialPrimary: String { L10n.tr("Localizable", "tk_present_result_invalidCredential_primary", fallback: "Verification of the transmitted data failed.") }
  /// Please check the validity of your credential.
  public static var tkPresentResultInvalidCredentialSecondary: String { L10n.tr("Localizable", "tk_present_result_invalidCredential_secondary", fallback: "Please check the validity of your credential.") }
  /// Your details have been successfully transmitted.
  public static var tkPresentResultSuccessPrimary: String { L10n.tr("Localizable", "tk_present_result_success_primary", fallback: "Your details have been successfully transmitted.") }
  /// Required credential available
  public static var tkPresentResultSuccessPrimary2: String { L10n.tr("Localizable", "tk_present_result_success_primary2", fallback: "Required credential available") }
  /// Warning
  public static var tkPresentResultWarningAlt: String { L10n.tr("Localizable", "tk_present_result_warning_alt", fallback: "Warning") }
  /// Allow
  public static var tkPresentReviewButtonAccept: String { L10n.tr("Localizable", "tk_present_review_button_accept", fallback: "Allow") }
  /// Allow sharing information
  public static var tkPresentReviewButtonAcceptAlt: String { L10n.tr("Localizable", "tk_present_review_button_accept_alt", fallback: "Allow sharing information") }
  /// Decline
  public static var tkPresentReviewButtonDecline: String { L10n.tr("Localizable", "tk_present_review_button_decline", fallback: "Decline") }
  /// Decline sharing information
  public static var tkPresentReviewButtonDeclineAlt: String { L10n.tr("Localizable", "tk_present_review_button_decline_alt", fallback: "Decline sharing information") }
  /// Would like to check your credential
  public static var tkPresentReviewCredentialSectionPrimary: String { L10n.tr("Localizable", "tk_present_review_credential_section_primary", fallback: "Would like to check your credential") }
  /// Please wait
  public static var tkPresentReviewLoading: String { L10n.tr("Localizable", "tk_present_review_loading", fallback: "Please wait") }
  /// Please wait. Your data are being sent.
  public static var tkPresentReviewLoadingAlt: String { L10n.tr("Localizable", "tk_present_review_loading_alt", fallback: "Please wait. Your data are being sent.") }
  /// Allow
  public static var tkPresentReviewPrimaryButton: String { L10n.tr("Localizable", "tk_present_review_primaryButton", fallback: "Allow") }
  /// Share information
  public static var tkPresentReviewPrimaryButtonAlt: String { L10n.tr("Localizable", "tk_present_review_primaryButton_alt", fallback: "Share information") }
  /// Decline
  public static var tkPresentReviewSecondaryButton: String { L10n.tr("Localizable", "tk_present_review_secondaryButton", fallback: "Decline") }
  /// Deny
  public static var tkPresentReviewSecondaryButtonAlt: String { L10n.tr("Localizable", "tk_present_review_secondaryButton_alt", fallback: "Deny") }
  /// Unknown verificator
  public static var tkPresentVerifierNameUnknown: String { L10n.tr("Localizable", "tk_present_verifier_name_unknown", fallback: "Unknown verificator") }
  /// Close QR code scanner
  public static var tkQrscannerButtonCloseAlt: String { L10n.tr("Localizable", "tk_qrscanner_button_close_alt", fallback: "Close QR code scanner") }
  /// This QR code has already been used. Please request a new QR code.
  public static var tkQrscannerInvalidcodeBody: String { L10n.tr("Localizable", "tk_qrscanner_invalidcode_body", fallback: "This QR code has already been used. Please request a new QR code.") }
  /// Was the QR code used without your knowledge?
  public static var tkQrscannerInvalidcodeLinkText: String { L10n.tr("Localizable", "tk_qrscanner_invalidcode_link_text", fallback: "Was the QR code used without your knowledge?") }
  /// https://www.eid.admin.ch/en
  public static var tkQrscannerInvalidcodeLinkValue: String { L10n.tr("Localizable", "tk_qrscanner_invalidcode_link_value", fallback: "https://www.eid.admin.ch/en") }
  /// QR code no longer valid
  public static var tkQrscannerInvalidcodeTitle: String { L10n.tr("Localizable", "tk_qrscanner_invalidcode_title", fallback: "QR code no longer valid") }
  /// Flashlight off. Double tap to turn on
  public static var tkQrscannerLightoffLabel: String { L10n.tr("Localizable", "tk_qrscanner_lightoff_label", fallback: "Flashlight off. Double tap to turn on") }
  /// Flashlight on. Double tap to turn off
  public static var tkQrscannerLightonLabel: String { L10n.tr("Localizable", "tk_qrscanner_lighton_label", fallback: "Flashlight on. Double tap to turn off") }
  /// Flashlight is on
  public static var tkQrscannerLightonTitle: String { L10n.tr("Localizable", "tk_qrscanner_lighton_title", fallback: "Flashlight is on") }
  /// More light needed
  public static var tkQrscannerMorelightneededTitle: String { L10n.tr("Localizable", "tk_qrscanner_morelightneeded_title", fallback: "More light needed") }
  /// QR code scanned
  public static var tkQrscannerProcessingAlt: String { L10n.tr("Localizable", "tk_qrscanner_processing_alt", fallback: "QR code scanned") }
  /// To identify yourself or add IDs and documents.
  public static var tkQrscannerScanningBody: String { L10n.tr("Localizable", "tk_qrscanner_scanning_body", fallback: "To identify yourself or add IDs and documents.") }
  /// Scan QR code
  public static var tkQrscannerScanningTitle: String { L10n.tr("Localizable", "tk_qrscanner_scanning_title", fallback: "Scan QR code") }
  /// Go to details
  public static var tkReceiveApprovalHiddenlinkText: String { L10n.tr("Localizable", "tk_receive_approval_hiddenlink_text", fallback: "Go to details") }
  /// Would like to issue the following credential:
  public static var tkReceiveApprovalSubtitle: String { L10n.tr("Localizable", "tk_receive_approval_subtitle", fallback: "Would like to issue the following credential:") }
  /// The camera is an important function. Without a camera, you cannot receive IDs and documents or identify yourself.
  public static var tkReceiveCameraaccessneeded1Body: String { L10n.tr("Localizable", "tk_receive_cameraaccessneeded1_body", fallback: "The camera is an important function. Without a camera, you cannot receive IDs and documents or identify yourself.") }
  /// Allow access to camera
  public static var tkReceiveCameraaccessneeded1Title: String { L10n.tr("Localizable", "tk_receive_cameraaccessneeded1_title", fallback: "Allow access to camera") }
  /// Camera access has expired. Please allow access again.
  public static var tkReceiveCameraaccessneeded2Body: String { L10n.tr("Localizable", "tk_receive_cameraaccessneeded2_body", fallback: "Camera access has expired. Please allow access again.") }
  /// Allow access to camera
  public static var tkReceiveCameraaccessneeded2Title: String { L10n.tr("Localizable", "tk_receive_cameraaccessneeded2_title", fallback: "Allow access to camera") }
  /// Please go to Settings and allow access.
  ///
  /// Without a camera, you cannot receive IDs and documents or identify yourself.
  public static var tkReceiveCameraaccessneeded3Body: String { L10n.tr("Localizable", "tk_receive_cameraaccessneeded3_body", fallback: "Please go to Settings and allow access.\n\nWithout a camera, you cannot receive IDs and documents or identify yourself.") }
  /// Allow access to camera
  public static var tkReceiveCameraaccessneeded3Title: String { L10n.tr("Localizable", "tk_receive_cameraaccessneeded3_title", fallback: "Allow access to camera") }
  /// The swiyu app wants to access your camera
  public static var tkReceiveCameraaccessneeded4Title: String { L10n.tr("Localizable", "tk_receive_cameraaccessneeded4_title", fallback: "The swiyu app wants to access your camera") }
  /// Add
  public static var tkReceiveCredentialOfferButtonAccept: String { L10n.tr("Localizable", "tk_receive_credentialOffer_button_accept", fallback: "Add") }
  /// Decline
  public static var tkReceiveCredentialOfferButtonDecline: String { L10n.tr("Localizable", "tk_receive_credentialOffer_button_decline", fallback: "Decline") }
  /// Details
  public static var tkReceiveCredentialOfferContentSectionPrimary: String { L10n.tr("Localizable", "tk_receive_credentialOffer_contentSection_primary", fallback: "Details") }
  /// Would like to issue the following credential:
  public static var tkReceiveCredentialOfferHeaderSectionSecondary: String { L10n.tr("Localizable", "tk_receive_credentialOffer_headerSection_secondary", fallback: "Would like to issue the following credential:") }
  /// Found any incorrect data?
  public static var tkReceiveCredentialOfferWrongDataPrimary: String { L10n.tr("Localizable", "tk_receive_credentialOffer_wrongData_primary", fallback: "Found any incorrect data?") }
  /// Once issued, a credential cannot be changed.
  ///
  /// If you notice an error in your data, please contact the issuer.
  /// They can issue a new, corrected credential.
  public static var tkReceiveCredentialOfferWrongDataSecondary: String { L10n.tr("Localizable", "tk_receive_credentialOffer_wrongData_secondary", fallback: "Once issued, a credential cannot be changed.\n\nIf you notice an error in your data, please contact the issuer.\nThey can issue a new, corrected credential.") }
  /// Report incorrect details
  public static var tkReceiveCredentialOfferWrongDataSectionCellPrimary: String { L10n.tr("Localizable", "tk_receive_credentialOffer_wrongDataSection_cell_primary", fallback: "Report incorrect details") }
  /// Decline credential?
  public static var tkReceiveDeclineOfferPrimary: String { L10n.tr("Localizable", "tk_receive_declineOffer_primary", fallback: "Decline credential?") }
  /// Decline credential
  public static var tkReceiveDeclineOfferPrimaryButton: String { L10n.tr("Localizable", "tk_receive_declineOffer_primaryButton", fallback: "Decline credential") }
  /// If you decline the credential now, it will immediately become invalid.
  ///
  /// You must then request a new credential.
  public static var tkReceiveDeclineOfferSecondary: String { L10n.tr("Localizable", "tk_receive_declineOffer_secondary", fallback: "If you decline the credential now, it will immediately become invalid.\n\nYou must then request a new credential.") }
  /// Credential declined
  public static var tkReceiveDeny2Title: String { L10n.tr("Localizable", "tk_receive_deny2_title", fallback: "Credential declined") }
  /// Report incorrect details
  public static var tkReceiveIncorrectdataTitle: String { L10n.tr("Localizable", "tk_receive_incorrectdata_title", fallback: "Report incorrect details") }
  /// Camera searching for QR code
  public static var tkReceiveScanningAlt: String { L10n.tr("Localizable", "tk_receive_scanning_alt", fallback: "Camera searching for QR code") }
  /// No QR code found. Try to reposition the camera.
  public static var tkReceiveScanningNotfoundAlt: String { L10n.tr("Localizable", "tk_receive_scanning_notfound_alt", fallback: "No QR code found. Try to reposition the camera.") }
  /// Please define a smartphone passcode so that you can use the app.
  public static var tkUnsafedeviceUnsafeBody: String { L10n.tr("Localizable", "tk_unsafedevice_unsafe_body", fallback: "Please define a smartphone passcode so that you can use the app.") }
  /// Go to settings
  public static var tkUnsafedeviceUnsafePrimaryButton: String { L10n.tr("Localizable", "tk_unsafedevice_unsafe_primaryButton", fallback: "Go to settings") }
  ///
  public static var tkUnsafedeviceUnsafeSmallbody: String { L10n.tr("Localizable", "tk_unsafedevice_unsafe_smallbody", fallback: " ") }
  /// Missing smartphone code
  public static var tkUnsafedeviceUnsafeTitle: String { L10n.tr("Localizable", "tk_unsafedevice_unsafe_title", fallback: "Missing smartphone code") }
  /// Update app
  public static var versionEnforcementButton: String { L10n.tr("Localizable", "version_enforcement_button", fallback: "Update app") }

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

  /// e-ID status for %@ unknown
  public static func tkGetEidNotificationEidUnknownStatePrimary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_getEid_notification_eidUnknownState_primary", String(describing: p1), fallback: "e-ID status for %@ unknown")
  }

  /// Please verify your identity by %@, otherwise your order will be canceled.
  ///
  /// Your parents’ or legal guardian’s consent is still missing.
  public static func tkGetEidNotificationLegalRepresentantPendingConsentReadyForAVSecondary(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_getEid_notification_legalRepresentantPendingConsent_readyForAV_secondary", String(describing: p1), fallback: "Please verify your identity by %@, otherwise your order will be canceled.\n\nYour parents’ or legal guardian’s consent is still missing.")
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

  /// %@ is not enabled on this device. Go to the device settings to enable biometrics.
  public static func tkMenuSecurityPrivacyMenuIosUnlockBody(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_securityPrivacy_menu_ios_unlock_body", String(describing: p1), fallback: "%@ is not enabled on this device. Go to the device settings to enable biometrics.")
  }

  /// Unlock with %@
  public static func tkMenuSecurityPrivacySecurityIosUnlock(_ p1: Any) -> String {
    L10n.tr("Localizable", "tk_menu_securityPrivacy_security_ios_unlock", String(describing: p1), fallback: "Unlock with %@")
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
    let format = TranslationHelper.localizeString(key, table, value)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}
