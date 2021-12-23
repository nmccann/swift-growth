import Foundation


struct Coord: Equatable {
  let x: Int
  let y: Int

  static var zero: Coord {
    .init(x: 0, y: 0)
  }

  var isNormalized: Bool {
    x >= -1 && x <= 1 && y >= -1 && y <= 1
  }

  var length: Int {
    .init(floatingLength)
  }

  func normalize() -> Coord {
    asDir()?.asNormalizedCoord() ?? .zero
  }

  func asDir() -> Direction? {
    if x == 0 && y == 0 {
      return nil
    }

    let two_pi = Double.pi * 2
    var angle = atan2(Double(y), Double(x))

    if angle < 0 {
      angle = Double.pi + (Double.pi + angle)
    }

    angle += two_pi / 16.0 // offset by half a slice
    if angle > two_pi {
      angle -= two_pi
    }

    let slice = Int(angle / (two_pi/8.0)) // find which division it's in
    /*
     We have to convert slice values:

     3  2  1
     4     0
     5  6  7

     into Dir8Compass value:

     6  7  8
     3  4  5
     0  1  2
     */
    let mapping: [Direction] = [.east, .northEast, .north, .northWest, .west, .southWest, .south, .southEast]
    return mapping[slice]
  }

  func asPolar() -> Polar {
    .init(magnitude: length, direction: asDir())
  }

  // returns -1.0 (opposite directions) .. +1.0 (same direction)
  // returns 1.0 if either vector is (0,0)
  func raySameness(other: Coord) -> Double {
    let mag1 = floatingLength
    let mag2 = other.floatingLength

    if mag1 == 0.0 || mag2 == 0.0 {
      return 1 // anything is "same" as zero vector
    }

    let dot = Double(x * other.x + y * other.y)
    let cos = dot / (mag1 * mag2)

    //TODO: Don't print
    if cos >= -1.0001 && cos <= 1.0001 {
      print("Within valid range")
    } else {
      print("Outside valid range")
    }

    return min(max(cos, -1), 1)
  }

  // returns -1.0 (opposite directions) .. +1.0 (same direction)
  // returns 1.0 if self is (0,0)
  func raySameness(other: Direction) -> Double {
    raySameness(other: other.asNormalizedCoord())
  }

  static func +(lhs: Coord, rhs: Coord) -> Coord {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  static func -(lhs: Coord, rhs: Coord) -> Coord {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  static func *(lhs: Coord, rhs: Int) -> Coord {
    .init(x: lhs.x * rhs, y: lhs.y * rhs)
  }

  static func +(lhs: Coord, rhs: Direction) -> Coord {
    lhs + rhs.asNormalizedCoord()
  }

  static func -(lhs: Coord, rhs: Direction) -> Coord {
    lhs - rhs.asNormalizedCoord()
  }
}

private extension Coord {
  var floatingLength: Double {
    sqrt(pow(Double(x), 2) + pow(Double(y), 2))
  }
}