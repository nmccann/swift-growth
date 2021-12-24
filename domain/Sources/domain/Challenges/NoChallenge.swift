import Foundation

/// All survivors pass
struct NoChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    return individual.alive ? .pass(1) : .fail(0)
  }
}
