import Foundation

struct Dir: Equatable {
  let dir9: Compass

  init(dir: Compass = .center) {
    dir9 = dir
  }

  static func random8() -> Dir {
    Dir(dir: .allCases.randomElement() ?? .N)
  }

  func asInt() -> Int {
    dir9.rawValue
  }

  func asNormalizedCoord() -> Coord {
    let d = dir9.rawValue
    return .init(x: (d % 3) - 1, y: (d / 3) - 1)
  }

  func asNormalizedPolar() -> Polar {
    .init(mag: 1, dir: dir9)
  }

  func rotate(n: Int = 0) -> Dir {
    let rotateRight = [3, 0, 1, 6, 4, 2, 7, 8, 5]
    let rotateLeft = [1, 2, 5, 0, 4, 8, 3, 6, 7]
    var n9 = dir9.rawValue
    var n = n

    if n < 0 {
      while n < 0 {
        n9 = rotateLeft[n9]
        n += 1
      }
    } else if n > 0 {
      while n > 0 {
        n9 = rotateRight[n9]
        n -= 1
      }
    }

    return Dir(dir: .init(rawValue: n9) ?? .N)
  }

  func rotate90DegCW() -> Dir {
    rotate(n: 2)
  }

  func rotate90DegCCW() -> Dir {
    rotate(n: -2)
  }

  func rotate180Deg() -> Dir {
    rotate(n: 4)
  }

  static func ==(lhs: Dir, rhs: Compass) -> Bool {
    lhs.dir9 == rhs
  }
}
