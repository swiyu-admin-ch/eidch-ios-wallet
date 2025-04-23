import XCTest
@testable import BITOpenID

final class CredentialDisplayLogoURIDecoderTests: XCTestCase {

  // MARK: Internal

  func testParseDataUri_success() throws {
    guard let mockUri = URL(string: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACPSURBVHgB7ZbbCYAwDEVvxEHcREdzlI7gCHUDN9AtfEJM0S9BUWwrSA5cWujHgdA2oWFcWhAyxKGjYVpYNpaZawSEiHJZCjhhP84lAuMczpUgMir8Tii32PBGiRdoSVWoQhX+UJjiOfnJf9pIV68QQFjsOWIkXoVGYi/OO9zgtlDKZeEBfRbeiT4IU+xRfwVePD+H6WV/zQAAAABJRU5ErkJggg==") else {
      fatalError("Cannot parse URL")
    }

    XCTAssertNotNil(decoder.decode(mockUri))
  }

  func testParseDataUri_wrongFormat() throws {
    guard let mockUri = URL(string: "data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACPSURBVHgB7ZbbCYAwDEVvxEHcREdzlI7gCHUDN9AtfEJM0S9BUWwrSA5cWujHgdA2oWFcWhAyxKGjYVpYNpaZawSEiHJZCjhhP84lAuMczpUgMir8Tii32PBGiRdoSVWoQhX+UJjiOfnJf9pIV68QQFjsOWIkXoVGYi/OO9zgtlDKZeEBfRbeiT4IU+xRfwVePD+H6WV/zQAAAABJRU5ErkJggg==") else {
      fatalError("Cannot parse URL")
    }

    XCTAssertNil(decoder.decode(mockUri))
  }

  func testParseDataUri_emptyBase64() throws {
    guard let mockUri = URL(string: "data:image/gif;base64,") else {
      fatalError("Cannot parse URL")
    }

    XCTAssertNil(decoder.decode(mockUri))
  }

  func testParseDataUri_validFormat_emptyBase64() throws {
    guard let mockUri = URL(string: "data:image/jpeg;base64,") else {
      fatalError("Cannot parse URL")
    }

    XCTAssertNil(decoder.decode(mockUri))
  }

  func testParseUrlUri_success() throws {
    guard let mockUri = URL(string: "https://image.noelshack.com/fichiers/2024/07/1/1707731598-flag.png") else {
      fatalError("Cannot parse URL")
    }

    XCTAssertNotNil(decoder.decode(mockUri))
  }

  func testParseUrlUri_failure() throws {
    guard let mockUri = URL(string: "file://image.noelshack.com/fichiers/2024/07/1/1707731598-flag.png") else {
      fatalError("Cannot parse URL")
    }

    XCTAssertNil(decoder.decode(mockUri))
  }

  func testParseDataUriString_success() throws {
    let mockString = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACPSURBVHgB7ZbbCYAwDEVvxEHcREdzlI7gCHUDN9AtfEJM0S9BUWwrSA5cWujHgdA2oWFcWhAyxKGjYVpYNpaZawSEiHJZCjhhP84lAuMczpUgMir8Tii32PBGiRdoSVWoQhX+UJjiOfnJf9pIV68QQFjsOWIkXoVGYi/OO9zgtlDKZeEBfRbeiT4IU+xRfwVePD+H6WV/zQAAAABJRU5ErkJggg=="

    XCTAssertNotNil(decoder.decode(from: mockString))
  }

  func testParseDataUriString_wrongFormat() throws {
    let mockString = "data:image/gif;base64,iVBORw0KGgoAAAANSUhEUgAAABwAAAAcCAYAAAByDd+UAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAACPSURBVHgB7ZbbCYAwDEVvxEHcREdzlI7gCHUDN9AtfEJM0S9BUWwrSA5cWujHgdA2oWFcWhAyxKGjYVpYNpaZawSEiHJZCjhhP84lAuMczpUgMir8Tii32PBGiRdoSVWoQhX+UJjiOfnJf9pIV68QQFjsOWIkXoVGYi/OO9zgtlDKZeEBfRbeiT4IU+xRfwVePD+H6WV/zQAAAABJRU5ErkJggg=="

    XCTAssertNil(decoder.decode(from: mockString))
  }

  // MARK: Private

  private var decoder = CredentialDisplayLogoURIDecoder()
}
