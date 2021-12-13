import Foundation

enum RunMode: Int {
  case STOP, RUN, PAUSE, ABORT
}

// Some of the survival challenges to try. Some are interesting, some
// not so much. Fine-tune the challenges by tweaking the corresponding code
// in survival-criteria
let CHALLENGE_CIRCLE = 0
let CHALLENGE_RIGHT_HALF = 1
let CHALLENGE_RIGHT_QUARTER = 2
let CHALLENGE_STRING = 3
let CHALLENGE_CENTER_WEIGHTED = 4
let CHALLENGE_CENTER_UNWEIGHTED = 40
let CHALLENGE_CORNER = 5
let CHALLENGE_CORNER_WEIGHTED = 6
let CHALLENGE_MIGRATE_DISTANCE = 7
let CHALLENGE_CENTER_SPARSE = 8
let CHALLENGE_LEFT_EIGHTH = 9
let CHALLENGE_RADIOACTIVE_WALLS = 10
let CHALLENGE_AGAINST_ANY_WALL = 11
let CHALLENGE_TOUCH_ANY_WALL = 12
let CHALLENGE_EAST_WEST_EIGHTHS = 13
let CHALLENGE_NEAR_BARRIER = 14
let CHALLENGE_PAIRS = 15
let CHALLENGE_LOCATION_SEQUENCE = 16
let CHALLENGE_ALTRUISM = 17
let CHALLENGE_ALTRUISM_SACRIFICE = 18

let runMode = RunMode.STOP
let p = Params.defaults
let grid = Grid(sizeX: p.sizeX, sizeY: p.sizeY) // 2D arena where the individuals live
//let signals = Signals()  // pheromone layers
//let peeps = Peeps() // container of all the individuals
