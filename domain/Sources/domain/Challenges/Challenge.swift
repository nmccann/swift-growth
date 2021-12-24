import Foundation

public protocol Challenge {
  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult
}

extension Challenge {
  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult {
    return result
  }
}

func isOnEdge(indiv: Indiv, of grid: Grid) -> Bool {
  let onEdgeX = indiv.loc.x == 0 || indiv.loc.x == grid.size.x - 1
  let onEdgeY = indiv.loc.y == 0 || indiv.loc.y == grid.size.y - 1
  return onEdgeX || onEdgeY
}

public struct ChallengeResult {
  let didPass: Bool
  let score: Double

  static func pass(_ score: Double) -> ChallengeResult {
    .init(didPass: true, score: score)
  }

  static func fail(_ score: Double) -> ChallengeResult {
    .init(didPass: false, score: score)
  }
}
