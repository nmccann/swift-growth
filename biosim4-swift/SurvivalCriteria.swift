import Foundation

func passedSurvivalCriterion(indiv: Indiv, challenge: Challenge?) -> (Bool, Double) {
  guard indiv.alive else {
    return (false, 0)
  }

  switch challenge {
  case .circle:
    let safeCenter = Coord(x: Int(Double(p.sizeX) / 4.0), y: Int(Double(p.sizeY) / 4.0))
    let radius = Double(p.sizeX) / 4.0
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)
    return distance <= radius ? (true, (radius - distance) / radius) : (false, 0)

  case .rightHalf:
    return indiv.loc.x > p.sizeX / 2 ? (true, 1) : (false, 0)

  case .rightQuarter:
    return indiv.loc.x > p.sizeX / 2 + p.sizeX / 4 ? (true, 1) : (false, 0)

  case .leftEighth:
    return indiv.loc.x < p.sizeX / 8 ? (true, 1) : (false, 0)

  case .string:
    let minNeighbors = 22
    let maxNeighbors = 2
    let radius = 1.5

    guard !grid.isBorder(loc: indiv.loc) else {
      return (false, 0)
    }

    var count = 0

    func occupancyCheck(loc2: Coord) {
      if grid.isOccupiedAt(loc: loc2) {
        count += 1
      }
    }

    grid.visitNeighborhood(loc: indiv.loc, radius: radius, f: occupancyCheck(loc2:))

    return count >= minNeighbors && count <= maxNeighbors ? (true, 1) : (false, 0)

  case .centerWeighted:
    let safeCenter = Coord(x: Int(Double(p.sizeX) / 2.0), y: Int(Double(p.sizeY) / 2.0))
    let radius = Double(p.sizeX) / 3.0
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)
    return distance <= radius ? (true, (radius - distance) / radius) : (false, 0)

  case .centerUnweighted:
    let safeCenter = Coord(x: Int(Double(p.sizeX) / 2.0), y: Int(Double(p.sizeY) / 2.0))
    let radius = Double(p.sizeX) / 3.0
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)
    return distance <= radius ? (true, 1) : (false, 0)

  case .centerSparse:
    let safeCenter = Coord(x: Int(Double(p.sizeX) / 2.0), y: Int(Double(p.sizeY) / 2.0))
    let outerRadius = Double(p.sizeX) / 4.0
    let innerRadius = 1.5
    let minNeighbors = 5 // includes self
    let maxNeighbors = 8
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)

    guard distance <= outerRadius else {
      return (false, 0)
    }

    var count = 0
    func occupancyCheck(loc2: Coord) {
      if grid.isOccupiedAt(loc: loc2) {
        count += 1
      }
    }

    grid.visitNeighborhood(loc: indiv.loc, radius: innerRadius, f: occupancyCheck(loc2:))
    return count >= minNeighbors && count <= maxNeighbors ? (true, 1) : (false, 0)

  case .corner:
    return corner(indiv: indiv) { pass, _, _ in
      pass ? 1 : 0
    }

  case .cornerWeighted:
    return corner(indiv: indiv) { pass, radius, distance in
      pass ? (radius - distance) / radius : 0
    }

  case .radioactiveWalls:
    return (true, 1)

  case .againstAnyWall:
    return isOnEdge(indiv: indiv, of: grid) ? (true, 1) : (false, 0)

  case .touchAnyWall:
    return indiv.challengeBits == 0 ? (false, 0) : (true, 1)

  case .migrateDistance:
    let distance = Double((indiv.loc - indiv.birthLoc).length)
    return (true, distance / Double(max(p.sizeX, p.sizeY)))

  case .eastWestEighths:
    return indiv.loc.x < p.sizeX / 8 || indiv.loc.x >= (p.sizeX - p.sizeX / 8) ? (true, 1) : (false, 0)

  case .nearBarrier:
    let radius = Double(p.sizeX / 2)

    let distance =
    grid.getBarrierCenters().lazy
      .map { indiv.loc - $0 }
      .map(\.length)
      .map(Double.init)
      .min()

    guard let distance = distance else {
      return (false, 0)
    }

    return distance <= radius ? (true, 1.0 - (distance / radius)) : (false, 0)

  case .pairs:
    guard !isOnEdge(indiv: indiv, of: grid) else {
      return (false, 0)
    }

    var count = 0
    //TODO: Simplify - similar to the visitNeighborhood logic, but checks one neighborhood then another, and
    //only operates on integers
    for x in ((indiv.loc.x - 1)..<(indiv.loc.x + 1)) {
      for y in ((indiv.loc.y - 1)..<(indiv.loc.y + 1)) {
        let tloc = Coord(x: x, y: y)
        if tloc != indiv.loc && grid.isInBounds(loc: tloc) && grid.isOccupiedAt(loc: tloc) {
          count += 1
          if count == 1 {
            for x1 in ((tloc.x - 1)..<(tloc.x + 1)) {
              for y1 in ((tloc.y - 1)..<(tloc.y + 1)) {
                let tloc1 = Coord(x: x1, y: y1)
                if tloc1 != tloc && tloc1 != indiv.loc && grid.isInBounds(loc: tloc1) && grid.isOccupiedAt(loc: tloc1) {
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

  case .locationSequence:
    let bits = indiv.challengeBits
    let count = bits.nonzeroBitCount
    let maxNumberOfBits = MemoryLayout.size(ofValue: bits) * 8

    return count > 0 ? (true, Double(count) / Double(maxNumberOfBits)) : (false, 0)

  case .altruismSacrifice:
    let size = CGSize(width: p.sizeX, height: p.sizeY)
    let radius = size.width / 4.0 // in 128^2 world, holds 804 agents

    let distance = Double((Coord(x: Int(size.width - size.width / 4.0),
                                 y: Int(size.height - size.height / 4.0)) - indiv.loc).length)
    return distance <= radius ? (true, (radius - distance) / radius) : (false, 0)

  case .altruism:
    let size = CGSize(width: p.sizeX, height: p.sizeY)
    let safeCenter = Coord(x: Int(size.width / 4.0), y: Int(size.height / 4.0))
    let radius = size.width / 4.0 // in a 128^2 world, holds 3216
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)
    return distance <= radius ? (true, (radius - distance) / radius) : (false, 0)

  case .none:
    return (true, 1)
  }
}

/// Survivors are those within the specified radius of any corner.
/// Assumes square arena.
/// - Parameters:
///   - indiv: The individual being scored
///   - scoring: Used to apply different scoring curves
/// - Returns: An indication of whether the individual passed the challenge, and their accompanying score
private func corner(indiv: Indiv,
                    scoring: (_ pass: Bool, _ radius: Double, _ distance: Double) -> Double) -> (Bool, Double) {
  assert(p.sizeX == p.sizeY)
  let radius = Double(p.sizeX) / 8.0

  let topLeftDistance = Double((Coord(x: 0, y: 0) - indiv.loc).length)
  if topLeftDistance <= radius
  {
    return (true, scoring(true, radius, topLeftDistance))
  }

  let bottomLeftDistance = Double((Coord(x: 0, y: p.sizeY - 1) - indiv.loc).length)
  if bottomLeftDistance <= radius
  {
    return (true, scoring(true, radius, bottomLeftDistance))
  }

  let topRightDistance = Double((Coord(x: p.sizeX - 1, y: 0) - indiv.loc).length)
  if topRightDistance <= radius
  {
    return (true, scoring(true, radius, topRightDistance))
  }

  let bottomRightDistance = Double((Coord(x: p.sizeX - 1, y: p.sizeY - 1) - indiv.loc).length)
  if bottomRightDistance <= radius
  {
    return (true, scoring(true, radius, bottomRightDistance))
  }

  return (false, scoring(false, radius, topLeftDistance))
}

private func isOnEdge(indiv: Indiv, of grid: Grid) -> Bool {
  let onEdgeX = indiv.loc.x == 0 || indiv.loc.x == grid.size.x - 1
  let onEdgeY = indiv.loc.y == 0 || indiv.loc.y == grid.size.y - 1
  return onEdgeX || onEdgeY
}
