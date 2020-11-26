//
//  CoreDataRetrievalManager.swift
//  musicSharing

import Foundation
import UIKit
import CoreData

class CoreDataRetrievalManager {
    
    static var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
    
    static func getUserWithName(_ name: String) -> UserEntity? {
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let user = try CoreDataRetrievalManager.context.fetch(userFetchRequest).first
            return user
        } catch {
            print("User fetch failed")
            return nil
        }
    }
    
    static func getSongInstancesFromUser(_ user: UserEntity) -> [SongInstance]? {
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
    static var getRecentlyListenedSongFromMainUser: NSFetchRequest<SongInstanceEntity> {
        let request: NSFetchRequest<SongInstanceEntity> = SongInstanceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "played_by.name = %@", User(userEntity: TestDataManager.mainUser).name)
        request.sortDescriptors = [NSSortDescriptor(key: "song_name", ascending: true)]
        return request
    }
    
    // get main user's songs from their STASH
    static var getStashFromMainUser: NSFetchRequest<SongInstanceEntity> {
        let request: NSFetchRequest<SongInstanceEntity> = SongInstanceEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY stashed_by.name = %@", User(userEntity: TestDataManager.mainUser).name) // comparing a collection of results(?) to a scalar value so need ANY
        request.sortDescriptors = [NSSortDescriptor(key: "song_name", ascending: true)]
        return request
    }
    
    static var getMainUsersFriends:
        NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY is_friends_with.name = %@", User(userEntity: TestDataManager.mainUser).name)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    static var getFollowRequestsSentByMainUser:
        NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY received_follow_request.name = %@", User(userEntity: TestDataManager.mainUser).name)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    static var getReceivedFollowRequestsForMainUser:
        NSFetchRequest<UserEntity> {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "ANY sent_follow_request.name = %@", User(userEntity: TestDataManager.mainUser).name)
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
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
