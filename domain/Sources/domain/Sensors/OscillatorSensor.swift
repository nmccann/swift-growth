import Foundation

// Maps current location along axis of 0...grid axis dimension-1 to sensor range 0.0..1.0
struct OscillatorSensor: Sensor {
  func get(for individual: Indiv, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    var sensorVal = 0.0

    // Maps the oscillator sine wave to sensor range 0.0..1.0;
    // cycles starts at simStep 0 for everybody.
    let phase = Double(simStep % individual.oscPeriod) / Double(individual.oscPeriod) // 0.0..1.0
    var factor = -cos(phase * 2.0 * Double.pi)
    assert(factor >= -1.0 && factor <= 1.0)
    factor += 1.0 // convert to 0.0..2.0
    factor /= 2.0 // convert to 0.0..1.0
    // Clip any round-off error
    sensorVal = factor;
    return min(1.0, max(0.0, sensorVal))
  }
}
