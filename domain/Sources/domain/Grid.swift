import Foundation

public struct Grid {
  public enum Kind: Equatable {
    case occupied(by: Individual)
    case barrier(manual: Bool)

    public static let barrier: Kind = .barrier(manual: false)
  }

  public private(set) var data: [Coord: Kind] = [:]
  public private(set) var dead: [Individual] = []
  private(set) var deathQueue: [Coord] = []
  private(set) var moveQueue: [(old: Coord, new: Coord)] = []
  public let size: Size

  public subscript(location: Coord) -> Kind? {
    get {
      data[location]
    }

    set {
      data[location] = newValue
    }
  }

  public subscript(x: Int, y: Int) -> Kind? {
    get {
      data[.init(x: x, y: y)]
    }

    set {
      data[.init(x: x, y: y)] = newValue
    }
  }

  public var living: [Individual] {
    data.values.compactMap {
      switch $0 {
      case .occupied(by: let individual): return individual
      case .barrier: return nil
      }
    }
  }

  public var barriers: [Barrier] {
    data.compactMap { coord, kind in
      switch kind {
      case .occupied(by: _): return nil
      case let .barrier(isManual): return .init(coord: coord, isManual: isManual)
      }
    }
  }

  /// Safe to call during multithread mode.
  /// Indiv will remain alive and in-world until end of sim step when
  /// drainDeathQueue() is called. It's ok if the same agent gets
  /// queued for death multiple times. It does not make sense to
  /// call this function for agents already dead.
  public mutating func queueForDeath(at location: Coord) {
    deathQueue.append(location)
  }

  /// Called in single-thread mode at end of sim step. This executes all the
  /// queued deaths, removing the dead agents from the grid.
  mutating func drainDeathQueue() {
    for location in deathQueue {
      guard case .occupied(by: let individual) = data.removeValue(forKey: location) else {
        continue
      }

      dead.append(individual)
    }
    deathQueue.removeAll()
  }


  /// Safe to call during multithread mode. individual won't move until end
  /// of sim step when drainMoveQueue() is called. Should only be called
  /// for living agents. It's ok if multiple agents are queued to move
  /// to the same location; only the first one will actually get moved.
  mutating func queueForMove(from location: Coord, to newLocation: Coord) {
    moveQueue.append((location, newLocation))
  }

  /// Called in single-thread mode at end of sim step. This executes all the
  /// queued movements. Each movement is typically one 8-neighbor cell distance
  /// but this function can move an individual any arbitrary distance. It is
  // possible that an agent queued for movement was recently killed when the
  // death queue was drained, so we'll ignore already-dead agents.
  mutating func drainMoveQueue() {
    for moveRecord in moveQueue {
      guard case .occupied(by: var individual) = data[moveRecord.old], individual.alive else {
        continue
      }

      if let moveDirection = (moveRecord.new - individual.loc).asDir(), isEmptyAt(loc: moveRecord.new) {
        individual.loc = moveRecord.new
        individual.lastDirection = moveDirection
        data[moveRecord.old] = nil
        data[moveRecord.new] = .occupied(by: individual)
      }
    }

    moveQueue.removeAll()
  }

  init(size: Size) {
    self.size = size
  }

  mutating func reset() {
    data.removeAll()
    dead.removeAll()
  }

  public func isInBounds(loc: Coord) -> Bool {
    loc.x >= 0 && loc.x < size.width && loc.y >= 0 && loc.y < size.height
  }

  func isEmptyAt(loc: Coord) -> Bool {
    data[loc] == nil
  }

  func isBarrierAt(loc: Coord) -> Bool {
    if case .barrier = data[loc] {
      return true
    } else {
      return false
    }
  }

  /// Occupied means an agent is living there.
  func isOccupiedAt(loc: Coord) -> Bool {
    if case .occupied(by: _) = data[loc] {
      return true
    } else {
      return false
    }
  }

  func isBorder(loc: Coord) -> Bool {
    loc.x == 0 || loc.x == size.width - 1 || loc.y == 0 || loc.y == size.height - 1
  }

  func findEmptyLocation() -> Coord {
    while true {
      let location = Coord(x: .random(in: 0..<size.width),
                           y: .random(in: 0..<size.height))

      if isEmptyAt(loc: location) {
        return location
      }
    }
  }

  /// Generates a series of barrier locations based on the provided barrier type.
  /// - Parameter type: Type of barrier to construct
  mutating func applyBarrier(_ type: GeneratedBarrier?) {
    guard let type = type else {
      return
    }

    func drawBox(min: (x: Int, y: Int), max: (x: Int, y: Int)) {
      for x in min.x...max.x {
        for y in min.y...max.y {
          data[.init(x: x, y: y)] = .barrier
        }
      }
    }

    switch type {
    case .verticalBarConstant:
      let min = (x: size.width / 2, y: size.height / 4)
      let max = (x: min.x + 1, y: min.y + size.height / 2)
      drawBox(min: min, max: max)
    case .verticalBarRandom:
      //TODO: Make less sensitive to grid size (fails if height / 2 - 20 is less than 20)
      let min = (x: Int.random(in: 20...(size.width - 20)), y: Int.random(in: 20...(size.height / 2 - 20)))
      let max = (x: min.x + 1, y: min.y + size.height / 2)
      drawBox(min: min, max: max)
    case .fiveBlocks: return //TODO
    case .horizontalBarConstant: return //TODO
    case .threeIslandsRandom: return // TODO
    case .spotsRandom:
      let numberOfLocations = 5
      let radius = 5.0

      for _ in 0..<numberOfLocations {
        let loc = Coord(x: .random(in: 0..<size.width), y: .random(in: 0..<size.height))
        visitNeighborhood(loc: loc, radius: radius) {
          data[$0] = .barrier
        }
      }
    }
  }

  func visitNeighborhood(loc: Coord, radius: Double, f: (Coord) -> Void) {
    for dx in (-min(Int(radius), loc.x)...min(Int(radius), (size.width - loc.x) - 1)) {
      let x = loc.x + dx
      assert(x >= 0 && x < size.width)
      let extentY = Int((pow(radius, 2) - pow(Double(dx), 2)).squareRoot())

      for dy in (-min(extentY, loc.y)...min(extentY, (size.height - loc.y) - 1)) {
        let y = loc.y + dy
        assert(y >= 0 && y < size.height)
        f(.init(x: x, y: y))
      }
    }
  }
}
