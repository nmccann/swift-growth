import Foundation

/// This challenge is handled in endOfSimStep(), where individuals may die
/// at the end of any sim step. There is nothing else to do here at the
/// end of a generation. All remaining alive become parents.
struct RadioactiveWallsChallenge: Challenge {
  let flipAtStep: Int

  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult {
    // During the first half of the generation, the west wall is radioactive,
    // where X == 0. In the last half of the generation, the east wall is
    // radioactive, where X = the area width - 1. There's an exponential
    // falloff of the danger, falling off to zero at the arena half line.
    let radioactiveX = step < flipAtStep ? 0 : grid.size.width - 1
    let distanceFromRadioactiveWall = Double(abs(result.individual.loc.x - radioactiveX))

    guard distanceFromRadioactiveWall < Double(grid.size.width / 2) else {
      return result
    }

    let chanceOfDeath = 1.0 / distanceFromRadioactiveWall

    guard .random(in: 0...1) < chanceOfDeath else {
      return result
    }

    var result = result
    result.killed.append(result.individual)
    return result
  }

  func test(_ individual: Individual, on grid: Grid) -> ChallengeResult {
    .pass(1)
  }
}

extension Challenge where Self == RadioactiveWallsChallenge {
  static func radioactiveWalls(flipAtStep: Int) -> Self {
    .init(flipAtStep: flipAtStep)
  }
}
