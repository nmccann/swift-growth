import Foundation

enum RunMode: Int {
  case STOP, RUN, PAUSE, ABORT
}

// Some of the survival challenges to try. Some are interesting, some
// not so much. Fine-tune the challenges by tweaking the corresponding code
// in survival-criteria
let CHALLENGE_CIRCLE = 0
let CHALLENGE_RIGHT_HALF = 1
let CHALLENGE_RIGHT_QUARTER = 2
let CHALLENGE_STRING = 3
let CHALLENGE_CENTER_WEIGHTED = 4
let CHALLENGE_CENTER_UNWEIGHTED = 40
let CHALLENGE_CORNER = 5
let CHALLENGE_CORNER_WEIGHTED = 6
let CHALLENGE_MIGRATE_DISTANCE = 7
let CHALLENGE_CENTER_SPARSE = 8
let CHALLENGE_LEFT_EIGHTH = 9
let CHALLENGE_RADIOACTIVE_WALLS = 10
let CHALLENGE_AGAINST_ANY_WALL = 11
let CHALLENGE_TOUCH_ANY_WALL = 12
let CHALLENGE_EAST_WEST_EIGHTHS = 13
let CHALLENGE_NEAR_BARRIER = 14
let CHALLENGE_PAIRS = 15
let CHALLENGE_LOCATION_SEQUENCE = 16
let CHALLENGE_ALTRUISM = 17
let CHALLENGE_ALTRUISM_SACRIFICE = 18

var runMode = RunMode.STOP
var p = Params.defaults
var grid = Grid(sizeX: p.sizeX, sizeY: p.sizeY) // 2D arena where the individuals live
//let signals = Signals()  // pheromone layers
var peeps = Peeps(individuals: []) // container of all the individuals
var generation = 0
var murderCount = 0
var simStep = 0

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
 peeps - an indexed set of agents of type Indiv; indexes start at 1

 The important simulator-wide variables are:
 generation - starts at 0, then increments every time the agents die and reproduce.
 simStep - reset to 0 at the start of each generation; fixed number per generation.
 randomUint - global random number generator

 The threads are:
 main thread - simulator
 simStepOneIndiv() - child threads created by the main simulator thread
 imageWriter - saves image frames used to make a movie (possibly not threaded
 due to unresolved bugs when threaded)
 ********************************************************************************/
func initializeSimulator() {
  printSensorsActions(); // show the agents' capabilities

  // Simulator parameters are available read-only through the global
  // variable p after paramManager is initialized.
  // Todo: remove the hardcoded parameter filename.
  p = .defaults
  //TODO: Support config files maybe?
//  paramManager.registerConfigFile(argc > 1 ? argv[1] : "biosim4.ini");
//  paramManager.updateFromConfigFile();

  // Allocate container space. Once allocated, these container elements
  // will be reused in each new generation.
  grid = .init(sizeX: p.sizeX, sizeY: p.sizeY) // the land on which the peeps live
//  signals.init(p.signalLayers, p.sizeX, p.sizeY);  // where the pheromones waft
  peeps = .init(individuals: []) // the peeps themselves (will be filled in when the first generation is initialized)

  generation = 0
  initializeGeneration0(); // starting population
}

func advanceSimulator() {
  for var indiv in peeps.individuals {
    simStepOneIndiv(indiv: &indiv, simStep: simStep)
  }

  // In single-thread mode: this executes deferred, queued deaths and movements,
  // updates signal layers (pheromone), etc.
  murderCount += peeps.deathQueueSize();
  endOfSimStep(simStep, generation: generation);

  simStep += 1

  guard simStep >= p.stepsPerGeneration else {
    return
  }

  endOfGeneration(generation)
  let numberSurvivors = spawnNewGeneration(generation: generation, murderCount: murderCount)
  murderCount = 0
  simStep = 0

  if numberSurvivors > 0 && generation % p.genomeAnalysisStride == 0 {
//    TODO: displaySamplGenomes(p.displaySampleGenomes)
  }

  if numberSurvivors == 0 {
    generation = 0 // start over
  } else {
    generation += 1
  }
}

/**********************************************************************************************
 Execute one simStep for one individual.

 This executes in its own thread, invoked from the main simulator thread. First we execute
 indiv.feedForward() which computes action values to be executed here. Some actions such as
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
 For many simulation scenarios, this matches our indiv.age member.
 randomUint - global random number generator, a private instance is given to each thread
 **********************************************************************************************/
func simStepOneIndiv(indiv: inout Indiv, simStep: Int) {
  indiv.age += 1 // for this implementation, tracks simStep
  let actionLevels = indiv.feedForward(simStep: simStep)
  executeActions(indiv: &indiv, levels: actionLevels)
}



