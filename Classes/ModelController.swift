//
//  ModelController.swift
//  FUMVC
//
//  Created by Mike Post on 2018-11-16.
//  Copyright © 2018 Mike Post. All rights reserved.
//

import CoreData

public class ModelController {
	
	// MARK: - Properties
	
	private var modelName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
	
	lazy var persistentContainer: NSPersistentContainer = {
		
		let container = NSPersistentContainer(name: modelName)
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}			
		})
		return container
	}()
	
	lazy var mainMOC: NSManagedObjectContext = {
		return persistentContainer.viewContext
	}()
	
	lazy var backgroundMOC: NSManagedObjectContext = {
		return persistentContainer.newBackgroundContext()
	}()		
	
	// MARK: - Convenience Init
	
	convenience init(modelName model: String) {
		self.init()
		modelName = model
	}
	
}

// MARK: - Add
extension ModelController {
	
	func add<M: NSManagedObject>(_ type: M.Type) -> M? {
		
		var modelObject: M?
		let context = persistentContainer.viewContext
		
		if let entity = NSEntityDescription.entity(forEntityName: M.description(),
												   in: context) {
			
			modelObject = M(entity: entity, insertInto: context)
		}
		return modelObject
	}
}


// MARK: - Fetch
extension ModelController {
	
	func total<M: NSManagedObject>(_ type: M.Type) -> Int {
		
		let context = persistentContainer.viewContext
		let entityName = String(describing: type)
		let request = NSFetchRequest<M>(entityName: entityName)
		
		do {
			let count = try context.count(for: request)
			return count
		}
		catch {
			print("Error executing total: \(error)")
			return 0
		}
	}
	
	func fetch<M: NSManagedObject>(_ type: M.Type, predicate: NSPredicate?=nil, sort: NSSortDescriptor?=nil) -> [M]? {
		
		var fetched: [M]?
		let context = persistentContainer.viewContext
		let entityName = String(describing: type)
		let request = NSFetchRequest<M>(entityName: entityName)
		
		request.predicate = predicate
		request.sortDescriptors = [sort] as? [NSSortDescriptor]
		
		do {
			fetched = try context.fetch(request)
		}
		catch {
			print("Error executing fetch: \(error)")
		}
		return fetched
	}
}

// MARK: - Save
extension ModelController {
	
	func save() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch {
				let nserror = error as NSError
				fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
			}
		}
	}
}

// MARK: - Delete
extension ModelController {
	
	func delete(by objectID: NSManagedObjectID) {
		
		let context = persistentContainer.viewContext
		let managedObject = context.object(with: objectID)
		context.delete(managedObject)
	}
	
	func delete<M: NSManagedObject>(_ type: M.Type, predicate: NSPredicate?=nil) {
		
		let context = persistentContainer.viewContext
		
		if let objects = fetch(type, predicate: predicate) {
			for modelObject in objects {
				delete(by: modelObject.objectID)
			}
		}
		
		if context.deletedObjects.count > 0 {
			save()
		}
	}
}
