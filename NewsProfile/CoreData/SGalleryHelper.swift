//
//  SGalleryHelper.swift
//  NewsProfile
//
//  Created by Apple on 17/05/25.
//

import UIKit
import Foundation
import CoreData

class SGalleryHelper: NSObject {
    static let shared = SGalleryHelper()
    var allFiles: [NSManagedObject] = []
    private override init() { }
    func getAllDataFromNews() -> [NewsDataModel] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SGalleryInfo")
        do {
            allFiles = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        var galleryList = [NewsDataModel]()
        for obj in allFiles {
            let tmp: NewsDataModel = NewsDataModel()
            galleryList.append(tmp.initWithData(galleryList: obj))
        }
        return galleryList.reversed()
    }
    
    func deleteNewsData(withId id: String) {
        // Access the AppDelegate and Managed Object Context
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Failed to retrieve AppDelegate")
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        // Create a fetch request for the entity
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SGalleryInfo")
        fetchRequest.predicate = NSPredicate(format: "name == %@", id) // Replace "id" with your unique identifier field

        do {
            // Fetch objects matching the predicate
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToDelete = objects.first {
                // Delete the object
                managedContext.delete(objectToDelete)
                
                // Save changes to persist the deletion
                try managedContext.save()
                print("Deleted object with id: \(id)")
            } else {
                print("No object found with id: \(id)")
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }
    
    func newsItemExists(id: String, name: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SGalleryInfo")
        request.predicate = NSPredicate(format: "id == %@ AND name == %@", id, name)
        request.fetchLimit = 1
        do {
            let count = try context.count(for: request)
            return count > 0
        } catch {
            print("Error checking existing item: \(error)")
            return false
        }
    }
    func saveData(galleryInfo: [String: Any])  {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "SGalleryInfo",
                                                in: managedContext)!
        
        let newGallery = NSManagedObject(entity: entity,
                                         insertInto: managedContext)
        
        newGallery.setValuesForKeys(galleryInfo)
        do {
            try managedContext.save()
            print("saved")
        } catch {
            print("Failed saving")
        }
    }
    
    
    func getFileIndex() -> Int {
            guard
                let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return 0
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "SGalleryInfo")
            
                // print("fetchRequest",fetchRequest)
            do {
                allFiles = try managedContext.fetch(fetchRequest)
                //print("allFiles",allFiles)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
            }
            if allFiles.count > 0 {
                let index = allFiles.last!.value(forKey: "index") as? Int
                return index!+1
                
            }
             return 0
        }
    
}
