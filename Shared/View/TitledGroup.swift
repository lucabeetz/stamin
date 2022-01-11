//
//  TitledGroup.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 06.01.22.
//

import SwiftUI

struct TitledGroup<Content: View>: View {
    let category: String
    let addProgressButton: Bool
    var viewModel: SummaryViewModel?
    
    @ViewBuilder var groupItems: Content
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text(category)
                    .font(.title2)
                    .fontWeight(.bold)
                
                
                Spacer()
                
                if addProgressButton {
                    NavigationLink(destination: CreateProgressView(viewModel: viewModel!, category: category)) {
                        Text("Add progress")
                            .font(.subheadline)
                    }
                }
            }
            .padding(.top)
            
            groupItems
        }
    }
}

struct TitledGroup_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = SummaryViewModel(repository: HKRepository(), persistenceController: PersistenceController.preview)
        
        TitledGroup(category: "Activity", addProgressButton: true, viewModel: viewModel) {
            
        }
    }
}

struct TitledGroup_PreviewsNoButton: PreviewProvider {
    static var previews: some View {
        TitledGroup(category: "Activity", addProgressButton: false) {
            
        }
    }
}
