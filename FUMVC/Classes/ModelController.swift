//
//  ModelController.swift
//  FUMVC
//
//  Created by Mike Post on 2018-11-16.
//  Copyright © 2018 Mike Post. All rights reserved.
//

import CoreData

protocol ModelCloudConfig {
		
	/// This to signify the usage of CloudKit with Core Data, only available in iOS 13+. NOTE: the container id used in CloudKit must match the `CFBundleIdentifier`!
	var useCloudKit: Bool { get }
}

public class ModelController: ModelCloudConfig {
	
	var useCloudKit: Bool = false
	
	public typealias VoidCompletion = () -> ()
	
	// MARK: - Properties
	
	private var modelName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
		
	lazy var persistentContainer: NSPersistentContainer = {
		
		var container = NSPersistentContainer(name: modelName)
		
		//Handle any config needed for CloudKit
		if useCloudKit, #available(iOS 13.0, *) {
			container = NSPersistentCloudKitContainer(name: modelName)
			
			guard let description = container.persistentStoreDescriptions.first else {
					fatalError("Could not retrieve a persistent store description to enable Core Data with CloudKit.")
			}

			// initialize the CloudKit schema
			let bundleID = "iCloud.\(Bundle.main.object(forInfoDictionaryKey: "CFBundleIdentifier") ?? "")"
			let options = NSPersistentCloudKitContainerOptions(containerIdentifier: bundleID)
			description.cloudKitContainerOptions = options
			container.persistentStoreDescriptions = [description]
		}
		
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			
			if let error = error as NSError? {
				fatalError("Unresolved error \(error), \(error.userInfo)")
			}
		})
		
		// TODO: Create a way to only inlcude this optionally before pushing a new FUMVC pod version - useCloudKit is not a suitable flag for this!!!
		if useCloudKit, #available(iOS 13.0, *) {
			do {
				// Uncomment to do a dry run and print the CK records that are made.
				//try container.initializeCloudKitSchema(options: [.dryRun, .printSchema])
				// Only uncomment to initialize your schema - move from production code!
				let cloudContainer: NSPersistentCloudKitContainer = container as! NSPersistentCloudKitContainer
				try cloudContainer.initializeCloudKitSchema()
			}
			catch {
				print("Unable to initialize CloudKit schema: \(error.localizedDescription)")
			}
		}
		return container
	}()
	
	lazy var context: NSManagedObjectContext = {
		return persistentContainer.viewContext
	}()
	
	lazy var backgroundContext: NSManagedObjectContext = {
		return persistentContainer.newBackgroundContext()
	}()
	
	// MARK: - Convenience Init
	
	public convenience init(modelName model: String, useCloudKit cloudKit: Bool?=nil) {
		self.init()
		self.modelName = model
		
		if let useCloudKit = cloudKit {
			self.useCloudKit = useCloudKit
		}
	}
}


// MARK: - Add
extension ModelController {
	
	public func add<M: NSManagedObject>(_ type: M.Type) -> M? {
		
		var modelObject: M?
		
		if let entity = NSEntityDescription.entity(forEntityName: M.description(), in: context) {			
			modelObject = M(entity: entity, insertInto: context)
		}
		return modelObject
	}
}


// MARK: - Fetch
extension ModelController {
	
	public typealias TotalCompletion = ((_ count: Int) -> ())
	public typealias FetchCompletion<M> = ((_ fetched: [M]) -> ())
	
	public func total<M: NSManagedObject>(_ type: M.Type, _ completion: TotalCompletion?=nil) -> Int {
		
		var count = 0
		let entityName = String(describing: type)
		let request = NSFetchRequest<M>(entityName: entityName)
		
		if let completion = completion {
			self.context.perform {
				let _ = self.fetchTotal(request, completion)
			}
		}
		else {
			count = fetchTotal(request)
		}
		return count
	}
	
	private func fetchTotal<M: NSManagedObject>(_ request: NSFetchRequest<M>,
												_ completion: TotalCompletion?=nil) -> Int {
		var count = 0
		do {
			count = try context.count(for: request)
			completion?(count)
		}
		catch {
			print("Error executing total: \(error)")
			completion?(0)
		}
		return count
	}
	
	public func fetch<M: NSManagedObject>(_ type: M.Type,
								   predicate: NSPredicate?=nil,
								   sort: NSSortDescriptor?=nil,
								   _ completion: FetchCompletion<M>?=nil) -> [M]? {
		var fetched: [M]?
		let entityName = String(describing: type)
		let request = NSFetchRequest<M>(entityName: entityName)
		
		request.predicate = predicate
		request.sortDescriptors = [sort] as? [NSSortDescriptor]
		
		if let completion = completion {
			self.context.perform {
				let _ = self.fetchObjects(request, completion)
			}
		}
		else {
			fetched = fetchObjects(request)
		}
		return fetched
	}
	
	private func fetchObjects<M: NSManagedObject>(_ request: NSFetchRequest<M>,
												  _ completion: FetchCompletion<M>?=nil) -> [M] {
		var fetched: [M] = [M]()
	
		do {
			fetched = try context.fetch(request)
			completion?(fetched)
		}
		catch {
			print("Error executing fetch: \(error)")
			completion?(fetched)
		}
		return fetched
	}
}

// MARK: - Save
extension ModelController {
	
	public func save(_ completion: VoidCompletion?=nil) {
		
		context.perform {
			if self.context.hasChanges {
				do {
					try self.context.save()
				} catch {
					let nserror = error as NSError
					fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
				}
			}
			completion?()
		}
	}
}

// MARK: - Delete
extension ModelController {
	
	public func delete(by objectID: NSManagedObjectID, _ completion: VoidCompletion?=nil) {
		
		let managedObject = context.object(with: objectID)
		
		context.perform {
			self.context.delete(managedObject)
			completion?()
		}
	}
	
	public func delete<M: NSManagedObject>(_ type: M.Type, predicate: NSPredicate?=nil, _ completion: VoidCompletion?=nil) {
		
		if let objects = fetch(type, predicate: predicate) {
			for modelObject in objects {
				delete(by: modelObject.objectID, completion)
			}
		}
		
		if context.deletedObjects.count > 0 {
			save()
		}
	}
}
