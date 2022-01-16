import SpriteKit
import domain

class SimulatorScene: SKScene {
  private var gridNode = SKNode()
  private var statsNode = SKLabelNode()
  private var cellNodes: [SKShapeNode] = []
  private var barrierNodes: [SKShapeNode] = []
  private var cellSize: CGSize = .init(width: 1, height: 1)
  private var previousTime: TimeInterval = 0
  private let simulatorRefreshRate: TimeInterval = 1.0 / 60.0
  private var simulatorStepsPerRefresh = 1
  private var isAdvancing = false
  private let padding: Double = 40
  private var world = World.randomPopulation(with: .defaults)
  private let simulator = Simulator(mode: .run)
  private var lastBarrierLocations: [Coord] = []
  private var timeAllSteps: TimeInterval = 0
  private var state: State

  init(state: State, size: CGSize) {
    self.state = state
    super.init(size: size)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func sceneDidLoad() {
    super.sceneDidLoad()

    generateGrid()

    statsNode.fontSize = 16
    scene?.addChild(statsNode)
  }

  override func didMove(to view: SKView) {
  }

  func touchDown(atPoint position: CGPoint) {
    guard let coord = positionToCoord(position) else {
      return
    }

    handleInteraction(at: coord)
  }

  func touchMoved(toPoint position: CGPoint) {
    guard let coord = positionToCoord(position) else {
      return
    }

    handleInteraction(at: coord)
  }

  func touchUp(atPoint position: CGPoint) {
  }

  override func mouseDown(with event: NSEvent) {
    touchDown(atPoint: event.location(in: self))
  }

  override func mouseDragged(with event: NSEvent) {
    touchMoved(toPoint: event.location(in: self))
  }

  override func mouseUp(with event: NSEvent) {
    touchUp(atPoint: event.location(in: self))
  }

  override func keyUp(with event: NSEvent) {
    handleKeyEvent(event, keyDown: false)
  }

  override func keyDown(with event: NSEvent) {
    handleKeyEvent(event, keyDown: true)
  }

  override func update(_ currentTime: TimeInterval) {
    let delta = currentTime - previousTime

    updateStats()

    guard case .run = simulator.mode, delta >= simulatorRefreshRate else {
      return
    }

    previousTime = currentTime

    advanceBySteps(simulatorStepsPerRefresh)
  }

  override func didChangeSize(_ oldSize: CGSize) {
    generateGrid()
    updateNodes()
  }
}

private extension SimulatorScene {
  func generateGrid() {
    lastBarrierLocations = []
    gridNode.removeFromParent()
    gridNode.removeAllChildren()

    guard let scene = scene else {
      return
    }

    let exactFit = CGSize(width: (scene.size.width - padding) / Double(world.parameters.size.x),
                          height: (scene.size.height - padding) / Double(world.parameters.size.y))
    let squareWidth = floor(min(exactFit.width, exactFit.height))
    cellSize = CGSize(width: squareWidth, height: squareWidth)

    //TODO: Find a better solution for issue where living cells can exceed the remaining cell nodes,
    //which can happen if we generate the grid and then the population changes (ex. due to death/or going into history).
    //Currently resolve this by generating more cells then we need and hiding the rest - resulting in a pool of available cells.
    cellNodes = (0...world.grid.living.count * 4).map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    cellNodes.forEach { gridNode.addChild($0) }

    generateBarriers()

    scene.addChild(gridNode)
  }

  func generateBarriers() {
    gridNode.removeChildren(in: barrierNodes)
    barrierNodes = world.grid.barriers.map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    barrierNodes.forEach { gridNode.addChild($0) }
  }

  func updateStats() {
    statsNode.position = .init(x: -((scene?.size.width ?? 0)/2) + (statsNode.frame.width / 2), y: -((scene?.size.height ?? 0)/2) + (statsNode.frame.height / 2))
    let average = timeAllSteps / (TimeInterval(world.simStep) + TimeInterval(world.generation * world.parameters.stepsPerGeneration) + 1)
    statsNode.text = "Step: \(world.simStep) Gen: \(world.generation) Survival: \(world.survivalPercentage) SPR: \(simulatorStepsPerRefresh) Average Per Step: \(average)"
  }

  func updateNodes() {
    let barriers = world.grid.barriers
    if barriers.count != barrierNodes.count {
      generateGrid()
    }

    let living = world.grid.living
    cellNodes.enumerated().forEach { index, cell in
      guard index < living.count else {
        cell.isHidden = true
        return
      }

      updateCell(cell, individual: living[index], size: cellSize)
    }

    if lastBarrierLocations != barriers {
      zip(barrierNodes, barriers).forEach { barrier, location in
        updateBarrier(barrier, location: location, size: cellSize)
      }
      lastBarrierLocations = barriers
    }
  }

  func advanceBySteps(_ steps: Int) {
    guard !isAdvancing else {
      return
    }

    didStartAdvancing()

    Task.detached(priority: .high) { [world, simulator] in
      let before = Date().timeIntervalSince1970
      var nextWorld = world
      for _ in 0..<steps {
        nextWorld = await simulator.stepForward(world: nextWorld)
      }
      let after = Date().timeIntervalSince1970

      await self.didFinishAdvancing(to: nextWorld)
      await self.incrementTimeForSteps(by: after - before)
    }
  }

  func updateCell(_ cell: SKShapeNode, individual: Individual, size: CGSize) {
    let color = individual.color
    cell.fillColor = .init(red: color.red, green: color.green, blue: color.blue, alpha: 1)
    cell.isHidden = !individual.alive
    cell.position = .init(x: Double(individual.loc.x - (world.parameters.size.x/2)) * size.width,
                          y: Double(individual.loc.y - (world.parameters.size.y/2)) * size.height)

    //TODO: More obvious selection state (ex. glow/pulse)
    cell.lineWidth = state.selected == individual ? 3 : 1
  }

  func updateBarrier(_ barrier: SKShapeNode, location: Coord, size: CGSize) {
    barrier.fillColor = .red
    barrier.position = .init(x: Double(location.x - (world.parameters.size.x/2)) * size.width,
                             y: Double(location.y - (world.parameters.size.y/2)) * size.height)
  }

  func handleInteraction(at coord: Coord) {
    guard case .pause = simulator.mode else {
      return
    }

    switch (state.mode, world.grid[coord]) {
    case (.placeBarrier, _): world.grid[coord] = .barrier
    case (.kill, .occupied(by: _)): world.grid[coord] = nil
    case (.kill, _): return
    case (.select, .occupied(by: let individual)): state.selected = individual
    case (.select, _): state.selected = nil
    }

    updateNodes()
  }

  func handleKeyEvent(_ event: NSEvent, keyDown: Bool) {
    guard let characters = event.charactersIgnoringModifiers,
          let keyChar = characters.unicodeScalars.first?.value,
          event.modifierFlags.contains(.numericPad) else {
            return
          }

    switch (simulator.mode, Int(keyChar)) {
    case (_, NSUpArrowFunctionKey) where !keyDown:
      let all: [Individual] = world.grid.living + world.grid.dead
      let diversity = world.parameters.genomeComparisonMethod.diversityFor(all, initialPopulation: world.parameters.population)
      #if DEBUG
      print("Genetic Diversity: \(diversity)")
      #endif

    case (.run, NSDownArrowFunctionKey) where !keyDown:   simulator.mode = .pause
    case (.pause, NSDownArrowFunctionKey) where !keyDown:  simulator.mode = .run
    case (.run, NSRightArrowFunctionKey) where !keyDown:  adjustStepsPerRefresh(by: 1)
    case (.pause, NSRightArrowFunctionKey) where keyDown:  advanceBySteps(1)
    case (.run, NSLeftArrowFunctionKey) where !keyDown:   adjustStepsPerRefresh(by: -1)
    case (.pause, NSLeftArrowFunctionKey) where simulatorStepsPerRefresh == 1: rewind()
    default: break
    }
  }

  func didStartAdvancing() {
    isAdvancing = true
  }

  func didFinishAdvancing(to world: World) {
    self.world = world
    updateNodes()
    isAdvancing = false
  }

  func incrementTimeForSteps(by time: TimeInterval) {
    timeAllSteps += time
  }

  func adjustStepsPerRefresh(by amount: Int) {
    simulatorStepsPerRefresh = max(1, simulatorStepsPerRefresh + amount)
  }

  func rewind() {
    world = simulator.stepBackward(world: world)
    timeAllSteps = 0
    updateStats()
    updateNodes()
  }

  /// Converts a given screen position to a coordinate in the grid,
  /// or nil if resulting coordinate lies outside of the grid
  func positionToCoord(_ position: CGPoint) -> Coord? {
    let result = Coord(x: Int(round(position.x / cellSize.width)) + (world.grid.size.x / 2), y: (Int(round(position.y / cellSize.height)) + (world.grid.size.y / 2)))
    return world.grid.isInBounds(loc: result) ? result : nil
  }
}
