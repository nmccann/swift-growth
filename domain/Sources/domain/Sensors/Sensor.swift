import Foundation

let SENSOR_MIN: Double = 0.0
let SENSOR_MAX: Double = 1.0
let SENSOR_RANGE = SENSOR_MAX - SENSOR_MIN

public protocol Sensor {
  func get(for individual: Individual, on world: World) -> Double
}
