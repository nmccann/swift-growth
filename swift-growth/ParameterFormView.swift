import SwiftUI
import domain

struct ParameterFormView: View {
  @Binding var parameters: Parameters

  var body: some View {
    Form {
      Group {
        TextFieldStepper("Population", value: $parameters.population)
        TextFieldStepper("Steps Per Generation", value: $parameters.stepsPerGeneration)
        TextFieldStepper("Max Generations", value: $parameters.maxGenerations)
        TextFieldStepper("Signal Layers", value: $parameters.signalLayers)
        TextFieldStepper("Genome Max Length", value: $parameters.genomeMaxLength)
        TextFieldStepper("Max Neurons", value: $parameters.maxNumberNeurons)
        TextFieldStepper("Point Mutation Rate", value: $parameters.pointMutationRate)
        TextFieldStepper("Grid Width", value: .init(get: { parameters.size.width },
                                                    set: { parameters.size = .init(width: $0,
                                                                                   height: parameters.size.height)}))
        TextFieldStepper("Grid Height", value: .init(get: { parameters.size.height },
                                                     set: { parameters.size = .init(width: parameters.size.width,
                                                                                    height: $0)}))
        TextFieldStepper("Initial Responsiveness", value: $parameters.initialResponsiveness, step: 0.05)
      }

      Group {
        Slider(value: $parameters.geneInsertionDeletionRate, in: 0.0...1.0, step: 0.0001, label: {
          Text("Gene Insertion/Deletion Rate – \(parameters.geneInsertionDeletionRate)")
        })

        Slider(value: $parameters.deletionRatio, in: 0.0...1.0, step: 0.01, label: {
          Text("Deletion Ratio – \(parameters.deletionRatio)")
        })

        Toggle("Sexual Reproduction", isOn: $parameters.sexualReproduction)
      }

      Group {
        Toggle("Parents By Fitness", isOn: $parameters.chooseParentsByFitness)
        Toggle("Persist Manual Barriers", isOn: $parameters.shouldPersistManualBarriers)
        Slider(value: $parameters.signalSensorRadius.asDouble, in: 0...16, step: 1, label: {
          Text("Signal Sensor Radius – \(parameters.signalSensorRadius)")
        })
      }
    }
  }
}
