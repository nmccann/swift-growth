import Foundation

/// Maps the oscillator sine wave to sensor range 0.0..1.0;
/// cycles starts at simStep 0 for everybody.
struct OscillatorSensor: Sensor {
  func get(for individual: Indiv, simStep: Int, on grid: Grid, with parameters: Params) -> Double {

    let phase = Double(simStep % individual.oscPeriod) / Double(individual.oscPeriod) // 0.0..1.0
    var factor = -cos(phase * 2.0 * Double.pi)
    assert(factor >= -1.0 && factor <= 1.0)
    factor += 1.0 // convert to 0.0..2.0
    factor /= 2.0 // convert to 0.0..1.0
    // Clip any round-off error
    return factor.clamped(to: 0...1)
  }
}
