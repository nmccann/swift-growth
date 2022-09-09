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
  private var lastBarriers: [Barrier] = []
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

    guard case .run = state.simulator.mode, delta >= simulatorRefreshRate else {
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
    lastBarriers = []
    gridNode.removeFromParent()
    gridNode.removeAllChildren()

    guard let scene = scene else {
      return
    }

    let exactFit = CGSize(width: (scene.size.width - padding) / Double(state.world.parameters.size.width),
                          height: (scene.size.height - padding) / Double(state.world.parameters.size.height))
    let squareWidth = floor(min(exactFit.width, exactFit.height))
    cellSize = CGSize(width: squareWidth, height: squareWidth)

    //TODO: Find a better solution for issue where living cells can exceed the remaining cell nodes,
    //which can happen if we generate the grid and then the population changes (ex. due to death/or going into history).
    //Currently resolve this by generating more cells then we need and hiding the rest - resulting in a pool of available cells.
    cellNodes = (0...state.world.grid.living.count * 4).map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    cellNodes.forEach { gridNode.addChild($0) }

    generateBarriers()

    scene.addChild(gridNode)
  }

  func generateBarriers() {
    gridNode.removeChildren(in: barrierNodes)
    barrierNodes = state.world.grid.barriers.map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    barrierNodes.forEach { gridNode.addChild($0) }
  }

  func updateStats() {
    statsNode.position = .init(x: -((scene?.size.width ?? 0)/2) + (statsNode.frame.width / 2), y: -((scene?.size.height ?? 0)/2) + (statsNode.frame.height / 2))
    let average = timeAllSteps / (TimeInterval(state.world.simStep) + TimeInterval(state.world.generation * state.world.parameters.stepsPerGeneration) + 1)
    statsNode.text = "Step: \(state.world.simStep) Gen: \(state.world.generation) Survival: \(state.world.survivalPercentage) SPR: \(simulatorStepsPerRefresh) Average Per Step: \(average)"
  }

  func updateNodes() {
    let barriers = state.world.grid.barriers
    if barriers.count != barrierNodes.count {
      generateGrid()
    }

    let living = state.world.grid.living
    cellNodes.enumerated().forEach { index, cell in
      guard index < living.count else {
        cell.isHidden = true
        return
      }

      updateCell(cell, individual: living[index], size: cellSize)
    }

    if lastBarriers != barriers {
      zip(barrierNodes, barriers).forEach { node, barrier in
        updateBarrier(node, barrier: barrier, size: cellSize)
      }
      lastBarriers = barriers
    }
  }

  func advanceBySteps(_ steps: Int) {
    guard !isAdvancing else {
      return
    }

    didStartAdvancing()

    Task.detached(priority: .high) { [state] in
      let before = Date().timeIntervalSince1970
      var nextWorld = state.world
      for _ in 0..<steps {
        nextWorld = await state.simulator.stepForward(world: nextWorld)
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
    cell.position = .init(x: Double(individual.loc.x - (state.world.parameters.size.width/2)) * size.width,
                          y: Double(individual.loc.y - (state.world.parameters.size.height/2)) * size.height)

    //TODO: More obvious selection state (ex. glow/pulse)
    cell.lineWidth = state.selected == individual ? 3 : 1
  }

  func updateBarrier(_ node: SKShapeNode, barrier: Barrier, size: CGSize) {
    node.fillColor = barrier.isManual ? .orange : .red
    node.position = .init(x: Double(barrier.coord.x - (state.world.parameters.size.width/2)) * size.width,
                          y: Double(barrier.coord.y - (state.world.parameters.size.height/2)) * size.height)
  }

  func handleInteraction(at coord: Coord) {
    guard case .pause = state.simulator.mode else {
      return
    }

    switch (state.mode, state.world.grid[coord]) {
    case (.placeBarrier, _): state.world.grid[coord] = .barrier(manual: true)
    case (.kill, .occupied(by: _)): state.world.grid[coord] = nil
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

    switch (state.simulator.mode, Int(keyChar)) {
    case (_, NSUpArrowFunctionKey) where !keyDown:
      let all: [Individual] = state.world.grid.living + state.world.grid.dead
      let diversity = state.world.parameters.genomeComparisonMethod.diversityFor(all, initialPopulation: state.world.parameters.population)
      #if DEBUG
      print("Genetic Diversity: \(diversity)")
      #endif

    case (.run, NSDownArrowFunctionKey) where !keyDown:   state.simulator.mode = .pause
    case (.pause, NSDownArrowFunctionKey) where !keyDown:  state.simulator.mode = .run
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
    state.world = world
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
    state.world = state.simulator.stepBackward(world: state.world)
    timeAllSteps = 0
    updateStats()
    updateNodes()
  }

  /// Converts a given screen position to a coordinate in the grid,
  /// or nil if resulting coordinate lies outside of the grid
  func positionToCoord(_ position: CGPoint) -> Coord? {
    let result = Coord(x: Int(round(position.x / cellSize.width)) + (state.world.grid.size.width / 2),
                       y: (Int(round(position.y / cellSize.height)) + (state.world.grid.size.height / 2)))
    return state.world.grid.isInBounds(loc: result) ? result : nil
  }
}
