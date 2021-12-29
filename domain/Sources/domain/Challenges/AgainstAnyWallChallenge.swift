import Foundation

/// This challenge is partially handled in endOfSimStep(), where individuals
/// that are touching a wall are flagged in their Indiv record. They are
/// allowed to continue living. Here at the end of the generation, any that
/// never touch a wall will die. All that touched a wall at any time during
/// their life will become parents.
struct AgainstAnyWallChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    grid.isBorder(loc: individual.loc) ? .pass(1) : .fail(0)
  }
}

extension Challenge where Self == AgainstAnyWallChallenge {
  static func againstAnyWall() -> Self { .init() }
}
