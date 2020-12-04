//
//  CoreDataRetrievalManager.swift
//  musicSharing

import Foundation
import UIKit
import CoreData

class CoreDataRetrievalManager {
    
    let memoryType: StorageType
    init(_ memoryType: StorageType = .persistent) {
        self.memoryType = memoryType
    }
    lazy var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
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
    
    func getStashFromMainUser()->[SongInstanceEntity]? {
        do {
            let stashSongs = try self.context?.fetch(self.getRequestForStashFromMainUser)
            return stashSongs
        } catch {
            print("Couldn't return stashed songs for Main User")
            return nil
        }
    }
    
    var getRequestForStashFromMainUser: NSFetchRequest<SongInstanceEntity> {
        let request: NSFetchRequest<SongInstanceEntity> = SongInstanceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY stashed_by.userID = %@", MainUser.idMainUser as CVarArg) // comparing a collection of results(?) to a scalar value so need ANY
        request.sortDescriptors = [NSSortDescriptor(key: "song_name", ascending: true)]
        return request
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
    
    // will need to be modified to use a Date as part of the Sort
    // also try to use ID instead of name for more accuracy--running into bug here.
    var getRecentlyListenedSongFromMainUser: NSFetchRequest<SongInstanceEntity> {
        let request: NSFetchRequest<SongInstanceEntity> = SongInstanceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "played_by.userID = %@", MainUser.idMainUser as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "song_name", ascending: true)]
        return request
    }
    
    var getMainUsersFriends:
        NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY is_friends_with.userID = %@", MainUser.idMainUser as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    var getFollowRequestsSentByMainUser:
        NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY received_follow_request.userID = %@", MainUser.idMainUser as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    var getReceivedFollowRequestsForMainUser:
        NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY sent_follow_request.userID = %@", MainUser.idMainUser as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
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
