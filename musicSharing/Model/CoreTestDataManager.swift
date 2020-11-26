//
//  CoreTestDataManager.swift
//  musicSharing
//
//  Created by Varghese Thomas on 26/11/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class TestDataManager {
    /*
      Class is responsible only for injecting test data into Core Data. Will be replaced with JSON loads instead once main functionality is done
     */
    static var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
      
    static var mainUser = TestDataManager.createMainUser() // will act as our main user for demo purposes -- e.g. the user profile will reflect user u0
    
    static func createMainUser() -> UserEntity {
        let u0 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: TestDataManager.context) as! UserEntity
               u0.userID = UUID()
               u0.name = "Tom"
               u0.avatar = "northern_lights"
               u0.bio = "student who likes all kinds of music. No favorite song -- Different songs for different moods."
        return u0
    }
    
    static func saveFakeData() {
        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
        
        // USERS
        let u1 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: TestDataManager.context) as! UserEntity
        u1.userID = UUID()
        u1.name = "Bob"
        u1.avatar = "northern_lights"
        u1.bio = "lawyer"
        
        let u2 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: TestDataManager.context) as! UserEntity
        u2.userID = UUID()
        u2.name = "Sally"
        u2.avatar = "northern_lights"
        u2.bio = "doctor"
        
        let u3 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: TestDataManager.context) as! UserEntity
        u3.userID = UUID()
        u3.name = "Peter"
        u3.avatar = "northern_lights"
        u3.bio = "has great power and recognizes great responsibilities come along with it"
        
        let u4 = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: TestDataManager.context) as! UserEntity
        u4.userID = UUID()
        u4.name = "Vic"
        u4.avatar = "northern_lights"
        u4.bio = "uh what are we supposed to put here?"
        
        // SONGS
        let s1 = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: TestDataManager.context) as! SongEntity
        
        s1.song_id = UUID()
        s1.artist_name = "Samuel Barber"
        s1.genre = "Classical"
        s1.song_image = "northern_lights"
        s1.song_length = 4.23
        s1.song_name = "Adagio For Strings"
        
        let s2 = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: TestDataManager.context) as! SongEntity
        s2.song_id = UUID()
        s2.artist_name = "Joe Esposito"
        s2.genre = "Rock"
        s2.song_image = "northern_lights"
        s2.song_length = 3.14
        s2.song_name = "You're the Best Around"
        
        let s3 = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: TestDataManager.context) as! SongEntity
        s3.song_id = UUID()
        s3.artist_name = "Jesper Kyd"
        s3.genre = "Classical"
        s3.song_image = "northern_lights"
        s3.song_length = 4.15
        s3.song_name = "Son of Fjord"
        
        let s4 = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: TestDataManager.context) as! SongEntity
        s4.song_id = UUID()
        s4.song_name = "Tyler Herro"
        s4.genre = "HipHop"
        s4.song_length = 2.36
        
        let s5 = Song(id: UUID(), name: "The Devil Went Down to Georgia", artist: "The Charlie Daniels Band", genre: "Country", image: "", songLength: 3.34).convertToManagedObject()
        
        // INSTANCES
        let i1 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: TestDataManager.context) as! SongInstanceEntity
        i1.instance_id = UUID()
        i1.song_name = s1.song_name
        i1.instance_of = s1
        i1.played_by = u1
        
        let i2 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: TestDataManager.context) as! SongInstanceEntity
        
        i2.instance_id = UUID()
        i2.song_name = s2.song_name
        i2.instance_of = s2
        i2.played_by = u1
        
        let i3 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: TestDataManager.context) as! SongInstanceEntity
        
        i3.instance_id = UUID()
        i3.song_name = s3.song_name
        i3.instance_of = s3
        i3.played_by = u2
        
        let i4 = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: TestDataManager.context) as! SongInstanceEntity
        
        i4.instance_id = UUID()
        i4.song_name = s1.song_name
        i4.instance_of = s1
        i4.played_by = TestDataManager.mainUser
        
        let i5 =  NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: TestDataManager.context) as! SongInstanceEntity
        
        i5.instance_id = UUID()
        i5.song_name = s5.song_name
        i5.instance_of = s5
        i5.played_by = TestDataManager.mainUser
        
        let i6 =  NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: TestDataManager.context) as! SongInstanceEntity
        
        i6.instance_id = UUID()
        i6.song_name = s2.song_name
        i6.instance_of = s2
        i6.played_by = TestDataManager.mainUser

//        let i6 = SongInstance(id: UUID(), instanceOf: Song(songEntity: s2), playedBy: User(userEntity: CoreDataManager.mainUser))
//        _ = i6.convertToManagedObject()
        
        let i7 =  NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: TestDataManager.context) as! SongInstanceEntity
        
        i7.instance_id = UUID()
        i7.song_name = s4.song_name
        i7.instance_of = s4
        i7.played_by = u3
        
        
        // assigning friendships
        CoreRelationshipDataManager.userIsFriends(user: TestDataManager.mainUser, friend: u2)
        CoreRelationshipDataManager.userIsFriends(user: TestDataManager.mainUser, friend: u3)
        
        // assigning follow request to Main User
        CoreRelationshipDataManager.userSentFollowRequest(from: u1, to: TestDataManager.mainUser)
        
        // assigning follow request sent by Main User
        CoreRelationshipDataManager.userSentFollowRequest(from: TestDataManager.mainUser, to: u4)
        
        // need to assign stash relationships
        appDelegate.saveContext()
    }
    
    // Methods for clearing Core Data instances
    static func emptyDB() {
        TestDataManager.deleteAllSongs()
        TestDataManager.deleteAllUsers()
    }
    
    static func deleteAllSongs(/*_ context: NSManagedObjectContext*/) {
        let songFetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        do {
            let songs = try TestDataManager.context.fetch(songFetchRequest)
            songs.forEach{ TestDataManager.context.delete($0)}
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
}

