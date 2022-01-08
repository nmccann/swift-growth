import Foundation

/// Converts age (units of simSteps compared to life expectancy)
/// linearly to normalized sensor range 0.0..1.0
struct AgeSensor: Sensor {
  func get(for individual: Individual, on world: World) -> Double {
    (Double(individual.age) / Double(world.parameters.stepsPerGeneration)).clamped(to: 0...1)
  }
}
