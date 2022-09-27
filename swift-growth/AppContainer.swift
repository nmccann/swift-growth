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
  let minSceneSize = CGSize(width: 600, height: 400)
  @StateObject var state = State()

  var scene: SKScene {
    let scene = SimulatorScene(state: state, size: minSceneSize)
    scene.scaleMode = .resizeFill
    scene.anchorPoint = .init(x: 0.5, y: 0.5)
    return scene
  }

  var body: some View {
    HStack {
        ParameterFormView(parameters: $state.editableParameters) {
          VStack {
            HStack {
              Text("Parameters")

              Button("Reset") {
                state.resetParameters()
              }

              Button("Apply") {
                state.applyParameters()
              }
            }

            Divider()

            HStack  {
              Text("On Tap")

              Button("Barrier") {
                state.mode = .placeBarrier
              }

              Button("Kill") {
                state.mode = .kill
              }

              Button("Select") {
                state.mode = .select
              }
            }.fixedSize(horizontal: true, vertical: false)
          }
          .padding()
        }
        .fixedSize(horizontal: true, vertical: false)

      SpriteView(scene: scene, options: .ignoresSiblingOrder)
        .frame(minWidth: minSceneSize.width,
               maxWidth: .infinity,
               minHeight: minSceneSize.height,
               maxHeight: .infinity)
        .layoutPriority(1)
    }
  }
}

