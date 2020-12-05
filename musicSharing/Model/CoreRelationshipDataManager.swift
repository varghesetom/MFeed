//
//  CoreDataRelationshipManager.swift
//  musicSharing

import Foundation
import UIKit
import CoreData


class CoreRelationshipDataManager {
    /* Class will be responsible for RELATIONSHIP ASSIGNMENTS.
     Note: all relationships have an inverse so no need to assign the data in the other way as well.
     E.g. User stashes a song, and uses the "addToStashes_this" method, then we don't need to have use the "addToStashed_by" assignment where we have our song "add" the user
     
     */
    let memoryType: StorageType
    let context: NSManagedObjectContext?
    
    init(_ memoryType: StorageType = .persistent, backgroundContext: NSManagedObjectContext? = CoreDataStoreContainer.shared!.backgroundContext) {
        self.memoryType = memoryType
        self.context = backgroundContext
    }
    
//    lazy var context: NSManagedObjectContext? = {
//        var trueContext = CoreDataStoreContainer(.inMemory)?.persistentContainer.viewContext
//        if self.memoryType == .persistent {
//            trueContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
//        }
//        return trueContext
//    }()
    
    func userStashesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        print("\n\nUSER BEFORE ADDING \(user)")
        user.addToStashes_this(songInstance)
        print("\n\nUSER AFTER ADDING \(user)")
        do {
            try self.context!.save()
        } catch {
            print("Error adding stashed song relationship for user")
        }
    }
    
    func userListenedToSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.addToListened_to(songInstance)
        do {
            try self.context!.save()
        } catch {
            print("Error adding listened song relationship for user")
        }
    }
    
    func userLikesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.addToLikes_this(songInstance)
        do {
            try self.context!.save()
        } catch {
            print("Error adding liked song relationship for user")
        }
    }
    
    func userCommentsOnSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.addToCommented_on(songInstance)
        do {
            try self.context!.save()
        } catch {
            print("Error adding commented song relationship for user")
        }
    }
    
    func userIsFriends(user: UserEntity, friend: UserEntity) {
        user.addToIs_friends_with(friend)
        do {
            try self.context!.save()
        } catch {
            print("Error adding friendship for user")
        }
    }
    
    func userSentFollowRequest(from: UserEntity, to: UserEntity) {
        from.addToSent_follow_request(to)
        do {
            try self.context!.save()
        } catch {
            print("Error adding follow sent request for user")
        }
    }
    
    /* Deleting Database relationships */
    
    func userUnlikesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.removeFromLikes_this(songInstance)
        do {
            try self.context!.save()
        } catch {
            print("Error removing liked song relationship for user")
        }
    }

    func userUncommentsSong(user: UserEntity, songInstance: SongInstanceEntity) {
           user.removeFromCommented_on(songInstance)
        do {
            try self.context!.save()
        } catch {
            print("Error removing comment relationship for user")
        }
   }
    
    func userUnstashesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.removeFromStashes_this(songInstance)
        do {
            try self.context!.save()
        } catch {
            print("Error removing stashed song relationship for user")
        }
    }
}

