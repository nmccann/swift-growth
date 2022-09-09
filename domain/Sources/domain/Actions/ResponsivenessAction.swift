import Foundation

/// Responsiveness action - convert neuron action level from arbitrary float range
/// to the range 0.0..1.0. If this action neuron is enabled but not driven, will
/// default to mid-level 0.5.
struct ResponsivenessAction: Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Parameters) {
    result.individual.responsiveness = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
  }
}
