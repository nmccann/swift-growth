import SpriteKit
import GameplayKit

class GameScene: SKScene {
  private var gridNode = SKNode()
  private var cellNodes: [SKShapeNode] = []
  private var cellSize: CGSize = .init(width: 1, height: 1)
  private var previousTime: TimeInterval = 0
  private let simulatorStepRate: TimeInterval = 1.0 / 60.0
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
    
    if case .run = runMode, delta >= simulatorStepRate {
      previousTime = currentTime
      advanceSimulator()
    }

    zip(cellNodes, peeps.individuals).forEach { cell, indiv in
      updateCell(cell, indiv: indiv, size: cellSize)
    }
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
    scene.addChild(gridNode)
  }

  func updateCell(_ cell: SKShapeNode, indiv: Indiv, size: CGSize) {
    cell.fillColor = .green
    cell.isHidden = !indiv.alive
    cell.position = .init(x: Double(indiv.loc.x - (p.sizeX/2)) * size.width,
                          y: Double(indiv.loc.y - (p.sizeY/2)) * size.height)
  }

  func handleKeyEvent(_ event: NSEvent, keyDown: Bool) {
    guard let characters = event.charactersIgnoringModifiers,
          let keyChar = characters.unicodeScalars.first?.value,
          event.modifierFlags.contains(.numericPad) else {
            return
          }

    switch Int(keyChar) {
    case NSDownArrowFunctionKey where keyDown == false:
      if case .run = runMode {
        runMode = .stop
      } else {
        runMode = .run
      }
    case NSRightArrowFunctionKey:
      if case .run = runMode {
        runMode = .stop
      } else {
        advanceSimulator()
      }
    default: break
    }
  }
}
