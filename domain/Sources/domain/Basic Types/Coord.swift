import Foundation

public struct Coord: Equatable, Hashable {
  public let x: Int
  public let y: Int

  public init(x: Int, y: Int) {
    self.x = x
    self.y = y
  }

  public static var zero: Coord {
    .init(x: 0, y: 0)
  }

  public var isNormalized: Bool {
    x >= -1 && x <= 1 && y >= -1 && y <= 1
  }

  public var length: Int {
    .init(floatingLength)
  }

  public func normalize() -> Coord {
    asDir()?.asNormalizedCoord() ?? .zero
  }

  public func asDir() -> Direction? {
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

  public func asPolar() -> Polar {
    .init(magnitude: length, direction: asDir())
  }

  public static func +(lhs: Coord, rhs: Coord) -> Coord {
    .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
  }

  public static func -(lhs: Coord, rhs: Coord) -> Coord {
    .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
  }

  public static func *(lhs: Coord, rhs: Int) -> Coord {
    .init(x: lhs.x * rhs, y: lhs.y * rhs)
  }

  public static func +(lhs: Coord, rhs: Direction) -> Coord {
    lhs + rhs.asNormalizedCoord()
  }

  public static func -(lhs: Coord, rhs: Direction) -> Coord {
    lhs - rhs.asNormalizedCoord()
  }
}

private extension Coord {
  var floatingLength: Double {
    sqrt(pow(Double(x), 2) + pow(Double(y), 2))
  }
}
