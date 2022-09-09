import Foundation

public struct World {
  public var grid: Grid
  public var signals: Signals
  public var parameters: Params
  public var generation = 0
  public var simStep = 0
  public var survivalPercentage: Double

  public init(parameters: Params, survivalPercentage: Double = 0.0, fill: (inout Grid, Params) -> Void = { _, _ in }) {
    /********************************************************************************
     Start of simulator

     All the agents are randomly placed with random genomes at the start. The outer
     loop is generation, the inner loop is simStep. There is a fixed number of
     simSteps in each generation. Agents can die at any simStep and their corpses
     remain until the end of the generation. At the end of the generation, the
     dead corpses are removed, the survivors reproduce and then die. The newborns
     are placed at random locations, signals (pheromones) are updated, simStep is
     reset to 0, and a new generation proceeds.

     The paramManager manages all the simulator parameters. It starts with defaults,
     then keeps them updated as the config file (biosim4.ini) changes.

     The main simulator-wide data structures are:
     grid - where the agents live (identified by their non-zero index). 0 means empty.
     signals - multiple layers overlay the grid, hold pheromones

     The important simulator-wide variables are:
     generation - starts at 0, then increments every time the agents die and reproduce.
     simStep - reset to 0 at the start of each generation; fixed number per generation.
     randomUint - global random number generator

     The threads are:
     main thread - simulator
     simStepOneIndividual() - child threads created by the main simulator thread
     imageWriter - saves image frames used to make a movie (possibly not threaded
     due to unresolved bugs when threaded)
     ********************************************************************************/
    self.parameters = parameters
    self.survivalPercentage = survivalPercentage
    grid = .init(size: self.parameters.size)
    signals = .init(layers: self.parameters.signalLayers, size: self.parameters.size)

    generation = 0
    fill(&grid, self.parameters)
  }

  func nextGeneration() -> World {
    let challenge = parameters.challenge ?? NoChallenge()

    //  if case .altruism = parameters.challenge {
    //TODO: Implement altruism challenge
    //  } else {
    // First, make a list of all the individuals who will become parents; save
    // their scores for later sorting. Indexes start at 1.
    var parents: [(Genome, Double)] = grid.living.compactMap { individual in
      let challengeResult = challenge.test(individual, on: grid)

      // Save the parent genome if it results in valid neural connections
      // ToDo: if the parents no longer need their genome record, we could
      // possibly do a move here instead of copy, although it's doubtful that
      // the optimization would be noticeable.
      guard challengeResult.didPass && !individual.nnet.connections.isEmpty else {
        return nil
      }

      return (individual.genome, challengeResult.score)
    }
    //  }

    // Sort the indexes of the parents by their fitness scores
    parents.sort { $0.1 > $1.1 }

    // Assemble a list of all the parent genomes. These will be ordered by their
    // scores if the parents[] container was sorted by score
    let parentGenomes = parents.map { $0.0 }

    // Now we have a container of zero or more parents' genomes
    guard !parentGenomes.isEmpty else {
      // Special case: there are no surviving parents: start the simulation over
      // from scratch with randomly-generated genomes
      return .randomPopulation(with: parameters)
    }

    let previousGrid = grid

    var world = World(parameters: parameters, survivalPercentage: Double(parentGenomes.count) / Double(parameters.population)) { grid, parameters in
      if let replaceBarrier = parameters.replaceBarrier, generation > replaceBarrier.generation {
        grid.applyBarrier(replaceBarrier.type)
      } else {
        grid.applyBarrier(parameters.generatedBarrier)
      }

      if parameters.shouldPersistManualBarriers {
        let manualBarriers = previousGrid.data.compactMap { coord, kind -> Coord? in
          switch kind {
          case .barrier(manual: true): return coord
          case .barrier, .occupied: return nil
          }
        }

        manualBarriers.forEach {
          if case .occupied = grid[$0] {
            return
          }

          grid[$0] = .barrier(manual: true)
        }
      }

      (0..<parameters.population).forEach {
        let individual = Individual(index: $0,
                                    loc: grid.findEmptyLocation(),
                                    genome: generateChildGenome(parentGenomes: parentGenomes, with: parameters),
                                    probeDistance: parameters.probeDistance,
                                    responsiveness: parameters.initialResponsiveness,
                                    maxNumberOfNeurons: parameters.maxNumberNeurons,
                                    actions: parameters.actions.count,
                                    sensors: parameters.sensors.count)
        grid[individual.loc] = .occupied(by: individual)
      }
    }

    world.generation = generation + 1
    return world
  }

  public static func randomPopulation(with parameters: Params) -> World {
    .init(parameters: parameters) { grid, parameters in
      if let replaceBarrier = parameters.replaceBarrier, replaceBarrier.generation == 0 {
        grid.applyBarrier(replaceBarrier.type)
      } else {
        grid.applyBarrier(parameters.generatedBarrier)
      }

      (0..<parameters.population).forEach {
        let individual = Individual(index: $0,
                                    loc: grid.findEmptyLocation(),
                                    genome: makeRandomGenome(parameters.genomeInitialLength),
                                    probeDistance: parameters.probeDistance,
                                    responsiveness: parameters.initialResponsiveness,
                                    maxNumberOfNeurons: parameters.maxNumberNeurons,
                                    actions: parameters.actions.count,
                                    sensors: parameters.sensors.count)
        grid[individual.loc] = .occupied(by: individual)
      }
    }
  }
}
