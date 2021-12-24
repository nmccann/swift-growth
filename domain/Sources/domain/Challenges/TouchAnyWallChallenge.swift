import Foundation

/// Survivors are those touching any wall at the end of the generation
struct TouchAnyWallChallenge: Challenge {
  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult {
    // If the individual is touching any wall, we set its challengeFlag to true.
    // At the end of the generation, all those with the flag true will reproduce.
    guard isOnEdge(indiv: result.indiv, of: grid) else {
      return result
    }

    var result = result
    result.indiv.challengeBits = 1
    return result
  }

  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    individual.challengeBits == 0 ? (false, 0) : (true, 1)
  }
}

extension Challenge where Self == TouchAnyWallChallenge {
  static func touchAnyWall() -> Self { .init() }
}
