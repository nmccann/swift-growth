import Foundation

// This class keeps track of alive and dead Indiv's and where they
// are in the Grid.
// Peeps allows spawning a live Indiv at a random or specific location
// in the grid, moving Indiv's from one grid location to another, and
// killing any Indiv.
// All the Indiv instances, living and dead, are stored in the private
// .individuals member. The .cull() function will remove dead members and
// replace their slots in the .individuals container with living members
// from the end of the container for compacting the container.
// Each Indiv has an identifying index in the range 1..0xfffe that is
// stored in the Grid at the location where the Indiv resides, such that
// a Grid element value n refers to .individuals[n]. Index value 0 is
// reserved, i.e., .individuals[0] is not a valid individual.
// This class does not manage properties inside Indiv except for the
// Indiv's location in the grid and its aliveness.
class Peeps {
  var individuals: [Indiv] = []
  var deathQueue: [Int] = []
  var moveQueue: [(Int, Coord)] = []

  init(individuals: [Indiv]) {
    self.individuals = individuals
  }

  /// Safe to call during multithread mode.
  /// Indiv will remain alive and in-world until end of sim step when
  /// drainDeathQueue() is called.
  func queueForDeath(_ indiv: Indiv) {
    deathQueue.append(indiv.index)
  }

  /// Called in single-thread mode at end of sim step. This executes all the
  /// queued deaths, removing the dead agents from the grid.
  func drainDeathQueue() {
    for index in deathQueue {
      // TODO: Don't rely on static instance from Simulator
      // This matches original implementation, but is not ideal
      var indiv = peeps[index]
      indiv.alive = false
      grid.set(loc: indiv.loc, val: nil)
      peeps[index] = indiv
    }
    deathQueue.removeAll()
  }


  /// Safe to call during multithread mode. Indiv won't move until end
  /// of sim step when drainMoveQueue() is called.
  func queueForMove(_ indiv: Indiv, newLoc: Coord) {
    moveQueue.append((indiv.index, newLoc))
  }

  /// Called in single-thread mode at end of sim step. This executes all the
  /// queued movements. Each movement is typically one 8-neighbor cell distance
  /// but this function can move an individual any arbitrary distance.
  func drainMoveQueue() {
    for moveRecord in moveQueue {
      // TODO: Don't rely on static instance for `peeps` or `grid` from Simulator
      // This matches original implementation, but is not ideal
      var indiv = peeps[moveRecord.0]
      let newLoc = moveRecord.1
      let moveDir = (newLoc - indiv.loc).asDir()
      if grid.isEmptyAt(loc: newLoc) {
        grid.set(loc: indiv.loc, val: nil)
        grid.set(loc: newLoc, val: indiv.index)
        indiv.loc = newLoc
        indiv.lastMoveDir = moveDir
        peeps[moveRecord.0] = indiv
      }
    }

    moveQueue.removeAll()
  }


  func deathQueueSize() -> Int {
    deathQueue.count
  }

  /// Does no error checking -- check first that loc is occupied
  func getIndiv(loc: Coord) -> Indiv {
    guard let index = grid.at(loc) else {
      fatalError("Location is not occupied")
    }

    return individuals[index]
  }

  subscript(index: Int) -> Indiv {
    get {
      individuals[index]
    }

    set {
      individuals[index] = newValue
    }
  }
}
