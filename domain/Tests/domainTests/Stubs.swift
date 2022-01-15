import Foundation
@testable import domain

extension Individual {
  static func stub(index: Int = 0,
                   loc: Coord = .init(x: 0, y: 0),
                   genome: Genome = makeRandomGenome(10...10),
                   probeDistance: (short: Int, long: Int) = (short: 3, long: 16),
                   responsiveness: Double = 0.5,
                   maxNumberOfNeurons: Int = 10,
                   actions: Int = 17, sensors: Int = 20) -> Self {
    .init(index: index,
          loc: loc,
          genome: genome,
          probeDistance: probeDistance,
          responsiveness: responsiveness,
          maxNumberOfNeurons: maxNumberOfNeurons,
          actions: actions,
          sensors: sensors)
  }
}

extension Params {
  static func stub(population: Int = Params.defaults.population,
                   stepsPerGeneration: Int = Params.defaults.stepsPerGeneration,
                   maxGenerations: Int = Params.defaults.maxGenerations,
                   signalLayers: Int = Params.defaults.signalLayers,
                   genomeMaxLength: Int = Params.defaults.genomeMaxLength,
                   maxNumberNeurons: Int = Params.defaults.maxNumberNeurons,
                   pointMutationRate: Double = Params.defaults.pointMutationRate,
                   geneInsertionDeletionRate: Double = Params.defaults.geneInsertionDeletionRate,
                   deletionRatio: Double = Params.defaults.deletionRatio,
                   sexualReproduction: Bool = Params.defaults.sexualReproduction,
                   chooseParentsByFitness: Bool = Params.defaults.chooseParentsByFitness,
                   populationSensorRadius: Double = Params.defaults.populationSensorRadius,
                   signalSensorRadius: Int = Params.defaults.signalSensorRadius,
                   responsiveness: (value: Double, kFactor: Int) = Params.defaults.responsiveness,
                   initialResponsiveness: Double = Params.defaults.initialResponsiveness,
                   probeDistance: (short: Int, long: Int) = Params.defaults.probeDistance,
                   genomeComparisonMethod: GenomeComparison = Params.defaults.genomeComparisonMethod,
                   challenge: Challenge? = Params.defaults.challenge,
                   barrierType: BarrierType? = Params.defaults.barrierType,
                   replaceBarrier: (BarrierType, Int)? = Params.defaults.replaceBarrier,
                   size: (x: Int, y: Int) = Params.defaults.size,
                   genomeInitialLength: ClosedRange<Int> = Params.defaults.genomeInitialLength,
                   sensors: [Sensor] = Params.defaults.sensors,
                   actions: [Action] = Params.defaults.actions) -> Self {
    .init(population: population,
          stepsPerGeneration: stepsPerGeneration,
          maxGenerations: maxGenerations,
          signalLayers: signalLayers,
          genomeMaxLength: genomeMaxLength,
          maxNumberNeurons: maxNumberNeurons,
          pointMutationRate: pointMutationRate,
          geneInsertionDeletionRate: geneInsertionDeletionRate,
          deletionRatio: deletionRatio,
          sexualReproduction: sexualReproduction,
          chooseParentsByFitness: chooseParentsByFitness,
          populationSensorRadius: populationSensorRadius,
          signalSensorRadius: signalSensorRadius,
          responsiveness: responsiveness,
          initialResponsiveness: initialResponsiveness,
          probeDistance: probeDistance,
          genomeComparisonMethod: genomeComparisonMethod,
          challenge: challenge,
          barrierType: barrierType,
          replaceBarrier: replaceBarrier,
          size: size,
          genomeInitialLength: genomeInitialLength,
          sensors: sensors,
          actions: actions)
  }
}
