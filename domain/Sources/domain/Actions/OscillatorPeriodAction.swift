import Foundation

/// Oscillator period action - convert action level nonlinearly to
/// 2...4*parameters.stepsPerGeneration. If this action neuron is enabled but not driven,
/// will default to 1.5 + e^(3.5) = a period of 35 simSteps.
struct OscillatorPeriodAction: Action {
  func apply(to result: inout ActionResult, level: Double, on grid: Grid, with parameters: Params) {
    let newPeriodf01 = (tanh(level) + 1.0) / 2.0 // convert to 0.0..1.0
    let newPeriod = 1 + Int(1.5 + exp(7.0 * newPeriodf01))
    result.indiv.oscPeriod = newPeriod.clamped(to: 2...(parameters.stepsPerGeneration*4))
  }
}
