import Foundation

/// Everybody survives and are candidate parents, but scored by how far
/// they migrated from their birth location.
struct MigrateDistanceChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    let distance = Double((individual.loc - individual.birthLoc).length)
    return (true, distance / Double(max(grid.size.x, grid.size.y)))
  }
}

extension Challenge where Self == MigrateDistanceChallenge {
  static func migrateDistance() -> Self { .init() }
}
