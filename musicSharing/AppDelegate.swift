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
}


// customized Persistent Store Container so can use the .inMemory option for testing purposes. By default, will use CloudKit instead.
enum StorageType {
    case persistent
    case inMemory
}

final class CoreDataStoreContainer {
    let memoryType: StorageType
    
    init?(_ storageType: StorageType = .persistent) {
        self.memoryType = storageType
    }
    
    static let shared = CoreDataStoreContainer()
    
    lazy var persistentContainer = self.setUp(completion: {})
    
    func setUp(completion: (() -> Void)?) -> NSPersistentCloudKitContainer {
        return createPersistentContainer(self.memoryType) {
          completion?()
        }
    }
    
    lazy var backgroundContext: NSManagedObjectContext = {
        let context = self.persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy

        return context
    }()
    
    // used for saving fake data here and retrieving later
    func newDerivedContext() -> NSManagedObjectContext? {
      let context = persistentContainer.newBackgroundContext()
      return context
    }
}

func createPersistentContainer(_ memoryType: StorageType, completion: @escaping () -> Void?) -> NSPersistentCloudKitContainer {
    let container = NSPersistentCloudKitContainer(name: "musicSharing")
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




