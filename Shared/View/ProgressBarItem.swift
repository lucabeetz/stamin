//
//  ProgressBarItem.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 06.01.22.
//

import SwiftUI

struct ProgressBarItemFromProgress: View {
    @ObservedObject var progress: Progress
    
    var body: some View {
        ProgressBarItem(name: progress.name!, desc: "\(progress.currentValue.cleanValue)/\(progress.goalValue.cleanValue)", unit: progress.unit!, value: Float(progress.currentValue / progress.goalValue), color: Color(uiColor: UIColor.decode(data: progress.color as! Data)!), iconName: progress.iconName ?? "")
    }
}

struct ProgressBarItem: View {
    let name: String
    let desc: String
    let unit: String
    let value: Float
    let color: Color
    var iconName: String = ""
    
    var body: some View {
        HStack(spacing: 16.0) {
            if !iconName.isEmpty {
                Image(systemName: iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            }
            
            VStack(alignment: .leading) {
                HStack {
                    Text(name)
                        .font(.callout)
                    
                    Spacer()
                    
                    
                    HStack(alignment: .bottom, spacing: 0.0) {
                        Text(desc)
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(color)
                        Text(unit)
                            .font(.system(.subheadline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(color)
                    }
                }
                
                ProgressView(value: value)
                    .tint(color)
            }
        }
        .padding()
        .background(.thinMaterial)
        .cornerRadius(8.0)
    }
}

struct ProgressBarItem_Previews: PreviewProvider {
    static var previews: some View {
        ProgressBarItem(name: "Lifespan", desc: "101/303PGS", unit: "PGS", value: 0.3, color: .orange)
    }
}

struct ProgressBarItemFromProgress_Previews: PreviewProvider {
    static var previews: some View {
        let progress = PersistenceController.preview.container.viewContext.registeredObjects.first(where: { $0 is Progress}) as! Progress
        
        ProgressBarItemFromProgress(progress: progress)
    }
}
