import Foundation

/// Everybody survives and are candidate parents, but scored by how far
/// they migrated from their birth location.
struct MigrateDistanceChallenge: Challenge {
  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    let distance = Double((individual.loc - individual.birthLoc).length)
    return .pass(distance / Double(max(grid.size.x, grid.size.y)))
  }
}

extension Challenge where Self == MigrateDistanceChallenge {
  static func migrateDistance() -> Self { .init() }
}
