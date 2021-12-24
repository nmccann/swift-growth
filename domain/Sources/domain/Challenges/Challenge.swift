import Foundation

public protocol Challenge {
  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult
  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult
}

extension Challenge {
  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult {
    return result
  }
}

public struct ChallengeResult: Equatable {
  let didPass: Bool
  let score: Double

  var didFail: Bool {
    !didPass
  }

  static func pass(_ score: Double) -> ChallengeResult {
    .init(didPass: true, score: score)
  }

  static func fail(_ score: Double) -> ChallengeResult {
    .init(didPass: false, score: score)
  }
}
