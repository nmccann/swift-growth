import Foundation

struct MoveXAction: Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Parameters) {
    result.movePotential.x += level
  }
}
