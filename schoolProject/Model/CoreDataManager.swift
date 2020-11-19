//
//  CoreDataManager.swift
//  OnTheSpot
//
//  Created by Varghese Thomas on 18/11/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class CoreDataManager {
    
    static var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
      // will act as our main user for demo purposes -- e.g. the user profile will reflect user u0
    static var mainUser = CoreDataManager.createMainUser()
    
    static func createMainUser() -> UserEntity {
        let u0 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: CoreDataManager.context) as! UserEntity
               u0.userID = UUID()
               u0.name = "Tom"
               u0.avatar = "northern_lights"
               u0.bio = "student who likes all kinds of music. No favorite song -- Different songs for different moods."
        return u0
    }
        
    static func saveFakeData() {
        
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
        
        let u1 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: CoreDataManager.context) as! UserEntity
        u1.userID = UUID()
        u1.name = "Bob"
        u1.avatar = "northern-lights"
        u1.bio = "lawyer"
        
        let u2 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: CoreDataManager.context) as! UserEntity
        u2.userID = UUID()
        u2.name = "Sally"
        u2.avatar = "northern-lights"
        u2.bio = "doctor"
        
        let s1 = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: CoreDataManager.context) as! SongEntity
        
        s1.song_id = UUID()
        s1.artist_name = "Samuel Barber"
        s1.genre = "Classical"
        s1.song_image = "northern_lights"
        s1.song_length = 4.23
        s1.song_name = "Adagio For Strings"
        
        let s2 = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: CoreDataManager.context) as! SongEntity
        s2.song_id = UUID()
        s2.artist_name = "Joe Esposito"
        s2.genre = "80s"
        s2.song_image = "northern_lights"
        s2.song_length = 3.14
        s2.song_name = "You're the Best Around"
        
        let s3 = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: CoreDataManager.context) as! SongEntity
        s3.song_id = UUID()
        s3.artist_name = "Jesper Kyd"
        s3.genre = "Instrumental"
        s3.song_image = "northern_lights"
        s3.song_length = 4.15
        s3.song_name = "Son of Fjord"
        
        let i1 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: CoreDataManager.context) as! SongInstanceEntity
        i1.instance_id = UUID()
        i1.instance_of = s1
        i1.played_by = u1
        
        let i2 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: CoreDataManager.context) as! SongInstanceEntity
        
        i2.instance_id = UUID()
        i2.instance_of = s2
        i2.played_by = u1
        
        let i3 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: CoreDataManager.context) as! SongInstanceEntity
        
        i3.instance_id = UUID()
        i3.instance_of = s3
        i3.played_by = u2
        
        let i4 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: CoreDataManager.context) as! SongInstanceEntity
        
        i4.instance_id = UUID()
        i4.instance_of = s1
        i4.played_by = CoreDataManager.mainUser

        appDelegate.saveContext()
    }
    
    static func getUserWithName(_ name: String) -> UserEntity? {
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        userFetchRequest.predicate = NSPredicate(format: "name == %@", name)
        do {
            let user = try CoreDataManager.context.fetch(userFetchRequest).first
            return user
        } catch {
            print("User fetch failed")
            return nil
        }
    }
    
    static func getSongInstancesFromUser(_ user: UserEntity) -> [SongInstanceEntity]? {
        if let songs:[SongInstanceEntity] = user.listened_to?.allObjects as? [SongInstanceEntity] {
            songs.forEach({ print("User 1 listens to -> \($0.instance_of!.song_name ?? "Unknown") by \($0.instance_of!.artist_name ?? "")")})
            return songs
        }
        print("Error getting songs for user")
        return nil
    }
    
    
    /* RELATIONSHIP ASSIGNMENTS -- all relationships have an inverse so no need
      to assign the data in the other way as well.
     E.g. User stashes a song, and uses the "addToStashes_this" method, then we don't need to have use the "addToStashed_by" assignment where we have our song "add" the user
     */
    static func userStashesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.addToStashes_this(songInstance)
    }
    
    static func userListenedToSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.addToListened_to(songInstance)
    }
    
    static func userLikesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.addToLikes_this(songInstance)
    }
    
    static func userCommentsOnSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.addToCommented_on(songInstance)
    }
    
    static func userIsFriends(user: UserEntity, friend: UserEntity) {
        user.addToIs_friends_with(friend)
    }
    
    /* Deleting Database entries and relationships */
    static func emptyDB() {
        CoreDataManager.deleteAllSongs()
        CoreDataManager.deleteAllUsers()
    }
    
    static func deleteAllSongs(/*_ context: NSManagedObjectContext*/) {
        let songFetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        do {
            let songs = try CoreDataManager.context.fetch(songFetchRequest)
            songs.forEach{ CoreDataManager.context.delete($0)}
        } catch {
            print("Error deleting Songs: \(error.localizedDescription)")
        }
    }
    
    static func deleteAllUsers() {
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let users = try context.fetch(userFetchRequest)
            users.forEach{ context.delete($0)}
        } catch {
            print("Error deleting Users: \(error.localizedDescription)")
        }
    }
    
    static func userUnlikesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.removeFromLikes_this(songInstance)
    }

    static func userUncommentsSong(user: UserEntity, songInstance: SongInstanceEntity) {
           user.removeFromCommented_on(songInstance)
       }
    
    static func userUnstashesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.removeFromStashes_this(songInstance)
    }
}

