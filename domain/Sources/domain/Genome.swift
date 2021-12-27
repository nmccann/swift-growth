import Foundation

let NEURON_MIN: Double = -1.0
let NEURON_MAX: Double = 1.0
let NEURON_RANGE: Double = NEURON_MAX - NEURON_MIN

// Each gene specifies one synaptic connection in a neural net. Each
// connection has an input (source) which is either a sensor or another neuron.
// Each connection has an output, which is either an action or another neuron.
// Each connection has a floating point weight derived from a signed 16-bit
// value. The signed integer weight is scaled to a small range, then cubed
// to provide fine resolution near zero.

struct Gene: Equatable {
  enum Source: CaseIterable {
    case sensor, neuron
  }
  
  enum Sink: CaseIterable {
    case action, neuron
  }
  
  var sourceType: Source
  var sourceNum: Int
  var sinkType: Sink
  var sinkNum: Int
  var weight: Int
  
  let f1 = 8.0
  let f2 = 64.0
  
  //Alternative implementation
  //  func weightAsDouble() -> Double {
  //    pow(Double(weight) / f1, 3.0) / f2
  //  }
  
  func weightAsDouble() -> Double {
    Double(weight) / 8192.0
  }
  
  static func makeRandomWeight() -> Int {
    .random(in: 0...0xffff) - 0x8000
  }
}

// An individual's genome is a set of Genes (see Gene comments above). Each
// gene is equivalent to one connection in a neural net. An individual's
// neural net is derived from its set of genes.
typealias Genome = [Gene]

// An individual's "brain" is a neural net specified by a set
// of Genes where each Gene specifies one connection in the neural net (see
// Genome comments above). Each neuron has a single output which is
// connected to a set of sinks where each sink is either an action output
// or another neuron. Each neuron has a set of input sources where each
// source is either a sensor or another neuron. There is no concept of
// layers in the net: it's a free-for-all topology with forward, backwards,
// and sideways connection allowed. Weighted connections are allowed
// directly from any source to any action.

// Currently the genome does not specify the activation function used in
// the neurons. (May be hardcoded to std::tanh() !!!)

// When the input is a sensor, the input value to the sink is the raw
// sensor value of type float and depends on the sensor. If the output
// is an action, the source's output value is interpreted by the action
// node and whether the action occurs or not depends on the action's
// implementation.

// In the genome, neurons are identified by 15-bit unsigned indices,
// which are reinterpreted as values in the range 0..p.genomeMaxLength-1
// by taking the 15-bit index modulo the max number of allowed neurons.
// In the neural net, the neurons that end up connected get new indices
// assigned sequentially starting at 0.

struct NeuralNet {
  var connections: [Gene] // connections are equivalent to genes
  var neurons: [Neuron]
  
  struct Neuron {
    var output: Double
    let driven: Bool // undriven neurons have fixed output values
  }
}

// When a new population is generated and every individual is given a
// neural net, the neuron outputs must be initialized to something:
//Alternative implementation
//func initialNeuronOutput() -> Double {
//  (NEURON_RANGE / 2.0) + NEURON_MIN
//}

func initialNeuronOutput() -> Double {
  0.5
}

// This structure is used while converting the connection list to a
// neural net. This helps us to find neurons that don't feed anything
// so that they can be removed along with all the connections that
// feed the useless neurons. We'll cull neurons with .numOutputs == 0
// or those that only feed themselves, i.e., .numSelfInputs == .numOutputs.
// Finally, we'll renumber the remaining neurons sequentially starting
// at zero using the .remappedNumber member.
struct Node {
  var remappedNumber: Int
  var numOutputs: Int
  var numSelfInputs: Int
  var numInputsFromSensorsOrOtherNeurons: Int
}

// Two neuron renumberings occur: The original genome uses a uint16_t for
// neuron numbers. The first renumbering maps 16-bit unsigned neuron numbers
// to the range 0..p.maxNumberNeurons - 1. After culling useless neurons
// (see comments above), we'll renumber the remaining neurons sequentially
// starting at 0.
typealias NodeMap = [Int: Node] // key is neuron number 0..p.maxNumberNeurons - 1

typealias ConnectionList = [Gene]

// Returns by value a single gene with random members.
// See genome.h for the width of the members.
// ToDo: don't assume the width of the members in gene.
func makeRandomGene() -> Gene {
  .init(sourceType: .allCases.randomElement() ?? .neuron,
        sourceNum: .random(in: 0...0x7fff),
        sinkType: .allCases.randomElement() ?? .neuron,
        sinkNum: .random(in: 0...0x7fff),
        weight: Gene.makeRandomWeight())
}

/// Create a sequence of random genes of random length based on provided range
/// - Parameter range: Indicates the min/max length of resultant sequence
/// - Returns: A sequence of random genes
func makeRandomGenome(_ range: ClosedRange<Int>) -> Genome {
  (0..<Int.random(in: range)).map { _ in
    makeRandomGene()
  }
}

// Convert the indiv's genome to a renumbered connection list.
// This renumbers the neurons from their uint16_t values in the genome
// to the range 0..p.maxNumberNeurons - 1 by using a modulo operator.
// Sensors are renumbered 0..Sensor::NUM_SENSES - 1
// Actions are renumbered 0..Action::NUM_ACTIONS - 1
func makeRenumberedConnectionList(genome: Genome, maxNumberNeurons: Int, actions: Int, sensors: Int) -> ConnectionList {
  genome.map { gene in
    var gene = gene
    
    switch gene.sourceType {
    case .neuron: gene.sourceNum %= maxNumberNeurons
    case .sensor: gene.sourceNum %= sensors
    }
    
    switch gene.sinkType {
    case .neuron: gene.sinkNum %= maxNumberNeurons
    case .action: gene.sinkNum %= actions
    }
    
    return gene
  }
}

// Scan the connections and make a list of all the neuron numbers
// mentioned in the connections. Also keep track of how many inputs and
// outputs each neuron has.
func makeNodeMap(from connections: ConnectionList, maxNumberNeurons: Int) -> NodeMap {
  var nodeMap: NodeMap = [:]
  for connection in connections {
    if case .neuron = connection.sinkType {
      assert(connection.sinkNum < maxNumberNeurons)
      var it = nodeMap[connection.sinkNum] ?? .init(remappedNumber: 0,
                                              numOutputs: 0,
                                              numSelfInputs: 0,
                                              numInputsFromSensorsOrOtherNeurons: 0)

      if case .neuron = connection.sourceType, connection.sourceNum == connection.sinkNum {
        it.numSelfInputs += 1
      } else {
        it.numInputsFromSensorsOrOtherNeurons += 1
      }

      nodeMap[connection.sinkNum] = it
    }

    if case .neuron = connection.sourceType {
      assert(connection.sourceNum < maxNumberNeurons)
      var it = nodeMap[connection.sourceNum] ?? .init(remappedNumber: 0,
                                                numOutputs: 0,
                                                numSelfInputs: 0,
                                                numInputsFromSensorsOrOtherNeurons: 0)


      it.numOutputs += 1
      nodeMap[connection.sourceNum] = it
    }
  }
  return nodeMap
}

// During the culling process, we will remove any neuron that has no outputs,
// and all the connections that feed the useless neuron.
func removeConnectionsToNeuron(connections: inout ConnectionList, nodeMap: inout NodeMap, neuronNumber: Int) {
  connections.removeAll {
    if case .neuron = $0.sinkType, $0.sinkNum == neuronNumber {
      // Remove the connection. If the connection source is from another
      // neuron, also decrement the other neuron's numOutputs:
      if case .neuron = $0.sourceType {
        nodeMap[$0.sourceNum]?.numOutputs -= 1
      }
      return true
    } else {
      return false
    }
  }
}

// If a neuron has no outputs or only outputs that feed itself, then we
// remove it along with all connections that feed it. Reiterative, because
// after we remove a connection to a useless neuron, it may result in a
// different neuron having no outputs.
func cullUselessNeurons(connections: inout ConnectionList, nodeMap: inout NodeMap, maxNumberNeurons: Int) {
  var allDone = false
  while !allDone {
    allDone = true
    var keysToRemove: [Int] = []
    for itNeuron in nodeMap {
      assert(itNeuron.key < maxNumberNeurons)
      // We're looking for neurons with zero outputs, or neurons that feed itself
      // and nobody else:
      if itNeuron.value.numOutputs == itNeuron.value.numSelfInputs { // could be 0
        allDone = false
        // Find and remove connections from sensors or other neurons
        removeConnectionsToNeuron(connections: &connections, nodeMap: &nodeMap, neuronNumber: itNeuron.key)
        keysToRemove.append(itNeuron.key)
      }
    }
    
    //TODO: Determine a better way to iterate and remove keys in-place
    for key in keysToRemove {
      nodeMap.removeValue(forKey: key)
    }
  }
}

/// This function is used when an agent is spawned. This function converts the
/// agent's inherited genome into the agent's neural net brain. There is a close
/// correspondence between the genome and the neural net, but a connection
/// specified in the genome will not be represented in the neural net if the
/// connection feeds a neuron that does not itself feed anything else.
/// Neurons get renumbered in the process:
/// 1. Create a set of referenced neuron numbers where each index is in the
///    range 0..p.genomeMaxLength-1, keeping a count of outputs for each neuron.
/// 2. Delete any referenced neuron index that has no outputs or only feeds itself.
/// 3. Renumber the remaining neurons sequentially starting at 0.
func createWiringFromGenome(_ genome: Genome, maxNumberNeurons: Int, actions: Int, sensors: Int) -> NeuralNet {
  var nnet = NeuralNet(connections: [], neurons: [])
  
  // Convert the indiv's genome to a renumbered connection list
  var connectionList = makeRenumberedConnectionList(genome: genome, maxNumberNeurons: maxNumberNeurons, actions: actions, sensors: sensors) // synaptic connections
  
  // Make a node (neuron) map and their number of inputs and outputs from the renumbered connection list
  var nodeMap = makeNodeMap(from: connectionList, maxNumberNeurons: maxNumberNeurons)
  
  // Find and remove neurons that don't feed anything or only feed themself.
  // This reiteratively removes all connections to the useless neurons.
  cullUselessNeurons(connections: &connectionList, nodeMap: &nodeMap, maxNumberNeurons: maxNumberNeurons)
  
  // The neurons map now has all the referenced neurons, their neuron numbers, and
  // the number of outputs for each neuron. Now we'll renumber the neurons
  // starting at zero.
  
  assert(nodeMap.count <= maxNumberNeurons)
  var newNumber = 0;

  nodeMap = nodeMap.mapValues { node in
    var node = node
    assert(node.numOutputs != 0)
    node.remappedNumber = newNumber
    newNumber += 1
    return node
  }

  // Create the indiv's connection list in two passes:
  // First the connections to neurons, then the connections to actions.
  // This ordering optimizes the feed-forward function in feedForward.cpp.
  
  nnet.connections.removeAll()
  
  // First, the connections from sensor or neuron to a neuron
  for conn in connectionList {
    if case .neuron = conn.sinkType {
      var newConn = conn
      // fix the destination neuron number
      newConn.sinkNum = nodeMap[newConn.sinkNum]?.remappedNumber ?? newConn.sinkNum
      // if the source is a neuron, fix its number too
      if case .neuron = newConn.sourceType {
        newConn.sourceNum = nodeMap[newConn.sourceNum]?.remappedNumber ?? newConn.sourceNum
      }
      nnet.connections.append(newConn)
    }
  }
  
  // Last, the connections from sensor or neuron to an action
  for conn in connectionList {
    if case .action = conn.sinkType {
      var newConn = conn
      // if the source is a neuron, fix its number
      if case .neuron = newConn.sourceType {
        newConn.sourceNum = nodeMap[newConn.sourceNum]?.remappedNumber ?? newConn.sourceNum
      }
      nnet.connections.append(newConn)
    }
  }
  
  // Create the indiv's neural node list
  nnet.neurons = (0..<nodeMap.count).map {
    .init(output: initialNeuronOutput(),
          driven: nodeMap[$0]?.numInputsFromSensorsOrOtherNeurons != 0)
  }
  
  return nnet
}

// This generates a child genome from one or two parent genomes.
// If the parameter p.sexualReproduction is true, two parents contribute
// genes to the offspring. The new genome may undergo mutation.
// Must be called in single-thread mode between generations
func generateChildGenome(parentGenomes: [Genome], with parameters: Params) -> Genome {
  // random parent (or parents if sexual reproduction) with random
  // mutations
  var genome: Genome
  
  var parent1Idx: Int
  var parent2Idx: Int
  
  // Choose two parents randomly from the candidates. If the parameter
  // p.chooseParentsByFitness is false, then we choose at random from
  // all the candidate parents with equal preference. If the parameter is
  // true, then we give preference to candidate parents according to their
  // score. Their score was computed by the survival/selection algorithm
  // in survival-criteria.cpp.
  if parameters.chooseParentsByFitness && parentGenomes.count > 1 {
    parent1Idx = .random(in: 1..<parentGenomes.count)
    parent2Idx = .random(in: 0..<parent1Idx)
  } else {
    parent1Idx = .random(in: 0..<parentGenomes.count)
    parent2Idx = .random(in: 0..<parentGenomes.count)
  }
  
  let g1 = parentGenomes[parent1Idx]
  let g2 = parentGenomes[parent2Idx]
  
  if g1.isEmpty || g2.isEmpty {
    preconditionFailure("Invalid genome")
  }
  
  func overlayWithSliceOf(gShorter: Genome) {
    var index0 = Int.random(in: 0..<gShorter.count)
    var index1 = Int.random(in: 0...gShorter.count)
    if index0 > index1 {
      swap(&index0, &index1)
    }
    
    genome.replaceSubrange(index0..<index1, with: gShorter[index0..<index1])
  }
  
  if parameters.sexualReproduction {
    if g1.count > g2.count {
      genome = g1
      overlayWithSliceOf(gShorter: g2)
      assert(!genome.isEmpty)
    } else {
      genome = g2
      overlayWithSliceOf(gShorter: g1)
      assert(!genome.isEmpty)
    }
  } else {
    genome = g2
    assert(!genome.isEmpty)
  }
  
  genome = randomInsertDeletion(genome: genome, with: parameters)
  assert(!genome.isEmpty)
  genome = applyPointMutations(genome: genome, with: parameters.pointMutationRate)
  assert(!genome.isEmpty)
  assert(genome.count <= parameters.genomeMaxLength)
  
  return genome
}

// This applies a point mutation at a random bit in a genome.
func randomBitFlip(genome: Genome) -> Genome {
  var genome = genome
  let method = 1
  
  let byteIndex = Int.random(in: 0..<genome.count)
  let elementIndex = Int.random(in: 0..<genome.count)
  let bitIndex8 = 1 << Int.random(in: 0...7)
  
  switch method {
  case 0: fatalError()
    //TODO: Not sure how to do method 0 in Swift
  case 1:
    //TODO: Update source/sink type to work as expected - currently it isn't a single bit flip
    //and it's possible to randomly select the original source/sink (ex. no change), which the
    //original implementation wouldn't allow
    let chance = Double.random(in: 0...1)
    switch chance {
    case 0.0..<0.2: genome[elementIndex].sourceType = Gene.Source.allCases.randomElement() ?? .neuron
    case 0.2..<0.4: genome[elementIndex].sinkType = Gene.Sink.allCases.randomElement() ?? .neuron
    case 0.4..<0.6: genome[elementIndex].sourceNum ^= bitIndex8
    case 0.6..<0.8: genome[elementIndex].sinkNum ^= bitIndex8
    default: genome[elementIndex].weight ^= 1 << Int.random(in: 1...15)
    }
    //TODO: Implement
  default: assert(false)
  }

  return genome
}

// If the genome is longer than the prescribed length, and if it's longer
// than one gene, then we remove genes from the front or back. This is
// used only when the simulator is configured to allow genomes of
// unequal lengths during a simulation.
func cropLength(genome: inout Genome, length: Int) {
  //TODO
}

// Inserts or removes a single gene from the genome. This is
// used only when the simulator is configured to allow genomes of
// unequal lengths during a simulation.
func randomInsertDeletion(genome: Genome, with parameters: Params) -> Genome {
  guard Double.random(in: 0...1) < parameters.geneInsertionDeletionRate else {
    return genome
  }

  var genome = genome

  if Double.random(in: 0...1) < parameters.deletionRatio {
    // deletion
    if genome.count > 1 {
      genome.remove(at: .random(in: 0..<genome.count))
    }
  } else if genome.count < parameters.genomeMaxLength {
    // insertion
    //genome.insert(genome.begin() + randomUint(0, genome.size() - 1), makeRandomGene()); //In original implementation
    genome.append(makeRandomGene())
  }

  return genome
}

// This function causes point mutations in a genome with a probability defined
// by the parameter p.pointMutationRate.
func applyPointMutations(genome: Genome, with rate: Double) -> Genome {
  var genome = genome

  for _ in 0..<genome.count {
    if Double.random(in: 0...1) < rate {
      genome = randomBitFlip(genome: genome)
    }
  }

  return genome
}
