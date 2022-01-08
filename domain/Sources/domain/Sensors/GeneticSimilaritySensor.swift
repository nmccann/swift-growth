import Foundation

/// Return minimum sensor value if nobody is alive in the forward adjacent location,
/// else returns a similarity match in the sensor range 0.0..1.0
struct GeneticSimilaritySensor: Sensor {
  func get(for individual: Individual, on world: World) -> Double {
    let otherLocation = individual.loc + individual.lastDirection;

    guard world.grid.isInBounds(loc: otherLocation), world.grid.isOccupiedAt(loc: otherLocation) else {
      return 0.0
    }

    guard case .occupied(by: let other) = world.grid[otherLocation], other.alive else {
      return 0.0
    }

    return world.parameters.genomeComparisonMethod.similarity(individual.genome, other.genome) // 0.0..1.0
  }
}

