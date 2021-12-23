import Foundation

/// Survivors are all those on the left eighth of the arena
struct LeftEighthChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    individual.loc.x < grid.size.x / 8 ? (true, 1) : (false, 0)
  }
}

extension Challenge where Self == LeftEighthChallenge {
  static func leftEighth() -> Self { .init() }
}
