//
//  AppDelegate.swift
//
//  Created by Varghese Thomas on 19/11/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack
//    lazy var persistentContainer: NSPersistentContainer = (CoreDataStoreContainer()?.setUp(completion: {}))!
    
//    lazy var persistentContainer: NSPersistentContainer = {
//        /*
//         The persistent container for the application. This implementation
//         creates and returns a container, having loaded the store for the
//         application to it. This property is optional since there are legitimate
//         error conditions that could cause the creation of the store to fail.
//        */
//        let container = NSPersistentContainer(name: "musicSharing")
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//
//            if let error = error as NSError? {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//
//                /*
//                 Typical reasons for an error here include:
//                 * The parent directory does not exist, cannot be created, or disallows writing.
//                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
//                 * The device is out of space.
//                 * The store could not be migrated to the current model version.
//                 Check the error message to determine what the actual problem was.
//                 */
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
////            try? container.viewContext.setQueryGenerationFrom(.current) // prints out any updates
//
////            // BELOW USED TO REPLACE WAL WITH ROLLBACK
////            storeDescription.setValue("wal_autocheckpoint" as NSObject, forPragmaNamed: "wal")
////            container.persistentStoreDescriptions = [storeDescription]
//        })
//        return container
//    }()

    // MARK: - Core Data Saving support

//    func saveContext () {
//        let context = persistentContainer.viewContext
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
}


// customized Persistent Store Container so can use the .inMemory option for testing purposes. By default, will use SQLite store instead.
enum StorageType {
    case persistent
    case inMemory
}

class CoreDataStoreContainer {
    let memoryType: StorageType
    
    init?(_ storageType: StorageType = .persistent) {
        self.memoryType = storageType
    }
//    lazy var persistentContainer = createPersistentContainer(self.memoryType)
    static let shared = CoreDataStoreContainer()
    
    lazy var persistentContainer = self.setUp(completion: {})
    
    func setUp(completion: (() -> Void)?) -> NSPersistentContainer {
        return createPersistentContainer(self.memoryType) {
          completion?()
        }
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return context
    }()
    
    lazy var context: NSManagedObjectContext = {
        let context = self.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()
    
    // used for saving fake data here and retrieving later
    func newDerivedContext() -> NSManagedObjectContext? {
      let context = persistentContainer.newBackgroundContext()
      return context
    }
}

func createPersistentContainer(_ memoryType: StorageType, completion: @escaping () -> Void?) -> NSPersistentContainer {
    let container = NSPersistentContainer(name: "musicSharing")
    if memoryType == .inMemory {
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
    }
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError? {
            fatalError("Unresolved error \(error.localizedDescription), \(error.userInfo)")
        }
        try? container.viewContext.setQueryGenerationFrom(.current) // prints out any updates
    })
    return container
}


