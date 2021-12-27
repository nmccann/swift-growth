import Foundation

struct MoveYAction: Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Params) {
    result.movePotential.y += level
  }
}
