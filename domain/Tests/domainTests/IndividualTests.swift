import XCTest
import Nimble
@testable import domain

class IndividualTests: XCTestCase {
  var grid: Grid!
  var parameters: Params!

  override func setUp() {
    grid = .init(size: (x: 4, y: 4))

  }

  func testFeedForwardSimple() {
    parameters = .stub(maxNumberNeurons: 3,
                       probeDistance: (short: 3, long: 16),
                       sensors: [ConstantSensor(value: 1), ConstantSensor(value: 5)],
                       actions: [MoveXAction(), MoveYAction()])

    let genome: Genome = [.init(sourceType: .sensor, sourceNum: 0, sinkType: .neuron, sinkNum: 0, weight: Gene.weightDivisor),
                          .init(sourceType: .neuron, sourceNum: 0, sinkType: .action, sinkNum: 0, weight: Gene.weightDivisor),
                          .init(sourceType: .sensor, sourceNum: 1, sinkType: .neuron, sinkNum: 1, weight: Gene.weightDivisor),
                          .init(sourceType: .neuron, sourceNum: 1, sinkType: .action, sinkNum: 1, weight: Gene.weightDivisor)]

    var individual = Individual(index: 0,
                                loc: .init(x: 2, y: 2),
                                genome: genome,
                                probeDistance: parameters.probeDistance,
                                maxNumberOfNeurons: parameters.maxNumberNeurons,
                                actions: 2,
                                sensors: 2)

    expect(individual.nnet.neurons[0].driven) == true
    expect(individual.nnet.neurons[0].output) == 0.5

    expect(individual.nnet.neurons[1].driven) == true
    expect(individual.nnet.neurons[1].output) == 0.5

    grid[individual.loc] = .occupied(by: individual)
    let levels = individual.feedForward(simStep: 0, on: grid, with: parameters)

    expect(individual.nnet.neurons[0].driven) == true
    expect(individual.nnet.neurons[0].output) ≈ 0.7615

    expect(individual.nnet.neurons[1].driven) == true
    expect(individual.nnet.neurons[1].output) ≈ 0.9999

    expect(levels).to(haveCount(2))
    expect(levels[0].action is MoveXAction) == true
    expect(levels[0].level) ≈ 0.7615

    expect(levels[1].action is MoveYAction) == true
    expect(levels[1].level) ≈ 0.9999
  }

  func testFeedForwardManyToOne() {
    parameters = .stub(maxNumberNeurons: 1,
                       probeDistance: (short: 3, long: 16),
                       sensors: [ConstantSensor(value: 1), ConstantSensor(value: 2)],
                       actions: [MoveXAction(), MoveYAction()])

    let genome: Genome = [.init(sourceType: .sensor, sourceNum: 0, sinkType: .neuron, sinkNum: 0, weight: Gene.weightDivisor),
                          .init(sourceType: .sensor, sourceNum: 1, sinkType: .neuron, sinkNum: 0, weight: Gene.weightDivisor),
                          .init(sourceType: .neuron, sourceNum: 0, sinkType: .action, sinkNum: 0, weight: Gene.weightDivisor)]

    var individual = Individual(index: 0,
                                loc: .init(x: 2, y: 2),
                                genome: genome,
                                probeDistance: parameters.probeDistance,
                                maxNumberOfNeurons: parameters.maxNumberNeurons,
                                actions: 2,
                                sensors: 2)

    expect(individual.nnet.neurons[0].output) == 0.5

    grid[individual.loc] = .occupied(by: individual)
    let levels = individual.feedForward(simStep: 0, on: grid, with: parameters)

    expect(individual.nnet.neurons[0].output) ≈ 0.9951

    expect(levels).to(haveCount(2))
    expect(levels[0].action is MoveXAction) == true
    expect(levels[0].level) ≈ 0.9951

    expect(levels[1].action is MoveYAction) == true
    expect(levels[1].level) ≈ 0.0
  }

  func testFeedForwardOneToMany() {
    parameters = .stub(maxNumberNeurons: 2,
                       probeDistance: (short: 3, long: 16),
                       sensors: [ConstantSensor(value: 1), ConstantSensor(value: 2)],
                       actions: [MoveXAction(), MoveYAction()])

    let genome: Genome = [.init(sourceType: .sensor, sourceNum: 0, sinkType: .neuron, sinkNum: 0, weight: Gene.weightDivisor),
                          .init(sourceType: .neuron, sourceNum: 0, sinkType: .action, sinkNum: 0, weight: Gene.weightDivisor),
                          .init(sourceType: .neuron, sourceNum: 0, sinkType: .action, sinkNum: 1, weight: Gene.weightDivisor)]

    var individual = Individual(index: 0,
                                loc: .init(x: 2, y: 2),
                                genome: genome,
                                probeDistance: parameters.probeDistance,
                                maxNumberOfNeurons: parameters.maxNumberNeurons,
                                actions: 2,
                                sensors: 2)

    expect(individual.nnet.neurons[0].output) == 0.5

    grid[individual.loc] = .occupied(by: individual)
    let levels = individual.feedForward(simStep: 0, on: grid, with: parameters)

    expect(individual.nnet.neurons[0].driven) == true
    expect(individual.nnet.neurons[0].output) ≈ 0.7615

    expect(levels).to(haveCount(2))
    expect(levels[0].action is MoveXAction) == true
    expect(levels[0].level) ≈ levels[1].1
  }
}

struct ConstantSensor: Sensor {
  let value: Double

  func get(for individual: Individual, simStep: Int, on grid: Grid, with parameters: Params) -> Double {
    value
  }
}