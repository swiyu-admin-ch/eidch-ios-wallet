import Foundation

struct OCACaptureBaseMocks {

  static let validInputs: [String] = [
    OCACaptureBaseMocks.validInput01,
    OCACaptureBaseMocks.validInput02,
    OCACaptureBaseMocks.validInput03,
    OCACaptureBaseMocks.validInput04,
    OCACaptureBaseMocks.validInput05,
  ]

  static let validInput01 = """
  {
      "type":"spec/capture_base/1.0",
      "digest":"IBYzBHEN4moeVO_aQtW_DbDoQd-30BgeJQMyfsRzoUFI",
      "attributes":{
          "name":"Text"
      }
  }
  """

  static let validInput01DummyCanonicalized = """
  {"attributes":{"name":"Text"},"digest":"############################################","type":"spec/capture_base/1.0"}
  """

  static let validInput02 = """
  {
      "type": "spec/capture_base/1.0",
      "digest": "IEaoDFlT--ZaM8F_Y8sJosPaPwEBu06BZWAjZu1mVE2o",
      "attributes": {
          "firstname": "Text",
          "lastname": "Text",
          "address_street": "Text",
          "address_city": "Text",
          "address_country": "Text"
      }
  }
  """

  static let validInput02DummyCanonicalized = """
  {"attributes":{"address_city":"Text","address_country":"Text","address_street":"Text","firstname":"Text","lastname":"Text"},"digest":"############################################","type":"spec/capture_base/1.0"}
  """

  static let validInput03 = """
  {
      "attributes":{
          "name":"Text",
          "race":"Text"
      },
      "type":"spec/capture_base/1.0",
      "digest":"IKLvtGx1NU0007DUTTmI_6Zw-hnGRFicZ5R4vAxg4j2j"
  }
  """

  static let validInput03DummyCanonicalized = """
  {"attributes":{"name":"Text","race":"Text"},"digest":"############################################","type":"spec/capture_base/1.0"}
  """

  static let validInput04 = """
  {
      "type":"spec/capture_base/1.0",
      "digest":"IFM8RfatBApjAWtUuoPdHBw7u-poW49aGCMSgoK1pwu5",
      "attributes":{
          "picture":"Text"
      }
  }
  """

  static let validInput04DummyCanonicalized = """
  {"attributes":{"picture":"Text"},"digest":"############################################","type":"spec/capture_base/1.0"}
  """

  static let validInput02alt = """
  {"attributes":{"address_city":"Text","address_country":"Text","address_street":"Text","firstname":"Text","lastname":"Text"},"digest":"IEaoDFlT--ZaM8F_Y8sJosPaPwEBu06BZWAjZu1mVE2o","type":"spec/capture_base/1.0"}
  """

  static let validInput05 = """
  {
      "type": "spec/capture_base/1.0",
      "digest": "IH9w8JN_ZE4maSfcs27R33JdV_ClH7jilM9mnlS9j_0j",
      "attributes": {
          "firstname": "Text",
          "lastname": "Text",
          "address_street": "Text",
          "address_city": "Text",
          "address_country": "Text",
          "pets": "Array[refs:IKLvtGx1NU0007DUTTmI_6Zw-hnGRFicZ5R4vAxg4j2j]"
      }
  }
  """

  static let validInput05DummyCanonicalized = """
  {"attributes":{"address_city":"Text","address_country":"Text","address_street":"Text","firstname":"Text","lastname":"Text","pets":"Array[refs:IKLvtGx1NU0007DUTTmI_6Zw-hnGRFicZ5R4vAxg4j2j]"},"digest":"############################################","type":"spec/capture_base/1.0"}
  """

  static let wrongAlgorithm = """
  {
      "type": "spec/capture_base/1.0",
      "digest": "HEaoDFlT--ZaM8F_Y8sJosPaPwEBu06BZWAjZu1mVE2o",
      "attributes": {
          "firstname": "Text",
          "lastname": "Text",
          "address_street": "Text",
          "address_city": "Text",
          "address_country": "Text"
      }
  }
  """

  static let wrongDigest = """
  {
      "type": "spec/capture_base/1.0",
      "digest": "ThisIsInvalid",
      "attributes": {
          "firstname": "Text"
      }
  }
  """

  static let noDigest = """
  {
      "type": "spec/capture_base/1.0",
      "attributes": {
          "firstname": "Text",
          "lastname": "Text"
      }
  }
  """

  static let emptyDigest = """
  {
      "type": "spec/capture_base/1.0",
      "digest": "",
      "attributes": {
          "firstname": "Text"
      }
  }
  """

  static let wrongJson = """
  {
      "type":"spec/capture_base/1.0",
      "digest":"IBYzBHEN4moeVO_aQtW_DbDoQd-30BgeJQMyfsRzoUFI",
      "attributes":{
          "name":"Text",
      }
  """

}
