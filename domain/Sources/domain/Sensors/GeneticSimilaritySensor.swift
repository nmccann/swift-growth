import Foundation

/// Return minimum sensor value if nobody is alive in the forward adjacent location,
/// else returns a similarity match in the sensor range 0.0..1.0
struct GeneticSimilaritySensor: Sensor {
  func get(for individual: Indiv, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    let loc2 = individual.loc + individual.lastDirection;

    guard grid.isInBounds(loc: loc2) && grid.isOccupiedAt(loc: loc2) else {
      return 0.0
    }

    let indiv2 = peeps.getIndiv(loc: loc2)

    guard indiv2.alive else {
      return 0.0
    }

    return parameters.genomeComparisonMethod.similarity(individual.genome, indiv2.genome) // 0.0..1.0
  }
}

