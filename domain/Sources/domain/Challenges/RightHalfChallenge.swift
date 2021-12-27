import Foundation

/// Survivors are all those on the right side of the arena
struct RightHalfChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    individual.loc.x > grid.size.x / 2 ? .pass(1) : .fail(0)
  }
}

extension Challenge where Self == RightHalfChallenge {
  static func rightHalf() -> Self { .init() }
}