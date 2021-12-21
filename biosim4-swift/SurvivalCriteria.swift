import Foundation

func passedSurvivalCriterion(indiv: inout Indiv, challenge: Challenge?) -> (Bool, Double) {
  guard indiv.alive else {
    return (false, 0)
  }

  switch challenge {
  case .circle:
    // Survivors are those inside the circular area defined by
    // safeCenter and radius
    let safeCenter = Coord(x: Int(Double(p.sizeX) / 4.0), y: Int(Double(p.sizeY) / 4.0))
    let radius = Double(p.sizeX) / 4.0
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)
    return distance <= radius ? (true, (radius - distance) / radius) : (false, 0)
  case .rightHalf:
    // Survivors are all those on the right side of the arena
    return indiv.loc.x > p.sizeX / 2 ? (true, 1) : (false, 0)
  case .rightQuarter:
    // Survivors are all those on the right quarter of the arena
    return indiv.loc.x > p.sizeX / 2 + p.sizeX / 4 ? (true, 1) : (false, 0)
  case .leftEighth:
    // Survivors are all those on the left eighth of the arena
    return indiv.loc.x < p.sizeX / 8 ? (true, 1) : (false, 0)
  case .string:
    // Survivors are those not touching the border and with exactly the number
    // of neighbors defined by neighbors and radius, where neighbors includes self
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
    // Survivors are those within the specified radius of the center. The score
    // is linearly weighted by distance from the center.
    let safeCenter = Coord(x: Int(Double(p.sizeX) / 2.0), y: Int(Double(p.sizeY) / 2.0))
    let radius = Double(p.sizeX) / 3.0
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)
    return distance <= radius ? (true, (radius - distance) / radius) : (false, 0)
  case .centerUnweighted:
    // Survivors are those within the specified radius of the center
    let safeCenter = Coord(x: Int(Double(p.sizeX) / 2.0), y: Int(Double(p.sizeY) / 2.0))
    let radius = Double(p.sizeX) / 3.0
    let offset = safeCenter - indiv.loc
    let distance = Double(offset.length)
    return distance <= radius ? (true, 1) : (false, 0)
  case .centerSparse:
    // Survivors are those within the specified outer radius of the center and with
    // the specified number of neighbors in the specified inner radius.
    // The score is not weighted by distance from the center.
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
    // Survivors are those within the specified radius of any corner.
    // Assumes square arena.
    return corner(indiv: indiv) { pass, _, _ in
      pass ? 1 : 0
    }
  case .cornerWeighted:
    // Survivors are those within the specified radius of any corner. The score
    // is linearly weighted by distance from the corner point.
    // Assumes square arena.
    return corner(indiv: indiv) { pass, radius, distance in
      pass ? (radius - distance) / radius : 0
    }
  case .radioactiveWalls:
    // This challenge is handled in endOfSimStep(), where individuals may die
    // at the end of any sim step. There is nothing else to do here at the
    // end of a generation. All remaining alive become parents.
    return (true, 1)
  case .againstAnyWall:
    // Survivors are those touching any wall at the end of the generation
    let onEdgeX = indiv.loc.x == 0 || indiv.loc.x == p.sizeX - 1
    let onEdgeY = indiv.loc.y == 0 || indiv.loc.y == p.sizeY - 1
    let onEdge = onEdgeX || onEdgeY

    return onEdge ? (true, 1) : (false, 0)
  case .touchAnyWall:
    // This challenge is partially handled in endOfSimStep(), where individuals
    // that are touching a wall are flagged in their Indiv record. They are
    // allowed to continue living. Here at the end of the generation, any that
    // never touch a wall will die. All that touched a wall at any time during
    // their life will become parents.
    return indiv.challengeBits == 0 ? (false, 0) : (true, 1)
  case .migrateDistance:
    // Everybody survives and are candidate parents, but scored by how far
    // they migrated from their birth location.
    let distance = (indiv.loc - indiv.birthLoc).floatingLength
    return (true, distance / Double(max(p.sizeX, p.sizeY)))
  case .eastWestEighths:
    // Survivors are all those on the left or right eighths of the arena
    return indiv.loc.x < p.sizeX / 8 || indiv.loc.x >= (p.sizeX - p.sizeX / 8) ? (true, 1) : (false, 0)
  case .nearBarrier:
    // Survivors are those within radius of any barrier center. Weighted by distance.
    //TODO
    return(false, 0)
  case .pairs:
    // Survivors are those not touching a border and with exactly one neighbor which has no other neighbor
    //TODO
    return (false, 0)
  case .locationSequence:
    // Survivors are those that contacted one or more specified locations in a sequence,
    // ranked by the number of locations contacted. There will be a bit set in their
    // challengeBits member for each location contacted.
    //TODO
    return (false, 0)
  case .altruismSacrifice:
    // Survivors are all those within the specified radius of the NE corner
    //TODO
    return (false, 0)
  case .altruism:
    // Survivors are those inside the circular area defined by
    // safeCenter and radius
    //TODO
    return (false, 0)
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
private func corner(indiv: Indiv, scoring: (_ pass: Bool, _ radius: Double, _ distance: Double) -> Double) -> (Bool, Double) {
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
