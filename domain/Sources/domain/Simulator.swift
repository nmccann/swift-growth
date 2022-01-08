import Foundation
import CollectionConcurrencyKit

public class Simulator {
  public enum Mode {
    case stop, run, pause, abort
  }

  public var longTermHistory: [World] = []
  public var shortTermHistory: [World] = []

  public var mode: Mode

  public init(mode: Mode) {
    self.mode = mode
  }

  public func advance(world: World) async -> World {
    var world = world

    let challenge = world.parameters.challenge ?? NoChallenge()
    let results: [ActionResult] = await world.grid.living.concurrentMap {
      let result = Self.executeStep(for: $0, simStep: world.simStep, on: world)
      return challenge.modify(result, at: world.simStep, on: world.grid)
      }

      results.forEach { result in
        world.grid[result.individual.loc] = .occupied(by: result.individual)

        if let layer = result.signalToLayer {
          world.signals.increment(layer: layer, loc: result.individual.loc)
        }

        if let newLocation = result.newLocation {
          world.grid.queueForMove(from: result.individual.loc, to: newLocation)
        }

        result.killed.forEach {
          world.grid.queueForDeath(at: $0.loc)
        }
      }

      // In single-thread mode: this executes deferred, queued deaths and movements,
      // updates signal layers (pheromone), etc.
    Self.endOfSimStep(world.simStep, generation: world.generation, on: &world)
      shortTermHistory.append(world)

    world.simStep += 1

    guard world.simStep >= world.parameters.stepsPerGeneration else {
        return world
      }

    let nextWorld = world.nextGeneration()

    if nextWorld.generation == 0 {
      longTermHistory.removeAll()
    }

    shortTermHistory.removeAll()
    longTermHistory.append(nextWorld)
    return nextWorld
    }
}

private extension Simulator {
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
  static func executeStep(for individual: Individual, simStep: Int, on world: World) -> ActionResult {
    var individual = individual
    individual.age += 1 // for this implementation, tracks simStep
    let actionLevels = individual.feedForward(on: world)
    return executeActions(for: individual, levels: actionLevels, on: world.grid, with: world.parameters)
  }

  /*
   At the end of each sim step, this function is called in single-thread
   mode to take care of several things:

   1. We may kill off some agents if a "radioactive" scenario is in progress.
   2. We may flag some agents as meeting some challenge criteria, if such
   a scenario is in progress.
   3. We then drain the deferred death queue.
   4. We then drain the deferred movement queue.
   5. We fade the signal layer(s) (pheromones).
   */
  static func endOfSimStep(_ simStep: Int, generation: Int, on world: inout World) {
    world.grid.drainDeathQueue()
    world.grid.drainMoveQueue()

    world.signals.layers.indices.forEach { index in
      world.signals.fade(layer: index, by: SIGNAL_DAMPING)
    }
  }
}
