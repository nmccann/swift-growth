import SpriteKit
import GameplayKit

class GameScene: SKScene {
  private var spinnyNode : SKShapeNode?
  private var gridNode: SKNode!
  private var gridCells: [[SKShapeNode]] = []
  private var previousTime: TimeInterval = 0
  private let delay: TimeInterval = 0.1

  override func sceneDidLoad() {
    super.sceneDidLoad()

    initializeSimulator()

    guard let scene = scene else {
      return
    }

    let rect = CGRect(x: 0,
                      y: 0,
                      width: scene.size.width / Double(p.sizeX),
                      height: scene.size.height / Double(p.sizeY))
    let size = rect.integral.size
    gridNode = SKNode()

    for (column, columnContents) in grid.data.enumerated() {
      var cellRow: [SKShapeNode] = []
      for (row, rowContent) in columnContents.data.enumerated() {
        let cell = SKShapeNode(rect: .init(x: Double(column) * size.width,
                                            y: Double(row) * size.height,
                                            width: size.width,
                                            height: size.height))
        updateCell(cell, value: rowContent)
        gridNode.addChild(cell)
        cellRow.append(cell)
      }
      gridCells.append(cellRow)
    }

    gridNode.position = .init(x: -floor(scene.size.width/2), y: -floor(scene.size.height/2))
    scene.addChild(gridNode)
  }

  override func didMove(to view: SKView) {
    // Create shape node to use during mouse interaction
    let w = (self.size.width + self.size.height) * 0.05
    self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)

    if let spinnyNode = self.spinnyNode {
      spinnyNode.lineWidth = 2.5

      spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
      spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                        SKAction.fadeOut(withDuration: 0.5),
                                        SKAction.removeFromParent()]))
    }
  }


  func touchDown(atPoint pos : CGPoint) {
    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
      n.position = pos
      n.strokeColor = SKColor.green
      self.addChild(n)
    }
  }

  func touchMoved(toPoint pos : CGPoint) {
    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
      n.position = pos
      n.strokeColor = SKColor.blue
      self.addChild(n)
    }
  }

  func touchUp(atPoint pos : CGPoint) {
    if let n = self.spinnyNode?.copy() as! SKShapeNode? {
      n.position = pos
      n.strokeColor = SKColor.red
      self.addChild(n)
    }
  }

  override func mouseDown(with event: NSEvent) {
    self.touchDown(atPoint: event.location(in: self))
  }

  override func mouseDragged(with event: NSEvent) {
    self.touchMoved(toPoint: event.location(in: self))
  }

  override func mouseUp(with event: NSEvent) {
    self.touchUp(atPoint: event.location(in: self))
  }

  override func update(_ currentTime: TimeInterval) {
    let delta = currentTime - previousTime
    if delta > delay {
      advanceSimulator()
      previousTime = currentTime

      for (column, columnContents) in gridCells.enumerated() {
        for (row, cell) in columnContents.enumerated() {
          updateCell(cell, value: grid.data[column][row])
        }
      }
    }
  }

  func updateCell(_ cell: SKShapeNode, value: Int?) {
    guard let value = value else {
      cell.fillColor = .clear
      return
    }

    cell.fillColor = value == BARRIER ? .red : .green
  }
}
