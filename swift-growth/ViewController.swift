import Cocoa
import SpriteKit
import GameplayKit

class ViewController: NSViewController, NSWindowDelegate {
  @IBOutlet var skView: SKView!

  override func viewDidLoad() {
    super.viewDidLoad()

    if let view = self.skView {
      // Load the SKScene from 'GameScene.sks'
      if let scene = SKScene(fileNamed: "GameScene") {
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .resizeFill

        // Ignores sibling order for improved performance, use Z Position for draw order
        scene.view?.ignoresSiblingOrder = true

        // Present the scene
        view.presentScene(scene)
      }

      view.ignoresSiblingOrder = true

      view.showsFPS = true
      view.showsNodeCount = true
      view.showsDrawCount = true
    }
  }

  override func viewWillAppear() {
    super.viewWillAppear()

    if let sceneSize = skView.scene?.size {
      view.window?.setContentSize(sceneSize)
    }
  }
}

