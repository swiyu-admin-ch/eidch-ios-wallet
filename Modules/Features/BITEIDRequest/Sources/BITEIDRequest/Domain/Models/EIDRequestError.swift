import Foundation

enum EIDRequestError: Error {
  case missingCaseId
  case missingAuthenticationToken
}
