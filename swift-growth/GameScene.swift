import SpriteKit
import GameplayKit
import domain

class GameScene: SKScene {
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
  private let parameters = Params.defaults
  private var lastBarrierLocations: [Coord] = []

  override func sceneDidLoad() {
    super.sceneDidLoad()

    initializeSimulator(with: parameters)
    generateGrid()

    statsNode.fontSize = 16
    scene?.addChild(statsNode)
  }

  override func didMove(to view: SKView) {
  }

  func touchDown(atPoint position: CGPoint) {
    if let coord = positionToCoord(position) {
      #if DEBUG
      print("Killing at: \(coord)")
      #endif
      grid.queueForDeath(at: coord)
    }
  }

  func touchMoved(toPoint position: CGPoint) {
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

    guard case .run = runMode, delta >= simulatorRefreshRate else {
      return
    }

    statsNode.position = .init(x: -((scene?.size.width ?? 0)/2) + (statsNode.frame.width / 2), y: -((scene?.size.height ?? 0)/2) + (statsNode.frame.height / 2))
    statsNode.text = "Step: \(simStep) Gen: \(generation) Survival: \(survivalPercentage) SPR: \(simulatorStepsPerRefresh)"

    previousTime = currentTime

    advanceBySteps(simulatorStepsPerRefresh)
  }

  override func didChangeSize(_ oldSize: CGSize) {
    generateGrid()
  }
}

private extension GameScene {
  func generateGrid() {
    guard grid != nil else {
      return
    }

    lastBarrierLocations = []
    gridNode.removeFromParent()
    gridNode.removeAllChildren()

    guard let scene = scene else {
      return
    }

    let exactFit = CGSize(width: (scene.size.width - padding) / Double(parameters.size.x),
                          height: (scene.size.height - padding) / Double(parameters.size.y))
    let squareWidth = floor(min(exactFit.width, exactFit.height))
    cellSize = CGSize(width: squareWidth, height: squareWidth)

    cellNodes = grid.living.map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    cellNodes.forEach { gridNode.addChild($0) }

    generateBarriers()

    scene.addChild(gridNode)
  }

  func generateBarriers() {
    gridNode.removeChildren(in: barrierNodes)
    barrierNodes = grid.barriers.map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    barrierNodes.forEach { gridNode.addChild($0) }
  }

  func updateNodes() {
    let barriers = grid.barriers
    if barriers.count != barrierNodes.count {
      generateGrid()
    }

    let living = grid.living
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

    Task.detached(priority: .high) {
      for _ in 0..<steps {
        await advanceSimulator(with: self.parameters)
      }

      await self.didFinishAdvancing()
    }
  }

  func updateCell(_ cell: SKShapeNode, individual: Individual, size: CGSize) {
    let color = individual.color
    cell.fillColor = .init(red: color.red, green: color.green, blue: color.blue, alpha: 1)
    cell.isHidden = !individual.alive
    cell.position = .init(x: Double(individual.loc.x - (parameters.size.x/2)) * size.width,
                          y: Double(individual.loc.y - (parameters.size.y/2)) * size.height)
  }

  func updateBarrier(_ barrier: SKShapeNode, location: Coord, size: CGSize) {
    barrier.fillColor = .red
    barrier.position = .init(x: Double(location.x - (parameters.size.x/2)) * size.width,
                             y: Double(location.y - (parameters.size.y/2)) * size.height)
  }

  func handleKeyEvent(_ event: NSEvent, keyDown: Bool) {
    guard let characters = event.charactersIgnoringModifiers,
          let keyChar = characters.unicodeScalars.first?.value,
          event.modifierFlags.contains(.numericPad) else {
            return
          }

    switch (runMode, Int(keyChar)) {
    case (_, NSUpArrowFunctionKey) where !keyDown:
      let all: [Individual] = grid.living + grid.dead
      let diversity = parameters.genomeComparisonMethod.diversityFor(all, initialPopulation: parameters.population)
      #if DEBUG
      print("Genetic Diversity: \(diversity)")
      #endif

    case (.run, NSDownArrowFunctionKey) where !keyDown:   runMode = .stop
    case (.stop, NSDownArrowFunctionKey) where !keyDown:  runMode = .run
    case (.run, NSRightArrowFunctionKey) where !keyDown:  adjustStepsPerRefresh(by: 1)
    case (.stop, NSRightArrowFunctionKey) where keyDown:  advanceBySteps(1)
    case (.run, NSLeftArrowFunctionKey) where !keyDown:   adjustStepsPerRefresh(by: -1)
    default: break
    }
  }

  func didStartAdvancing() {
    isAdvancing = true
  }

  func didFinishAdvancing() {
    updateNodes()
    isAdvancing = false
  }

  func adjustStepsPerRefresh(by amount: Int) {
    simulatorStepsPerRefresh = max(1, simulatorStepsPerRefresh + amount)
  }


  /// Converts a given screen position to a coordinate in the grid,
  /// or nil if resulting coordinate lies outside of the grid
  func positionToCoord(_ position: CGPoint) -> Coord? {
    let result = Coord(x: Int(round(position.x / cellSize.width)) + (grid.size.x / 2), y: (Int(round(position.y / cellSize.height)) + (grid.size.y / 2)))
    return grid.isInBounds(loc: result) ? result : nil
  }
}
