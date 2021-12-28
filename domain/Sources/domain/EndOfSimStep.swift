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
func endOfSimStep(_ simStep: Int, generation: Int, on grid: Grid, with parameters: Params) {
  grid.drainDeathQueue()
  grid.drainMoveQueue()
  
  signals.layers.indices.forEach { index in
    signals.fade(layer: index, by: SIGNAL_DAMPING)
  }
  //TODO: Support saving video?
}
