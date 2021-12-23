import SpriteKit
import GameplayKit

class GameScene: SKScene {
  private var gridNode = SKNode()
  private var cellNodes: [SKShapeNode] = []
  private var barrierNodes: [SKShapeNode] = []
  private var cellSize: CGSize = .init(width: 1, height: 1)
  private var previousTime: TimeInterval = 0
  private let simulatorRefreshRate: TimeInterval = 1.0 / 60.0
  private var simulatorStepsPerRefresh = 10
  private var isAdvancing = false
  private var isStepReady = true
  private let padding: Double = 40

  override func sceneDidLoad() {
    super.sceneDidLoad()

    initializeSimulator()
    generateGrid()
  }

  override func didMove(to view: SKView) {
  }

  func touchDown(atPoint pos : CGPoint) {
  }

  func touchMoved(toPoint pos : CGPoint) {
  }

  func touchUp(atPoint pos : CGPoint) {
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

    previousTime = currentTime

    if isStepReady {
      updateNodes()
    }

    advanceBySteps(simulatorStepsPerRefresh)
  }

  override func didChangeSize(_ oldSize: CGSize) {
    generateGrid()
  }
}

private extension GameScene {
  func generateGrid() {
    gridNode.removeFromParent()
    gridNode.removeAllChildren()

    guard let scene = scene else {
      return
    }

    let exactFit = CGSize(width: (scene.size.width - padding) / Double(p.sizeX),
                          height: (scene.size.height - padding) / Double(p.sizeY))
    let squareWidth = floor(min(exactFit.width, exactFit.height))
    cellSize = CGSize(width: squareWidth, height: squareWidth)

    cellNodes = peeps.individuals.map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    cellNodes.forEach { gridNode.addChild($0) }

    generateBarriers()

    scene.addChild(gridNode)
  }

  func generateBarriers() {
    gridNode.removeChildren(in: barrierNodes)
    barrierNodes = grid.barrierLocations.map { _ in .init(rect: .init(origin: .zero, size: cellSize)) }
    barrierNodes.forEach { gridNode.addChild($0) }
  }

  func updateNodes() {
    if grid.barrierLocations.count != barrierNodes.count {
      generateGrid()
    }

    zip(cellNodes, peeps.individuals).forEach { cell, indiv in
      updateCell(cell, indiv: indiv, size: cellSize)
    }

    zip(barrierNodes, grid.barrierLocations).forEach { barrier, location in
      updateBarrier(barrier, location: location, size: cellSize)
    }
  }

  func advanceBySteps(_ steps: Int) {
    guard !isAdvancing else {
      return
    }

    didStartAdvancing()

    Task.detached(priority: .high) {
      let before = Date().timeIntervalSince1970
      for _ in 0..<steps {
        await self.didStartStep()
        await advanceSimulator()
        await self.didFinishStep()
      }
      let after = Date().timeIntervalSince1970
      print("Delta \(after - before)")

      await self.didFinishAdvancing()
    }
  }

  func updateCell(_ cell: SKShapeNode, indiv: Indiv, size: CGSize) {
    cell.fillColor = .green
    cell.isHidden = !indiv.alive
    cell.position = .init(x: Double(indiv.loc.x - (p.sizeX/2)) * size.width,
                          y: Double(indiv.loc.y - (p.sizeY/2)) * size.height)
  }

  func updateBarrier(_ barrier: SKShapeNode, location: Coord, size: CGSize) {
    barrier.fillColor = .red
    barrier.position = .init(x: Double(location.x - (p.sizeX/2)) * size.width,
                          y: Double(location.y - (p.sizeY/2)) * size.height)
  }

  func handleKeyEvent(_ event: NSEvent, keyDown: Bool) {
    guard let characters = event.charactersIgnoringModifiers,
          let keyChar = characters.unicodeScalars.first?.value,
          event.modifierFlags.contains(.numericPad) else {
            return
          }

    switch (runMode, Int(keyChar)) {
    case (_, NSUpArrowFunctionKey) where !keyDown: print("Genetic Diversity: \(geneticDiversity())")
    case (.run, NSDownArrowFunctionKey) where !keyDown:   runMode = .stop
    case (.stop, NSDownArrowFunctionKey) where !keyDown:  runMode = .run
    case (.run, NSRightArrowFunctionKey) where !keyDown:  adjustStepsPerRefresh(by: 1)
    case (.stop, NSRightArrowFunctionKey) where keyDown:  advanceBySteps(1)
    case (.run, NSLeftArrowFunctionKey) where !keyDown:   adjustStepsPerRefresh(by: -1)
    default: break
    }
  }

  func didStartStep() {
    isStepReady = false
  }

  func didFinishStep() {
    isStepReady = true
  }

  func didStartAdvancing() {
    isAdvancing = true
  }

  func didFinishAdvancing() {
    isAdvancing = false
  }

  func adjustStepsPerRefresh(by amount: Int) {
    simulatorStepsPerRefresh = max(1, simulatorStepsPerRefresh + amount)
    print("Steps per refresh: \(simulatorStepsPerRefresh)")
  }
}
