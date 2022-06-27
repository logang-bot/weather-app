//
//  CoreDataManager.swift
//  P5_weather_app
//
//  Created by Alvaro Choque on 24/6/22.
//

import Foundation
import CoreData

class CoreDataManager {
    static var shared = CoreDataManager()
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "P5_weather_app")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func getContext() -> NSManagedObjectContext{
        return persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
                print("saved")
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getData<T: NSFetchRequestResult>(queries: [NSPredicate] = []) -> [T] {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<T>(entityName: "WeatherEntry")
        
        fetchRequest.predicate = NSCompoundPredicate(
            andPredicateWithSubpredicates: queries
        )
        
        do {
            let dbWEntries = try context.fetch(fetchRequest)
            return dbWEntries
        } catch(let error) {
            print(error)
        }
        return [T]()
    }
    
    func addElement(element: WeatherEntry) {
//        guard let entity = NSEntityDescription.entity(forEntityName: "WeatherEntry", in: context) else {return}
//        guard let entry = NSManagedObject(entity: entity, insertInto: context) as? WeatherEntry else {return}
//        
//        entry.id = Int16.random(in: 1...10000)
//        entry.urlSearch = urlSearch
//        entry.index = Int32(index)
//        entry.searchDate = Date()
//        entry.place = place
//        
//        try? persistentContainer.viewContext.save()
    }
    
    func deleteElement<T: NSManagedObject>(element: T) {
        let context = persistentContainer.viewContext
        context.delete(element)
        try? context.save()
    }
}
