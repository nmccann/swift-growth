import Foundation

/// Survivors are those that contacted one or more specified locations in a sequence,
/// ranked by the number of locations contacted. There will be a bit set in their
/// challengeBits member for each location contacted.
struct LocationSequenceChallenge: Challenge {
  let radius: Double

  func modify(_ result: ActionResult, at step: Int, on grid: Grid) -> ActionResult {
    // If this challenge is enabled, the individual gets a bit set in their challengeBits
    // member if they are within a specified radius of a barrier center. They have to
    // visit the barriers in sequential order.
    var result = result


    //TODO: Possible performance improvement, use challenge bits to skip barriers
    //on subsequent iterations
    for (n, center) in grid.getBarrierCenters().enumerated() {
      let bit = 1 << n

      if result.indiv.challengeBits & bit == 0 {
        if Double((result.indiv.loc - center).length) <= radius {
          result.indiv.challengeBits |= bit
        }

        //Break out of loop so additional barriers are ignored until next iteration
        break
      }
    }

    return result
  }

  func test(_ individual: Indiv, on grid: Grid) -> ChallengeResult {
    let bits = individual.challengeBits
    let count = bits.nonzeroBitCount
    let maxNumberOfBits = MemoryLayout.size(ofValue: bits) * 8

    return count > 0 ? .pass(Double(count) / Double(maxNumberOfBits)) : .fail(0)
  }
}

extension Challenge where Self == LocationSequenceChallenge {
  static func locationSequence(radius: Double = 9.0) -> Self {
    .init(radius: radius)
  }
}