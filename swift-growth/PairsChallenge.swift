import Foundation

/// Survivors are those not touching a border and with exactly one neighbor which has no other neighbor
struct PairsChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    guard !isOnEdge(indiv: individual, of: grid) else {
      return (false, 0)
    }

    var count = 0
    //TODO: Simplify - similar to the visitNeighborhood logic, but checks one neighborhood then another, and
    //only operates on integers
    for x in ((individual.loc.x - 1)..<(individual.loc.x + 1)) {
      for y in ((individual.loc.y - 1)..<(individual.loc.y + 1)) {
        let tloc = Coord(x: x, y: y)
        if tloc != individual.loc && grid.isInBounds(loc: tloc) && grid.isOccupiedAt(loc: tloc) {
          count += 1
          if count == 1 {
            for x1 in ((tloc.x - 1)..<(tloc.x + 1)) {
              for y1 in ((tloc.y - 1)..<(tloc.y + 1)) {
                let tloc1 = Coord(x: x1, y: y1)
                if tloc1 != tloc && tloc1 != individual.loc && grid.isInBounds(loc: tloc1) && grid.isOccupiedAt(loc: tloc1) {
                  return (false, 0)
                }
              }
            }
          } else {
            return (false, 0)
          }
        }
      }
    }

    return count == 1 ? (true, 1) : (false, 0)
  }
}

extension Challenge where Self == PairsChallenge {
  static func pairs() -> Self { .init() }
}
