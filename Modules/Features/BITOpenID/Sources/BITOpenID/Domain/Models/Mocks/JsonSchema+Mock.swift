#if DEBUG
import Foundation
@testable import BITCore

extension String.Mock {
  static let draft202012 = Mocker.getString(fromFile: "json-meta-schema-202012", ofType: "json", bundle: Bundle.module)
  static let draft202012Data = Mocker.getData(fromFile: "json-meta-schema-202012", ofType: "json", bundle: Bundle.module) ?? Data()
  static let schemaCredential = Mocker.getData(fromFile: "json-schema-credential", ofType: "json", bundle: Bundle.module) ?? Data()
  static let schemaMalformed = Mocker.getData(fromFile: "json-schema-malformed", ofType: "json", bundle: Bundle.module) ?? Data()
  static let schemaInsufficient = Mocker.getData(fromFile: "json-schema-insufficient-vcSdJwt", ofType: "json", bundle: Bundle.module) ?? Data()
  static let schemaWithRegex = JsonSchemaMock.withRegularExpression.data
}

#endif
