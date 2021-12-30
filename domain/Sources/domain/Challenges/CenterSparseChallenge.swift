import Foundation

/// Survivors are those within the specified outer radius of the center and with
/// the specified number of neighbors in the specified inner radius.
/// The score is not weighted by distance from the center.
struct CenterSparseChallenge: Challenge {
  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    let safeCenter = Coord(x: Int(Double(grid.size.x) / 2.0), y: Int(Double(grid.size.y) / 2.0))
    let outerRadius = Double(grid.size.x) / 4.0
    let innerRadius = 1.5
    let minNeighbors = 5 // includes self
    let maxNeighbors = 8
    let offset = safeCenter - individual.loc
    let distance = Double(offset.length)

    guard distance <= outerRadius else {
      return .fail(0)
    }

    var count = 0
    func occupancyCheck(loc2: Coord) {
      if grid.isOccupiedAt(loc: loc2) {
        count += 1
      }
    }

    grid.visitNeighborhood(loc: individual.loc, radius: innerRadius, f: occupancyCheck(loc2:))
    return count >= minNeighbors && count <= maxNeighbors ? .pass(1) : .fail(0)
  }
}

extension Challenge where Self == CenterSparseChallenge {
  static func centerSparse() -> Self { .init() }
}
