import Foundation

/// Survivors are those touching any wall at the end of the generation
struct TouchAnyWallChallenge: Challenge {
  private let againstAnyWall = AgainstAnyWallChallenge()

  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult {
    // If the individual is touching any wall, we set its challengeFlag to true.
    // At the end of the generation, all those with the flag true will reproduce.
    guard againstAnyWall.test(result.individual, on: grid).didPass else {
      return result
    }

    var result = result
    result.individual.challengeBits = 1
    return result
  }

  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    individual.challengeBits == 0 ? .fail(0) : .pass(1)
  }
}

extension Challenge where Self == TouchAnyWallChallenge {
  static func touchAnyWall() -> Self { .init() }
}
