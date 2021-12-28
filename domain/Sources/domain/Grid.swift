import Foundation

public class Grid {
  public enum Kind: Equatable {
    case occupied(by: Indiv)
    case barrier
  }

  private var data: [Coord: Kind] = [:]
  public private(set) var dead: [Indiv] = []
  public var barrierLocations: [Coord] = []
  var barrierCenters: [Coord] = []
  private(set) var deathQueue: [Coord] = []
  private(set) var moveQueue: [(old: Coord, new: Coord)] = []
  let size: (x: Int, y: Int)

  subscript(location: Coord) -> Kind? {
    get {
      data[location]
    }

    set {
      data[location] = newValue
    }
  }

  subscript(x: Int, y: Int) -> Kind? {
    get {
      data[.init(x: x, y: y)]
    }

    set {
      data[.init(x: x, y: y)] = newValue
    }
  }

  public var living: [Indiv] {
    data.values.compactMap {
      switch $0 {
      case .occupied(by: let individual): return individual
      case .barrier: return nil
      }
    }
  }

  /// Safe to call during multithread mode.
  /// Indiv will remain alive and in-world until end of sim step when
  /// drainDeathQueue() is called. It's ok if the same agent gets
  /// queued for death multiple times. It does not make sense to
  /// call this function for agents already dead.
  func queueForDeath(at location: Coord) {
    deathQueue.append(location)
  }

  /// Called in single-thread mode at end of sim step. This executes all the
  /// queued deaths, removing the dead agents from the grid.
  func drainDeathQueue() {
    for location in deathQueue {
      guard case .occupied(by: let individual) = data.removeValue(forKey: location) else {
        continue
      }

      dead.append(individual)
    }
    deathQueue.removeAll()
  }


  /// Safe to call during multithread mode. Indiv won't move until end
  /// of sim step when drainMoveQueue() is called. Should only be called
  /// for living agents. It's ok if multiple agents are queued to move
  /// to the same location; only the first one will actually get moved.
  func queueForMove(from location: Coord, to newLocation: Coord) {
    moveQueue.append((location, newLocation))
  }

  /// Called in single-thread mode at end of sim step. This executes all the
  /// queued movements. Each movement is typically one 8-neighbor cell distance
  /// but this function can move an individual any arbitrary distance. It is
  // possible that an agent queued for movement was recently killed when the
  // death queue was drained, so we'll ignore already-dead agents.
  func drainMoveQueue() {
    for moveRecord in moveQueue {
      guard case .occupied(by: var indiv) = data[moveRecord.old], indiv.alive else {
        continue
      }

      if let moveDirection = (moveRecord.new - indiv.loc).asDir(), isEmptyAt(loc: moveRecord.new) {
        indiv.loc = moveRecord.new
        indiv.lastDirection = moveDirection
        data[moveRecord.old] = nil
        data[moveRecord.new] = .occupied(by: indiv)
      }
    }

    moveQueue.removeAll()
  }

  /// Does no error checking -- check first that loc is occupied
  func getIndiv(loc: Coord) -> Indiv {
    guard case .occupied(by: let individual) = data[loc] else {
      fatalError("Location is not occupied")
    }

    return individual
  }

  init(size: (x: Int, y: Int)) {
    self.size = size
  }

  func nilFill() {
    data.removeAll()
  }

  func isInBounds(loc: Coord) -> Bool {
    loc.x >= 0 && loc.x < size.x && loc.y >= 0 && loc.y < size.y
  }

  func isEmptyAt(loc: Coord) -> Bool {
    at(loc) == nil
  }

  func isBarrierAt(loc: Coord) -> Bool {
    if case .barrier = at(loc) {
      return true
    } else {
      return false
    }
  }

  /// Occupied means an agent is living there.
  func isOccupiedAt(loc: Coord) -> Bool {
    if case .occupied(by: _) = at(loc) {
      return true
    } else {
      return false
    }
  }

  func isBorder(loc: Coord) -> Bool {
    loc.x == 0 || loc.x == size.x - 1 || loc.y == 0 || loc.y == size.y - 1
  }

  func at(_ loc: Coord) -> Kind? {
    data[loc]
  }

  func at(x: Int, y: Int) -> Kind? {
    data[.init(x: x, y: y)]
  }

  func findEmptyLocation() -> Coord {
    while true {
      let location = Coord(x: .random(in: 0..<size.x),
                           y: .random(in: 0..<size.y))

      if isEmptyAt(loc: location) {
        return location
      }
    }
  }

  // This generates barrier points, which are grid locations with value
  // BARRIER. A list of barrier locations is saved in private member
  // Grid::barrierLocations and, for some scenarios, Grid::barrierCenters.
  // Those members are available read-only with Grid::getBarrierLocations().
  // This function assumes an empty grid. This is typically called by
  // the main simulator thread after Grid::init() or Grid::zeroFill().

  // This file typically is under constant development and change for
  // specific scenarios.
  func applyBarrier(_ type: BarrierType?) {
    barrierLocations.removeAll()
    barrierCenters.removeAll() // used only for some barrier types

    guard let type = type else {
      return
    }

    func drawBox(min: (x: Int, y: Int), max: (x: Int, y: Int)) {
      for x in min.x...max.x {
        for y in min.y...max.y {
          data[.init(x: x, y: y)] = .barrier
          barrierLocations.append(.init(x: x, y: y))
        }
      }
    }

    switch type {
    case .verticalBarConstant:
      let min = (x: size.x / 2, y: size.y / 4)
      let max = (x: min.x + 1, y: min.y + size.y / 2)
      drawBox(min: min, max: max)
    case .verticalBarRandom:
      //TODO: Make less sensitive to grid size (fails if height / 2 - 20 is less than 20)
      let min = (x: Int.random(in: 20...(size.x - 20)), y: Int.random(in: 20...(size.y / 2 - 20)))
      let max = (x: min.x + 1, y: min.y + size.y / 2)
      drawBox(min: min, max: max)
    case .fiveBlocks: return //TODO
    case .horizontalBarConstant: return //TODO
    case .threeIslandsRandom: return // TODO
    case .spotsRandom:
      let numberOfLocations = 5
      let radius = 5.0

      for _ in 0..<numberOfLocations {
        let loc = Coord(x: .random(in: 0..<size.x), y: .random(in: 0..<size.y))
        visitNeighborhood(loc: loc, radius: radius) {
          data[$0] = .barrier
          barrierLocations.append($0)
        }
      }
    }
  }

  func getBarrierLocations() -> [Coord] {
    barrierLocations
  }

  func getBarrierCenters() -> [Coord] {
    barrierCenters
  }

  func visitNeighborhood(loc: Coord, radius: Double, f: (Coord) -> Void) {
    for dx in (-min(Int(radius), loc.x)...min(Int(radius), (size.x - loc.x) - 1)) {
      let x = loc.x + dx
      assert(x >= 0 && x < size.x)
      let extentY = Int((pow(radius, 2) - pow(Double(dx), 2)).squareRoot())

      for dy in (-min(extentY, loc.y)...min(extentY, (size.y - loc.y) - 1)) {
        let y = loc.y + dy
        assert(y >= 0 && y < size.y)
        f(.init(x: x, y: y))
      }
    }
  }
}
