//
//  CoreDataRetrievalManager.swift
//  musicSharing

import Foundation
import UIKit
import CoreData

class CoreDataRetrievalManager {
    let memoryType: StorageType
    let context: NSManagedObjectContext?
    
    init(_ memoryType: StorageType = .persistent, backgroundContext: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) {
        self.memoryType = memoryType
        self.context = backgroundContext
    }
    
//    let memoryType: StorageType
//
//    init(_ memoryType: StorageType = .persistent) {
//        self.memoryType = memoryType
//    }
//
//    lazy var context: NSManagedObjectContext? = {
//        var trueContext = CoreDataStoreContainer(.inMemory)?.persistentContainer.viewContext
//        if self.memoryType == .persistent {
//            trueContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
//        }
//        return trueContext
//    }()
    
    func getUserWithName(_ name: String) -> UserEntity? {
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let user = try self.context!.fetch(userFetchRequest).first
            return user
        } catch {
            print("User fetch failed")
            return nil
        }
    }
    
    func fetchMainUser() -> UserEntity? {
        let mainUserRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        mainUserRequest.predicate = NSPredicate(format: "%K == %@", "userID", MainUser.idMainUser as CVarArg)
        do {
            print("CONTEXT: \(self.context!)")
            let mainUser = try self.context!.fetch(mainUserRequest).first!
            return mainUser
        } catch {
            print("Could not initialize main user \(error.localizedDescription)")
        }
        return nil
    }
    
    // get main user's songs from their STASH
    
    func getStashFromUser(_ id: String = MainUser.idMainUser)->[SongInstanceEntity]? {
        let request: NSFetchRequest<SongInstanceEntity> = SongInstanceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY stashed_by.userID = %@", id as CVarArg) // comparing a collection of results(?) to a scalar value so need ANY
        request.sortDescriptors = [NSSortDescriptor(key: "song_name", ascending: true)]
        do {
            let stashSongs = try self.context?.fetch(request)
            return stashSongs
        } catch {
            print("Couldn't return stashed songs for Main User")
            return nil
        }
    }
    
    // get main user's friends
    
    func getUsersFriends(_ id: String = MainUser.idMainUser) -> [UserEntity]? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY is_friends_with.userID = %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let userEntities = try self.context?.fetch(request)
            return userEntities
        } catch {
            print("Couldn't return main user's friends")
            return nil
        }
    }
    
    // get people who requested to follow main user
    
    func getReceivedFollowRequestsForUser(_ id: String = MainUser.idMainUser) -> [UserEntity]? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
               request.predicate = NSPredicate(format: "ANY received_follow_request.userID = %@", id as CVarArg)
               request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let userEntities = try self.context?.fetch(request)
            return userEntities
        } catch {
            print("Couldn't return main user's follower requests")
            return nil
        }
    }
    
    // get follow requests sent by main users
    
    func getFollowRequestsSentByUser(_ id: String = MainUser.idMainUser) -> [UserEntity]? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY sent_follow_request.userID = %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        do {
            let userEntities = try self.context?.fetch(request)
            return userEntities
        } catch {
            print("Could not get requests sent BY main user")
            return nil
        }
    }
    
    func getRecentlyListenedSongFromUser(_ id: String = MainUser.idMainUser) -> [SongInstanceEntity]? {
        let request: NSFetchRequest<SongInstanceEntity> = SongInstanceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "played_by.userID = %@", id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "date_listened", ascending: false)]
        do {
            let songInstEnt = try self.context?.fetch(request)
            return songInstEnt
        } catch {
            print("Couldn't get the most recently listened to song for Main User")
            return nil
        }
    }
    
    func getSongInstancesFromUser(_ user: UserEntity) -> [SongInstance]? {
        if let songs:[SongInstanceEntity] = user.listened_to?.allObjects as? [SongInstanceEntity] {
            songs.forEach({ print("User 1 listens to -> \($0.instance_of!.song_name ?? "Unknown") by \($0.instance_of!.artist_name ?? "")")})
            let instances = songs.map({
                SongInstance(instanceEntity: $0)}
            )
            return instances
        }
        print("No song listens for user")
        return nil
    }
    

    func checkIfSongExists(_ songName: String) -> Bool? {
        let request: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        let regularMatchPredicate = NSPredicate(format: "ANY song_name = %@", songName)
        let lowerCaseMatchPredicate = NSPredicate(format: "ANY song_name = %@", songName.lowercased())
        let orPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [regularMatchPredicate, lowerCaseMatchPredicate])
        request.predicate = orPredicate
        do {
            let match = try  self.context!.fetch(request).first
            guard match != nil else { return false}
            return true
        } catch {
            print("Couldn't perform songName predicate match request.")
            return nil
        }
        
    }
    
    
//    static func getStashFromUser(_ user: UserEntity) -> [SongInstance]? {
//        if let songs: [SongInstanceEntity] = user.stashes_this?.allObjects as? [SongInstanceEntity] {
//            let instances = songs.map {
//                SongInstance(instanceEntity: $0)
//            }
//            return instances
//        }
//        print("No song stashes for user")
//        return nil
//    }
//

}

// helper function to get regex that ignores whitespaces between characters in name
//func regexIgnoreSpaceFor(_ name: String) {
//    let arr = Array(name)
//    print(arr)
//    Array(
//}
