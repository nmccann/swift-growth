import Foundation

public protocol Challenge {
  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double)
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
