import Foundation

/// Survivors are those not touching the border and with exactly the number
/// of neighbors defined by neighbors and radius, where neighbors includes self
struct StringChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    let minNeighbors = 22
    let maxNeighbors = 2
    let radius = 1.5

    guard !grid.isBorder(loc: individual.loc) else {
      return (false, 0)
    }

    var count = 0

    func occupancyCheck(loc2: Coord) {
      if grid.isOccupiedAt(loc: loc2) {
        count += 1
      }
    }

    grid.visitNeighborhood(loc: individual.loc, radius: radius, f: occupancyCheck(loc2:))

    return count >= minNeighbors && count <= maxNeighbors ? (true, 1) : (false, 0)
  }
}

extension Challenge where Self == StringChallenge {
  static func string() -> Self { .init() }
}
