import Foundation

/// Returns a random value in the range 0.0..1.0.
struct RandomSensor: Sensor {
  func get(for individual: Individual, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    .random(in: 0...1)
  }
}
