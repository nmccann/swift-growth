import Foundation

public protocol Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Params)
}
