import Foundation

// Maps current location along axis of 0...grid axis dimension-1 to sensor range 0.0..1.0
struct LastMoveDirectionSensor: Sensor {
  enum Axis {
    case x, y
  }

  let axis: Axis

  func get(for individual: Individual, on world: World) -> Double {
    switch axis {
    case .x:
      // X component -1,0,1 maps to sensor values 0.0, 0.5, 1.0
      let lastX = individual.lastDirection.asNormalizedCoord().x
      return lastX == 0 ? 0.5 : (lastX == -1 ? 0.0 : 1.0)
    case .y:
      // Y component -1,0,1 maps to sensor values 0.0, 0.5, 1.0
      let lastY = individual.lastDirection.asNormalizedCoord().y
      return lastY == 0 ? 0.5 : (lastY == -1 ? 0.0 : 1.0)
    }
  }
}



