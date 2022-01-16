import SwiftUI
import SpriteKit
import domain

class State: ObservableObject {
  enum Mode {
    case select, placeBarrier, kill
  }

  var mode: Mode = .select
  var world = World.randomPopulation(with: .defaults)
  let simulator = Simulator(mode: .run)
  @Published var selected: Individual?
}

struct AppContainer: View {
  let minSize = CGSize(width: 400, height: 400)
  @StateObject var state = State()

  var scene: SKScene {
    let scene = SimulatorScene(state: state, size: minSize)
    scene.scaleMode = .resizeFill
    scene.anchorPoint = .init(x: 0.5, y: 0.5)
    return scene
  }

  var body: some View {
    HStack {
      SpriteView(scene: scene, options: .ignoresSiblingOrder)
        .frame(minWidth: minSize.width,
               maxWidth: .infinity,
               minHeight: minSize.height,
               maxHeight: .infinity)
      VStack {
        Button("Barrier") {
          state.mode = .placeBarrier
        }

        Button("Kill") {
          state.mode = .kill
        }

        Button("Select") {
          state.mode = .select
        }
      }
    }
  }
}

