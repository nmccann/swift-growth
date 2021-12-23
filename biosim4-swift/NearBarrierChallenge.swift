import Foundation

/// Survivors are those within radius of any barrier center. Weighted by distance.
struct NearBarrierChallenge: Challenge {
  func test(_ individual: Indiv, on grid: Grid) -> (Bool, Double) {
    let radius = Double(grid.size.x / 2)

    let distance =
    grid.getBarrierCenters().lazy
      .map { individual.loc - $0 }
      .map(\.length)
      .map(Double.init)
      .min()

    guard let distance = distance else {
      return (false, 0)
    }

    return distance <= radius ? (true, 1.0 - (distance / radius)) : (false, 0)
  }
}

extension Challenge where Self == NearBarrierChallenge {
  static func nearBarrier() -> Self { .init() }
}
