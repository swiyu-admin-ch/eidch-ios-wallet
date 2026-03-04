import SwiftUI

// https://www.david-smith.org/blog/2023/02/22/design-notes-24/

extension UnitPoint {

  public init(angle: Angle) {
    let u = sin(angle.radians + .pi / 2)
    let v = cos(angle.radians + .pi / 2)

    let uSign = abs(u) / u
    let vSign = abs(v) / v

    if u * u >= v * v {
      self = UnitPoint(
        x: 0.5 + 0.5 * uSign,
        y: 0.5 + 0.5 * uSign * (v / u))
    } else {
      self = UnitPoint(
        x: 0.5 + 0.5 * vSign * (u / v),
        y: 0.5 + 0.5 * vSign)
    }
  }
}
