import Foundation

/*
 At the end of each sim step, this function is called in single-thread
 mode to take care of several things:
 
 1. We may kill off some agents if a "radioactive" scenario is in progress.
 2. We may flag some agents as meeting some challenge criteria, if such
 a scenario is in progress.
 3. We then drain the deferred death queue.
 4. We then drain the deferred movement queue.
 5. We fade the signal layer(s) (pheromones).
 6. We save the resulting world condition as a single image frame (if
 p.saveVideo is true).
 */
func endOfSimStep(_ simStep: Int, generation: Int) {
  switch p.challenge {
  case .radioactiveWalls:
    // During the first half of the generation, the west wall is radioactive,
    // where X == 0. In the last half of the generation, the east wall is
    // radioactive, where X = the area width - 1. There's an exponential
    // falloff of the danger, falling off to zero at the arena half line.
    let radioactiveX = (simStep < p.stepsPerGeneration / 2) ? 0 : p.sizeX - 1

    for indiv in peeps.individuals where indiv.alive {
      let distanceFromRadioactiveWall = Double(abs(indiv.loc.x - radioactiveX))
      if distanceFromRadioactiveWall < Double(p.sizeX / 2) {
        let chanceOfDeath = 1.0 / distanceFromRadioactiveWall
        if Double.random(in: 0...1) < chanceOfDeath {
          peeps.queueForDeath(indiv)
        }
      }
    }


  case .touchAnyWall:
    // If the individual is touching any wall, we set its challengeFlag to true.
    // At the end of the generation, all those with the flag true will reproduce.
    for i in 0..<p.population {
      if isOnEdge(indiv: peeps[i], of: grid) {
        peeps[i].challengeBits = 1
      }
    }

  case .locationSequence:
    // If this challenge is enabled, the individual gets a bit set in their challengeBits
    // member if they are within a specified radius of a barrier center. They have to
    // visit the barriers in sequential order.
    let radius = 9.0
    for i in 0..<p.population {
      let indiv = peeps[i]

      //TODO: Possible performance improvement, use challenge bits to skip barriers
      //on subsequent iterations
      for (n, center) in grid.getBarrierCenters().enumerated() {
        let bit = 1 << n

        if indiv.challengeBits & bit == 0 {
          if Double((indiv.loc - center).length) <= radius {
            peeps[i].challengeBits |= bit
          }

          //Break out of loop so additional barriers are ignored until next iteration
          break
        }
      }
    }

  default:
    break
  }
  
  peeps.drainDeathQueue()
  peeps.drainMoveQueue()
  signals.fade(layer: 0) // takes layerNum
  
  //TODO: Support saving video?
}
