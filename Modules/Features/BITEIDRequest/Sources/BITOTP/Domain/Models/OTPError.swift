enum OTPError: Error {
  case invalidFormat
  case forbiddenEmail
  case serviceDeactivated
  case invalidClientAttestation
  case otpExpired
  case tooManyRequests
  case unknown
}
