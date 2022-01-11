//
//  ContentView.swift
//  Shared
//
//  Created by Luca Beetz on 06.01.22.
//

import SwiftUI
import HealthKit

struct SummaryView: View {
    var hkRepository: HKRepository = HKRepository()
    
    @ObservedObject var viewModel: SummaryViewModel
    
    init(persistenceController: PersistenceController) {
        // Request HealthKit permissions
        let healthStore = HKHealthStore()
        let objectTypes: Set<HKObjectType> = [
            HKObjectType.activitySummaryType(),
            HKObjectType.workoutType(),
            HKCategoryType(.mindfulSession)
        ]
        healthStore.requestAuthorization(toShare: nil, read: objectTypes) { success, error in
            // Error handling
        }
        
        self.viewModel = SummaryViewModel(repository: hkRepository, persistenceController: persistenceController)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    TitledGroup(category: "Activity", addProgressButton: false) {
                        ActivitySummaryView(viewModel: viewModel)
                            .padding()
                            .background(.thinMaterial)
                            .cornerRadius(8.0)
                        
                        ProgressBarItem(name: "Weekly distance", desc: viewModel.weeklyKilometers.cleanValue + "/25", unit: "KMS", value: Float(viewModel.weeklyKilometers / 25.0), color: .green)
                        
                        ProgressBarItem(name: "Mindfulness today", desc: viewModel.mindfulMinutes.cleanValue + "/15", unit: "MIN", value: Float(viewModel.mindfulMinutes / 15), color: .blue)
                    }
                    
                    ForEach(Array(viewModel.dailyProgressesByCategory.keys.sorted()), id: \.self) { category in
                        TitledGroup(category: category, addProgressButton: true, viewModel: viewModel) {
                            ForEach(viewModel.dailyProgressesByCategory[category]!, id: \.self) { progress in
                                NavigationLink(destination: DetailView(progress: progress, viewModel: viewModel)) {
                                    ProgressBarItemFromProgress(progress: progress)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
//                    TitledGroup(category: "Reading", addProgressButton: true, viewModel: viewModel) {
//                        ProgressBarItem(name: "Lifespan", desc: "101/303", unit: "PGS", value: 0.33, color: .orange, iconName: "book")
//
//                        HStack(spacing: 16.0) {
//                            Image(systemName: "paperclip")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 32, height: 32)
//
//                            VStack(alignment: .leading) {
//                                Text("Attention is all you need")
//                                    .font(.subheadline)
//                                    .fixedSize()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                                Text("https://arxiv.org/abs/1706.03762")
//                                    .font(.subheadline)
//                                    .fixedSize()
//                                    .frame(maxWidth: .infinity, alignment: .leading)
//                            }
//
//                            Image(systemName: "plus")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 32, height: 32)
//                        }
//                        .padding()
//                        .background(.thinMaterial)
//                        .cornerRadius(8.0)
//
//                        ProgressBarItem(name: "Monthly books", desc: "1/5", unit: "", value: 0.2, color: .orange)
//
//                        ProgressBarItem(name: "Weekly papers", desc: "1/5", unit: "", value: 0.2, color: .orange)
//                    }
                    
                    NavigationLink(destination: CreateProgressView(viewModel: viewModel, category: "", categoryProvided: false)) {
                        Text("New category")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top)
                    
                }
                .padding(.horizontal)
            }
            .navigationTitle("Summary")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let persistenceController = PersistenceController.preview
        
        SummaryView(persistenceController: persistenceController)
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
    }
}
