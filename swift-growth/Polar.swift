import Foundation

struct Polar {
  let magnitude: Int
  let direction: Direction?

  func asCoord() -> Coord {
    guard let direction = direction else {
      return .init(x: 0, y: 0)
    }

    guard let slice = Self.radianSliceMapping[direction] else {
      fatalError("Expected to find a slice for \(direction)")
    }

    let radiansPerSlice = (Double.pi * 2) / 8
    let compassInRadians = Double(slice) * radiansPerSlice
    let x = Int(round(Double(magnitude) * cos(compassInRadians)))
    let y = Int(round(Double(magnitude) * sin(compassInRadians)))
    return .init(x: x, y: y)
  }
}

private extension Polar {
  static let radianSliceMapping: [Direction: Int] = [.southWest: 5,
                                                     .south: 6,
                                                     .southEast: 7,
                                                     .west: 4,
                                                     .east: 0,
                                                     .northWest: 3,
                                                     .north: 2,
                                                     .northEast: 1]
}
