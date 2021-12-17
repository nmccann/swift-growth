import Foundation

// Each gene specifies one synaptic connection in a neural net. Each
// connection has an input (source) which is either a sensor or another neuron.
// Each connection has an output, which is either an action or another neuron.
// Each connection has a floating point weight derived from a signed 16-bit
// value. The signed integer weight is scaled to a small range, then cubed
// to provide fine resolution near zero.

let SENSOR = 1 // always a source
let ACTION = 1 // always a sink
let NEURON = 0 // can be either a source or sink

struct Gene: Equatable {
  let sourceType: Int
  var sourceNum: Int
  let sinkType: Int
  var sinkNum: Int
  let weight: Int

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
    .random(in: 0...0xefff) - 0x8000
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
  .init(sourceType: Bool.random() ? SENSOR : NEURON,
        sourceNum: .random(in: 0...0x7fff),
        sinkType: Bool.random() ? NEURON : ACTION,
        sinkNum: .random(in: 0...0x7fff),
        weight: Gene.makeRandomWeight())
}

// Returns by value a single genome with random genes.
func makeRandomGenome() -> Genome {
  (0..<Int.random(in: p.genomeInitialLengthMin...p.genomeInitialLengthMax)).map { _ in
    makeRandomGene()
  }
}

// Convert the indiv's genome to a renumbered connection list.
// This renumbers the neurons from their uint16_t values in the genome
// to the range 0..p.maxNumberNeurons - 1 by using a modulo operator.
// Sensors are renumbered 0..Sensor::NUM_SENSES - 1
// Actions are renumbered 0..Action::NUM_ACTIONS - 1
func makeRenumberedConnectionList(connectionList: inout ConnectionList, genome: Genome) {
  //TODO: Confirm that behaviour is the same as original
  connectionList.removeAll()
  for gene in genome {
    var conn = gene

    if conn.sourceType == NEURON {
      conn.sourceNum %= p.maxNumberNeurons
    } else {
      conn.sourceNum %= Sensor.enabled.count
    }

    if conn.sinkType == NEURON {
      conn.sinkNum %= p.maxNumberNeurons
    } else {
      conn.sinkNum %= Action.enabled.count
    }

    connectionList.append(conn)
  }
}

// Scan the connections and make a list of all the neuron numbers
// mentioned in the connections. Also keep track of how many inputs and
// outputs each neuron has.
func makeNodeList(nodeMap: inout NodeMap, connectionList: inout ConnectionList) {
  nodeMap.removeAll()
  for conn in connectionList {
    if conn.sinkType == NEURON {
      assert(conn.sinkNum < p.maxNumberNeurons)
      var it = nodeMap[conn.sinkNum] ?? .init(remappedNumber: 0,
                                              numOutputs: 0,
                                              numSelfInputs: 0,
                                              numInputsFromSensorsOrOtherNeurons: 0)

      if conn.sourceType == NEURON && conn.sourceNum == conn.sinkNum
      {
        it.numSelfInputs += 1
      } else {
        it.numInputsFromSensorsOrOtherNeurons += 1
      }

      nodeMap[conn.sinkNum] = it
    }

    if conn.sourceType == NEURON {
      assert(conn.sourceNum < p.maxNumberNeurons)
      var it = nodeMap[conn.sourceNum] ?? .init(remappedNumber: 0,
                                                numOutputs: 0,
                                                numSelfInputs: 0,
                                                numInputsFromSensorsOrOtherNeurons: 0)


      it.numOutputs += 1
      nodeMap[conn.sourceNum] = it
    }
  }
}

// During the culling process, we will remove any neuron that has no outputs,
// and all the connections that feed the useless neuron.
//TODO: Verify that this behaves as expected - changed quite a bit from original implementation
func removeConnectionsToNeuron(connections: inout ConnectionList, nodeMap: inout NodeMap, neuronNumber: Int) {
  connections.removeAll {
    if $0.sinkType == NEURON && $0.sinkNum == neuronNumber {
      // Remove the connection. If the connection source is from another
      // neuron, also decrement the other neuron's numOutputs:
      if $0.sourceType == NEURON {
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
func cullUselessNeurons(connections: inout ConnectionList, nodeMap: inout NodeMap) {
  var allDone = false
  while !allDone {
    allDone = true
    var keysToRemove: [Int] = []
    for itNeuron in nodeMap {
      assert(itNeuron.key < p.maxNumberNeurons)
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
func createWiringFromGenome(_ genome: Genome) -> NeuralNet {
  var nodeMap: NodeMap = [:]  // list of neurons and their number of inputs and outputs
  var connectionList: ConnectionList = [] // synaptic connections
  var nnet = NeuralNet(connections: [], neurons: [])

  // Convert the indiv's genome to a renumbered connection list
  makeRenumberedConnectionList(connectionList: &connectionList, genome: genome);

  // Make a node (neuron) list from the renumbered connection list
  makeNodeList(nodeMap: &nodeMap, connectionList: &connectionList);

  // Find and remove neurons that don't feed anything or only feed themself.
  // This reiteratively removes all connections to the useless neurons.
  cullUselessNeurons(connections: &connectionList, nodeMap: &nodeMap);

  // The neurons map now has all the referenced neurons, their neuron numbers, and
  // the number of outputs for each neuron. Now we'll renumber the neurons
  // starting at zero.

  assert(nodeMap.count <= p.maxNumberNeurons);
  var newNumber = 0;

  for var node in nodeMap {
    assert(node.value.numOutputs != 0)
    node.value.remappedNumber = newNumber
    newNumber += 1
  }

  // Create the indiv's connection list in two passes:
  // First the connections to neurons, then the connections to actions.
  // This ordering optimizes the feed-forward function in feedForward.cpp.

  nnet.connections.removeAll()

  // First, the connections from sensor or neuron to a neuron
  for conn in connectionList {
    if conn.sinkType == NEURON {
      var newConn = conn
      // fix the destination neuron number
      newConn.sinkNum = nodeMap[newConn.sinkNum]?.remappedNumber ?? newConn.sinkNum
      // if the source is a neuron, fix its number too
      if newConn.sourceType == NEURON {
        newConn.sourceNum = nodeMap[newConn.sourceNum]?.remappedNumber ?? newConn.sourceNum
      }
      nnet.connections.append(newConn)
    }
  }

  // Last, the connections from sensor or neuron to an action
  for conn in connectionList {
    if conn.sinkType == ACTION {
      var newConn = conn
      // if the source is a neuron, fix its number
      if newConn.sourceType == NEURON {
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
func generateChildGenome(parentGenomes: inout [Genome]) -> Genome {
  //TODO: Implement correctly
  makeRandomGenome()
}
