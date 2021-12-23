import Foundation

/// Survivors are all those within the specified radius of the NE corner
struct AltruismSacrificeChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    let size = CGSize(width: grid.size.x, height: grid.size.y)
    let radius = size.width / 4.0 // in 128^2 world, holds 804 agents

    let distance = Double((Coord(x: Int(size.width - size.width / 4.0),
                                 y: Int(size.height - size.height / 4.0)) - individual.loc).length)
    return distance <= radius ? (true, (radius - distance) / radius) : (false, 0)
  }
}

extension Challenge where Self == AltruismSacrificeChallenge {
  static func altruismSacrifice() -> Self { .init() }
}
