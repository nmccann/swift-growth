import SwiftUI
import SpriteKit

struct AppContainer: View {
  let minSize = CGSize(width: 400, height: 400)

  var scene: SKScene {
    let scene = SimulatorScene()
    scene.size = minSize
    scene.scaleMode = .resizeFill
    scene.anchorPoint = .init(x: 0.5, y: 0.5)
    return scene
  }

  var body: some View {
    SpriteView(scene: scene, options: .ignoresSiblingOrder)
      .frame(minWidth: minSize.width,
             maxWidth: .infinity,
             minHeight: minSize.height,
             maxHeight: .infinity)
  }
}

