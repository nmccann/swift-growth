import Foundation

// Maps current location along axis of 0...grid axis dimension-1 to sensor range 0.0..1.0
struct LocationSensor: Sensor {
  enum Axis {
    case x, y
  }

  let axis: Axis

  func get(for individual: Individual, on world: World) -> Double {
    switch axis {
    case .x: return Double(individual.loc.x) / Double(world.grid.size.x - 1)
    case .y: return Double(individual.loc.y) / Double(world.grid.size.y - 1)
    }
  }
}
