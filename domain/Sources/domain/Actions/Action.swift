import Foundation

let ACTION_MIN: Double = 0.0
let ACTION_MAX: Double = 1.0
let ACTION_RANGE = ACTION_MAX - ACTION_MIN

public protocol Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Parameters)
}
