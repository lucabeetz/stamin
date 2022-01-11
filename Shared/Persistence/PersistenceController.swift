//
//  PersistenceController.swift
//  dun (iOS)
//
//  Created by Luca Beetz on 07.01.22.
//

import Foundation
import SwiftUI
import CoreData


struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        
        let progressWater = Progress(context: controller.container.viewContext)
        progressWater.category = "Nutrition"
        progressWater.name = "Water"
        progressWater.goalValue = 2500
        progressWater.currentValue = 1000
        progressWater.unit = "ML"
        progressWater.editValues = [100, 250, 500] as NSObject
        progressWater.iconName = "drop"
        progressWater.color = UIColor.systemBlue.encode()! as NSObject
        progressWater.startDate = Date()
        progressWater.endDate = Calendar.current.date(byAdding: .day, value: 1, to: progressWater.startDate!)
        
        let progressCalories = Progress(context: controller.container.viewContext)
        progressCalories.category = "Nutrition"
        progressCalories.name = "Calories"
        progressCalories.goalValue = 2500
        progressCalories.currentValue = 800
        progressCalories.unit = "KCAL"
        progressCalories.editValues = [100, 250, 400] as NSObject
        progressCalories.iconName = "flame"
        progressCalories.color = UIColor.systemRed.encode()! as NSObject
        progressCalories.startDate = Date()
        progressCalories.endDate = Calendar.current.date(byAdding: .day, value: 1, to: progressCalories.startDate!)
        
        let progressChinese = Progress(context: controller.container.viewContext)
        progressChinese.category = "Study and Work"
        progressChinese.name = "Chinese"
        progressChinese.goalValue = 30
        progressChinese.currentValue = 3
        progressChinese.unit = "MIN"
        progressChinese.editValues = [1, 5, 10] as NSObject
        progressChinese.color = UIColor.systemCyan.encode()! as NSObject
        progressChinese.startDate = Date()
        progressChinese.endDate = Calendar.current.date(byAdding: .day, value: 1, to: progressChinese.startDate!)
        
        let progressWork = Progress(context: controller.container.viewContext)
        progressWork.category = "Study and Work"
        progressWork.name = "Work"
        progressWork.goalValue = 120
        progressWork.currentValue = 20
        progressWork.unit = "MIN"
        progressWork.editValues = [15, 30, 60] as NSObject
        progressWork.color = UIColor.systemPurple.encode()! as NSObject
        progressWork.startDate = Date()
        progressWork.endDate = Calendar.current.date(byAdding: .day, value: 1, to: progressWork.startDate!)
        
        // Add sample repeating progress
        let repeatingProgressWater = RepeatingProgress(context: controller.container.viewContext)
        repeatingProgressWater.category = "Nutrition"
        repeatingProgressWater.name = "Water"
        repeatingProgressWater.goalValue = 2500
        repeatingProgressWater.unit = "ML"
        repeatingProgressWater.editValues = [100, 250, 500] as NSObject
        repeatingProgressWater.iconName = "drop"
        repeatingProgressWater.color = UIColor.systemBlue.encode()! as NSObject
        
        return controller
    }()
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Main")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error \(error.localizedDescription)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Error handling
            }
        }
    }
    
    func getAllDailyProgresses() -> [Progress] {
        let startDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
        
        let fetchRequest: NSFetchRequest<Progress> = Progress.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "endDate >= %@", startDate as NSDate)
        
        do {
            return try container.viewContext.fetch(fetchRequest)
        } catch {
            // Error handling
            return []
        }
    }
    
    func getAllDailyProgressesByCategory() -> [String: [Progress]] {
        let startDate = Calendar(identifier: .gregorian).startOfDay(for: Date())
        
        let fetchRequest: NSFetchRequest<Progress> = Progress.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "endDate >= %@", startDate as NSDate)
        
        do {
            let progresses = try container.viewContext.fetch(fetchRequest)
            
            // Sort progresses by their respective category
            var progressesByCategory: [String: [Progress]] = [:]
            for progress in progresses {
                let category = progress.category!
                
                if progressesByCategory[category] != nil {
                    progressesByCategory[category]!.append(progress)
                } else {
                    progressesByCategory[category] = [progress]
                }
            }
            
            return progressesByCategory
        } catch {
            // Error handling
            return [:]
        }
    }
    
    func getAllRepeatingProgresses() -> [RepeatingProgress] {
        let fetchRequest: NSFetchRequest<RepeatingProgress> = RepeatingProgress.fetchRequest()
        
        do {
            return try container.viewContext.fetch(fetchRequest)
        } catch {
            // Error handling
            return []
        }
    }
    
    func deleteProgress(progress: Progress) {
        // Delete repeating progress
        if progress.repeatingId != nil {
            do {
                let repeatingProgress = try container.viewContext.existingObject(with: progress.repeatingId as! NSManagedObjectID)
                container.viewContext.delete(repeatingProgress)
            } catch {
                // Error handling
            }
        }
        
        container.viewContext.delete(progress)
    }
    
}
