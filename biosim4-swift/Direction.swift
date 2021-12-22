import Foundation

enum Direction: CaseIterable {
  case southWest, south, southEast, west, east, northWest, north, northEast

  static func random() -> Direction {
    .allCases.randomElement() ?? .north
  }

  func asNormalizedCoord() -> Coord {
    guard let coord = Self.normalizedMapping[self] else {
      fatalError("Expected to find a normalized coord for \(self)")
    }

    return coord
  }

  func asNormalizedPolar() -> Polar {
    .init(magnitude: 1, direction: self)
  }

  func rotate(n: Int) -> Direction {
    guard n != 0 else {
      return self
    }

    let mapping = n < 0 ? Self.counterClockwiseMapping : Self.clockwiseMapping
    let count = abs(n) % Self.totalDirections

    return (0..<count).reduce(into: self) { result, _ in result = mapping[result] ?? result }
  }

  func rotate90DegreesClockwise() -> Direction {
    rotate(n: 2)
  }

  func rotate90DegreesCounterClockwise() -> Direction {
    rotate(n: -2)
  }

  func rotate180Degrees() -> Direction {
    rotate(n: 4)
  }
}

private extension Direction {
  static let clockwiseMapping: [Direction: Direction] = [.southWest: .west,
                                                         .south: .southWest,
                                                         .southEast: .south,
                                                         .west: .northWest,
                                                         .east: .southEast,
                                                         .northWest: .north,
                                                         .north: .northEast,
                                                         .northEast: .east]

  static let counterClockwiseMapping: [Direction: Direction] = clockwiseMapping.reduce(into: [:]) { $0[$1.value] = $1.key }

  static let normalizedMapping: [Direction: Coord] = [.southWest: .init(x: -1, y: -1),
                                                      .south: .init(x: 0, y: -1),
                                                      .southEast: .init(x: 1, y: -1),
                                                      .west: .init(x: -1, y: 0),
                                                      .east: .init(x: 1, y: 0),
                                                      .northWest: .init(x: -1, y: 1),
                                                      .north: .init(x: 0, y: 1),
                                                      .northEast: .init(x: 1, y: 1)]

  static let totalDirections = allCases.count
}
