import Foundation

/// This challenge is partially handled in endOfSimStep(), where individuals
/// that are touching a wall are flagged in their Indiv record. They are
/// allowed to continue living. Here at the end of the generation, any that
/// never touch a wall will die. All that touched a wall at any time during
/// their life will become parents.
struct AgainstAnyWallChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    isOnEdge(indiv: individual, of: grid) ? .pass(1) : .fail(0)
  }
}

private extension AgainstAnyWallChallenge {
  func isOnEdge(indiv: Indiv, of grid: Grid) -> Bool {
    let onEdgeX = indiv.loc.x == 0 || indiv.loc.x == grid.size.x - 1
    let onEdgeY = indiv.loc.y == 0 || indiv.loc.y == grid.size.y - 1
    return onEdgeX || onEdgeY
  }
}

extension Challenge where Self == AgainstAnyWallChallenge {
  static func againstAnyWall() -> Self { .init() }
}
