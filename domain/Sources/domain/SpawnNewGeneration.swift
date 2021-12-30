import Foundation

// Requires that the grid, signals, and peeps containers have been allocated.
// This will erase the grid and signal layers, then create a new population in
// the peeps container at random locations with random genomes.
func initializeGeneration0(on grid: Grid, with parameters: Params) {
  // The grid has already been allocated, just clear and reuse it
  grid.nilFill()
  
  if let replaceBarrier = parameters.replaceBarrier, replaceBarrier.generation == 0 {
    grid.applyBarrier(replaceBarrier.type)
  } else {
    grid.applyBarrier(parameters.barrierType)
  }
  
  // The signal layers have already been allocated, so just reuse them
  signals.zeroFill()
  
  // Spawn the population. The peeps container has already been allocated,
  // just clear and reuse it
  let individuals: [Individual] = (0..<parameters.population).map { .init(index: $0,
                                                                     loc: grid.findEmptyLocation(),
                                                                     genome: makeRandomGenome(parameters.genomeInitialLength),
                                                                     probeDistance: parameters.probeDistance,
                                                                     maxNumberOfNeurons: parameters.maxNumberNeurons,
                                                                     actions: parameters.actions.count,
                                                                     sensors: parameters.sensors.count) }
  
  individuals.forEach { individual in
    grid[individual.loc] = .occupied(by: individual)
  }
}

// Requires a container with one or more parent genomes to choose from.
// Called from spawnNewGeneration(). This requires that the grid, signals, and
// peeps containers have been allocated. This will erase the grid and signal
// layers, then create a new population in the peeps container with random
// locations and genomes derived from the container of parent genomes.
func initializeNewGeneration(parentGenomes: [Genome], generation: Int, on grid: Grid, with parameters: Params) {
  // The grid, signals, and peeps containers have already been allocated, just
  // clear them if needed and reuse the elements
  grid.nilFill()
  
  if let replaceBarrier = parameters.replaceBarrier, generation > replaceBarrier.generation {
    grid.applyBarrier(replaceBarrier.type)
  } else {
    grid.applyBarrier(parameters.barrierType)
  }
  
  signals.zeroFill()
  
  // Spawn the population. This overwrites all the elements of peeps[]
  let individuals: [Individual] = (0..<parameters.population).map { .init(index: $0,
                                                                     loc: grid.findEmptyLocation(),
                                                                     genome: generateChildGenome(parentGenomes: parentGenomes, with: parameters),
                                                                     probeDistance: parameters.probeDistance,
                                                                     maxNumberOfNeurons: parameters.maxNumberNeurons,
                                                                     actions: parameters.actions.count,
                                                                     sensors: parameters.sensors.count) }
  
  individuals.forEach { individual in
    grid[individual.loc] = .occupied(by: individual)
  }
}

// At this point, the deferred death queue and move queue have been processed
// and we are left with zero or more individuals who will repopulate the
// world grid.
// In order to redistribute the new population randomly, we will save all the
// surviving genomes in a container, then clear the grid of indexes and generate
// new individuals. This is inefficient when there are lots of survivors because
// we could have reused (with mutations) the survivors' genomes and neural
// nets instead of rebuilding them.
// Returns number of survivor-reproducers.
// Must be called in single-thread mode between generations.
func spawnNewGeneration(generation: Int, murderCount: Int, on grid: Grid, with parameters: Params) -> Int {
  // This container will hold the indexes and survival scores (0.0..1.0)
  // of all the survivors who will provide genomes for repopulation.
//  var parents: [(Int, Double)] = [] // <indiv index, score>
  
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
  if !parentGenomes.isEmpty {
    // Spawn a new generation
    initializeNewGeneration(parentGenomes: parentGenomes, generation: generation + 1, on: grid, with: parameters);
  } else {
    // Special case: there are no surviving parents: start the simulation over
    // from scratch with randomly-generated genomes
    initializeGeneration0(on: grid, with: parameters)
  }
  
  return parentGenomes.count
}
