import Foundation

/// Set longProbeDistance - convert action level to 1..max.
/// If this action neuron is enabled but not driven, will default to
/// mid-level period of 16 simSteps.
struct LongProbeDistanceAction: Action {
  let max: Int

  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Parameters) {
      var level = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
      level = 1 + level * Double(max - 1)
      result.individual.probeDistance.long = Int(UInt(level))
  }
}
