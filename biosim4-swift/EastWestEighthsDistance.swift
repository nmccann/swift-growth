import Foundation

/// Survivors are all those on the left or right eighths of the arena
struct EastWestEighthsChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    individual.loc.x < grid.size.x / 8 || individual.loc.x >= (grid.size.x - grid.size.x / 8) ? (true, 1) : (false, 0)
  }
}

extension Challenge where Self == EastWestEighthsChallenge {
  static func eastWestEighths() -> Self { .init() }
}
