import Foundation

/// Survivors are all those on the right quarter of the arena
struct RightQuarterChallenge: Challenge {
  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    individual.loc.x > grid.size.x / 2 + grid.size.x / 4 ? .pass(1) : .fail(0)
  }
}

extension Challenge where Self == RightQuarterChallenge {
  static func rightQuarter() -> Self { .init() }
}
