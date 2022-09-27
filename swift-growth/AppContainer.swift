import SwiftUI
import SpriteKit
import domain

class State: ObservableObject {
  enum Mode {
    case select, placeBarrier, kill
  }

  var mode: Mode
  var world: World
  var simulator: Simulator
  let initialParameters: Parameters = .defaults
  @Published var editableParameters: Parameters
  @Published var selected: Individual?

  init() {
    mode = .select
    editableParameters = initialParameters
    world = .randomPopulation(with: initialParameters)
    simulator = .init(mode: .run)
  }

  func resetParameters() {
    editableParameters = initialParameters
    applyParameters()
  }

  func applyParameters() {
    world = .randomPopulation(with: editableParameters)
    simulator = .init(mode: .run)
  }
}

struct AppContainer: View {
  let minSize = CGSize(width: 800, height: 600)
  @StateObject var state = State()

  var scene: SKScene {
    let scene = SimulatorScene(state: state, size: minSize)
    scene.scaleMode = .resizeFill
    scene.anchorPoint = .init(x: 0.5, y: 0.5)
    return scene
  }

  var body: some View {
    HStack {
      VStack {
        ParameterFormView(parameters: $state.editableParameters)
        HStack {
          Button("Reset") {
            state.resetParameters()
          }

          Button("Apply") {
            state.applyParameters()
          }
        }.padding()
      }

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

