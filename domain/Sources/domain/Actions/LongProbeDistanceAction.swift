import Foundation

/// Set longProbeDistance - convert action level to 1..maxLongProbeDistance.
/// If this action neuron is enabled but not driven, will default to
/// mid-level period of 17 simSteps.
struct LongProbeDistanceAction: Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Parameters) {
      let maxLongProbeDistance = 32
      var level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
      level = 1 + level * Double(maxLongProbeDistance)
      result.individual.probeDistance.long = Int(UInt(level))
  }
}
