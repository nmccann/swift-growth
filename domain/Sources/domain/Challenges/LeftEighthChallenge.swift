import Foundation

/// Survivors are all those on the left eighth of the arena
struct LeftEighthChallenge: Challenge {
  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    individual.loc.x < grid.size.width / 8 ? .pass(1) : .fail(0)
  }
}

extension Challenge where Self == LeftEighthChallenge {
  static func leftEighth() -> Self { .init() }
}
