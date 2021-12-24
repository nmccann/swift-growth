import Foundation

/// All survivors pass
struct NoChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    return individual.alive ? (true, 1) : (false, 0)
  }
}
