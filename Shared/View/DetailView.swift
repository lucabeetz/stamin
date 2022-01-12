//
//  DetailView.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 07.01.22.
//

import SwiftUI

func updateValue(progress: Progress, editValue: Int, increase: Bool) {
    if increase {
        progress.currentValue += Double(editValue)
    } else {
        progress.currentValue -= Double(editValue)
    }
}

struct DetailView: View {
    @ObservedObject var progress: Progress
    
    let viewModel: SummaryViewModel
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                ProgressBarItem(name: progress.name ?? "", desc: "\(progress.currentValue.cleanValue)/\(progress.goalValue.cleanValue)", unit: progress.unit ?? "", value: Float(progress.currentValue / progress.goalValue), color: progress.color != nil ? Color(UIColor.decode(data: progress.color as! Data)!) : Color.black, iconName: progress.iconName ?? "")
                
                if progress.editValues != nil {
                    ForEach(progress.editValues as! [Int], id: \.self) {editValue in
                        HStack {
                            Button(action: { updateValue(progress: progress, editValue: editValue, increase: false) }) {
                                Text("- " + String(editValue))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .background(.thinMaterial)
                            .cornerRadius(8.0)
                            
                            Button(action: { updateValue(progress: progress, editValue: editValue, increase: true) }) {
                                Text("+ " + String(editValue))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }
                            .background(.thinMaterial)
                            .cornerRadius(8.0)
                        }
                    }
                }
                
                Button(role: .destructive, action: {
                    viewModel.deleteProgress(progress: progress)
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                        Text("Delete")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .background(.thinMaterial)
                    .cornerRadius(8.0)
            }
        }
        .padding(.horizontal)
        .navigationTitle("Nutrition")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SummaryViewModel(repository: HKRepository(), persistenceController: PersistenceController.preview)
        DetailView(progress: PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Progress}) as! Progress, viewModel: viewModel)
    }
}
