import Foundation

public struct Barrier: Equatable {
  public let coord: Coord
  public let isManual: Bool

  public init(coord: Coord, isManual: Bool) {
    self.coord = coord
    self.isManual = isManual
  }
}
