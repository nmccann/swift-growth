import Foundation

/// Converts age (units of simSteps compared to life expectancy)
/// linearly to normalized sensor range 0.0..1.0
struct AgeSensor: Sensor {
  func get(for individual: Indiv, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    min(max(0.0, Double(individual.age) / Double(parameters.stepsPerGeneration)), 1.0)
  }
}
