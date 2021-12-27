import Foundation
import Surge

/********************************************************************************
 This function does a neural net feed-forward operation, from sensor (input) neurons
 through internal neurons to action (output) neurons. The feed-forward
 calculations are evaluated once each simulator step (simStep).
 
 There is no back-propagation in this simulator. Once an individual's neural net
 brain is wired at birth, the weights and topology do not change during the
 individual's lifetime.
 
 The data structure Indiv::neurons contains internal neurons, and Indiv::connections
 holds the connections between the neurons.
 
 We have three types of neurons:
 
 input sensors - each gives a value in the range SENSOR_MIN.. SENSOR_MAX (0.0..1.0).
 Values are obtained from getSensor().
 
 internal neurons - each takes inputs from sensors or other internal neurons;
 each has output value in the range NEURON_MIN..NEURON_MAX (-1.0..1.0). The
 output value for each neuron is stored in Indiv::neurons[] and survives from
 one simStep to the next. (For example, a neuron that feeds itself will use
 its output value that was latched from the previous simStep.) Inputs to the
 neurons are summed each simStep in a temporary container and then discarded
 after the neurons' outputs are computed.
 
 action (output) neurons - each takes inputs from sensors or other internal
 neurons; In this function, each has an output value in an arbitrary range
 (because they are the raw sums of zero or more weighted inputs).
 The values of the action neurons are saved in local container
 actionLevels[] which is returned to the caller by value (thanks RVO).
 ********************************************************************************/
extension Indiv {
  mutating func feedForward(simStep: Int, on grid: Grid, with parameters: Params) -> [(Action, Double)] {
    // This container is used to return values for all the action outputs. This array
    // contains one value per action neuron, which is the sum of all its weighted
    // input connections. The sum has an arbitrary range. Return by value assumes compiler
    // return value optimization.
    var levels: [Int: Double] = [:]

    // Weighted inputs to each neuron are summed in neuronAccumulators[]
    var neuronAccumulators: [Double] = .init(repeating: 0.0, count: nnet.neurons.count)

    // Connections were ordered at birth so that all connections to neurons get
    // processed here before any connections to actions. As soon as we encounter the
    // first connection to an action, we'll pass all the neuron input accumulators
    // through a transfer function and update the neuron outputs in the indiv,
    // except for undriven neurons which act as bias feeds and don't change. The
    // transfer function will leave each neuron's output in the range -1.0..1.0.
    var neuronOutputsComputed = false
    
    for conn in nnet.connections {
      if case .action = conn.sinkType, !neuronOutputsComputed {
        // We've handled all the connections from sensors and now we are about to
        // start on the connections to the action outputs, so now it's time to
        // update and latch all the neuron outputs to their proper range (-1.0..1.0)
        let clampedNeuronAccumulators = Surge.tanh(neuronAccumulators)
        
        for i in nnet.neurons.indices {
          if nnet.neurons[i].driven {
            nnet.neurons[i].output = clampedNeuronAccumulators[i]
          }
        }
        neuronOutputsComputed = true;
      }

      // Obtain the connection's input value from a sensor neuron or other neuron
      // The values are summed for now, later passed through a transfer function
      var inputVal: Double = 0.0

      if case .sensor = conn.sourceType {
        if parameters.sensors.count > conn.sourceNum {
          let sensor = parameters.sensors[conn.sourceNum]
          inputVal = sensor.get(for: self, simStep: simStep, on: grid, with: parameters)
        }
      } else {
        inputVal = nnet.neurons[conn.sourceNum].output;
      }

      // Weight the connection's value and add to neuron accumulator or action accumulator.
      // The action and neuron accumulators will therefore contain +- float values in
      // an arbitrary range.
      if case .action = conn.sinkType {
        levels[conn.sinkNum, default: 0.0] += inputVal * conn.weightAsDouble()
      } else {
        neuronAccumulators[conn.sinkNum] += inputVal * conn.weightAsDouble()
      }
    }

    return parameters.actions.enumerated().map { ($1, levels[$0, default: 0.0]) }
  }
}
