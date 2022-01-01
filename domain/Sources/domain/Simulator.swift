import Foundation
import CollectionConcurrencyKit

public enum RunMode {
  case stop, run, pause, abort
}

public var runMode = RunMode.run
public var grid: Grid! // 2D arena where the individuals live
public var signals: Signals! // pheromone layers
public var generation = 0
public var murderCount = 0
public var simStep = 0
public var survivalPercentage = 0.0

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
public func initializeSimulator(with parameters: Params) {
  //TODO: Restore ability to print agent capabilities

  // Allocate container space. Once allocated, these container elements
  // will be reused in each new generation.
  grid = .init(size: parameters.size) // the land on which the peeps live
  signals = .init(layers: parameters.signalLayers, size: parameters.size)
  
  generation = 0
  initializeGeneration0(on: grid, with: parameters); // starting population
}

public func advanceSimulator(with parameters: Params) async {
  let challenge = parameters.challenge ?? NoChallenge()
  let results: [ActionResult] = await grid.living.concurrentMap {
    let result = executeStep(for: $0, simStep: simStep, on: grid, with: parameters)
    return challenge.modify(result, at: simStep, on: grid)
  }

  results.forEach { result in
    grid[result.individual.loc] = .occupied(by: result.individual)

    if let layer = result.signalToLayer {
      signals.increment(layer: layer, loc: result.individual.loc)
    }

    if let newLocation = result.newLocation {
      grid.queueForMove(from: result.individual.loc, to: newLocation)
    }

    result.killed.forEach {
      grid.queueForDeath(at: $0.loc)
    }
  }

  // In single-thread mode: this executes deferred, queued deaths and movements,
  // updates signal layers (pheromone), etc.
  murderCount += grid.deathQueue.count
  endOfSimStep(simStep, generation: generation, on: grid, with: parameters)
  
  simStep += 1
  
  guard simStep >= parameters.stepsPerGeneration else {
    return
  }
  
  endOfGeneration(generation)
  let numberSurvivors = spawnNewGeneration(generation: generation, murderCount: murderCount, on: grid, with: parameters)
  murderCount = 0
  simStep = 0
  
  if numberSurvivors == 0 {
    generation = 0 // start over
    survivalPercentage = 0
  } else {
    generation += 1
    survivalPercentage = Double(numberSurvivors) / Double(parameters.population)
  }
}

/**********************************************************************************************
 Execute one simStep for one individual.
 
 This executes in its own thread, invoked from the main simulator thread. First we execute
 individual.feedForward() which computes action values to be executed here. Some actions such as
 signal emission(s) (pheromones), agent movement, or deaths will have been queued for
 later execution at the end of the generation in single-threaded mode (the deferred queues
 allow the main data structures (e.g., grid, signals) to be freely accessed read-only in all threads).
 
 In order to be thread-safe, the main simulator-wide data structures and their
 accessibility are:
 
 grid - read-only
 signals - (pheromones) read-write for the location where our agent lives
 using signals.increment(), read-only for other locations
 peeps - for other individuals, we can only read their index and genome.
 We have read-write access to our individual through the indiv argument.
 
 The other important variables are:
 
 simStep - the current age of our agent, reset to 0 at the start of each generation.
 For many simulation scenarios, this matches our individual.age member.
 randomUint - global random number generator, a private instance is given to each thread
 **********************************************************************************************/
func executeStep(for individual: Individual, simStep: Int, on grid: Grid, with parameters: Params) -> ActionResult {
  var individual = individual
  individual.age += 1 // for this implementation, tracks simStep
  let actionLevels = individual.feedForward(simStep: simStep, on: grid, with: parameters)
  return executeActions(for: individual, levels: actionLevels, on: grid, with: parameters)
}



