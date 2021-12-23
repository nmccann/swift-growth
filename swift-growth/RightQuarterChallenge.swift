import Foundation

/// Survivors are all those on the right quarter of the arena
struct RightQuarterChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    individual.loc.x > grid.size.x / 2 + grid.size.x / 4 ? (true, 1) : (false, 0)
  }
}

extension Challenge where Self == RightQuarterChallenge {
  static func rightQuarter() -> Self { .init() }
}
