import Foundation

func passedSurvivalCriterion(indiv: inout Indiv, challenge: Int) -> (Bool, Double) {
  //TODO: Implement correctly
  return (true, 1.0)
}

// Requires that the grid, signals, and peeps containers have been allocated.
// This will erase the grid and signal layers, then create a new population in
// the peeps container at random locations with random genomes.
func initializeGeneration0() {
  // The grid has already been allocated, just clear and reuse it
  grid.nilFill()
  grid.createBarrier(barrierType: p.replaceBarrierTypeGenerationNumber == 0 ? p.replaceBarrierType : p.barrierType)

  //TODO: Signals when they are supported
  // The signal layers have already been allocated, so just reuse them
  //  signals.zeroFill();

  // Spawn the population. The peeps container has already been allocated,
  // just clear and reuse it
  let individuals: [Indiv] = (0..<p.population).map { .init(index: $0,
                                                            loc: grid.findEmptyLocation(),
                                                            genome: makeRandomGenome()) }
  peeps = .init(individuals: individuals)
}

// Requires a container with one or more parent genomes to choose from.
// Called from spawnNewGeneration(). This requires that the grid, signals, and
// peeps containers have been allocated. This will erase the grid and signal
// layers, then create a new population in the peeps container with random
// locations and genomes derived from the container of parent genomes.
func initializeNewGeneration(parentGenomes: inout [Genome], generation: Int) {
  // The grid, signals, and peeps containers have already been allocated, just
  // clear them if needed and reuse the elements
  grid.nilFill();
  grid.createBarrier(barrierType: generation >= p.replaceBarrierTypeGenerationNumber ? p.replaceBarrierType : p.barrierType);
  //TODO: Signals when they are supported
//  signals.zeroFill();

  // Spawn the population. This overwrites all the elements of peeps[]
  let individuals: [Indiv] = (0..<p.population).map { .init(index: $0,
                                                            loc: grid.findEmptyLocation(),
                                                            genome: generateChildGenome(parentGenomes: &parentGenomes)) }
  peeps = .init(individuals: individuals)
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
func spawnNewGeneration(generation: Int, murderCount: Int) -> Int {
  // This container will hold the indexes and survival scores (0.0..1.0)
  // of all the survivors who will provide genomes for repopulation.
  var parents: [(Int, Double)] = [] // <indiv index, score>

  if p.challenge != CHALLENGE_ALTRUISM {
    // First, make a list of all the individuals who will become parents; save
    // their scores for later sorting. Indexes start at 1.
    for i in 0..<p.population {
      let passed = passedSurvivalCriterion(indiv: &peeps[i], challenge: p.challenge)

      // Save the parent genome if it results in valid neural connections
      // ToDo: if the parents no longer need their genome record, we could
      // possibly do a move here instead of copy, although it's doubtful that
      // the optimization would be noticeable.
      if passed.0 && !peeps[i].nnet.connections.isEmpty {
        parents.append((i, passed.1))
      }
    }
  } else {
    //TODO: Implement altruism challenge
  }

  // Sort the indexes of the parents by their fitness scores
  parents.sort { $0.1 > $1.1 }

  // Assemble a list of all the parent genomes. These will be ordered by their
  // scores if the parents[] container was sorted by score
  var parentGenomes = parents.map { peeps[$0.0].genome }

  // Now we have a container of zero or more parents' genomes
  if !parentGenomes.isEmpty {
    // Spawn a new generation
    initializeNewGeneration(parentGenomes: &parentGenomes, generation: generation + 1);
  } else {
    // Special case: there are no surviving parents: start the simulation over
    // from scratch with randomly-generated genomes
    initializeGeneration0()
  }

  return parentGenomes.count
}