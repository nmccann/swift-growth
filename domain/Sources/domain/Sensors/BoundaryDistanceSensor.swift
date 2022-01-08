import Foundation

// Maps current location along axis of 0...grid axis dimension-1 to sensor range 0.0..1.0
struct BoundaryDistanceSensor: Sensor {
  enum Axis {
    case x, y, both
  }
  
  let axis: Axis
  
  func get(for individual: Individual, on world: World) -> Double {
    let grid = world.grid

    switch axis {
    case .x:
      // Measures the distance to nearest boundary in the east-west axis,
      // max distance is half the grid width; scaled to sensor range 0.0..1.0.
      let minDistanceX = min(individual.loc.x, (grid.size.x - individual.loc.x) - 1)
      return Double(minDistanceX) / (Double(grid.size.x) / 2.0)
    case .y:
      // Measures the distance to nearest boundary in the south-north axis,
      // max distance is half the grid height; scaled to sensor range 0.0..1.0.
      let minDistanceY = min(individual.loc.y, (grid.size.y - individual.loc.y) - 1)
      return Double(minDistanceY) / (Double(grid.size.y) / 2.0)
    case .both:
      // Finds closest boundary, compares that to the max possible dist
      // to a boundary from the center, and converts that linearly to the
      // sensor range 0.0..1.0
      let distanceX = min(individual.loc.x, (grid.size.x - individual.loc.x) - 1)
      let distanceY = min(individual.loc.y, (grid.size.y - individual.loc.y) - 1)
      let closest = min(distanceX, distanceY)
      let maxPossible = max(grid.size.x / 2 - 1, grid.size.y / 2 - 1)
      return Double(closest) / Double(maxPossible)
    }
  }
}
