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
    
    var users = [User]()
    var songs = [Song]()
    var songInstances = [SongInstance]()
    static var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    static let idMainUser = "947be968-e95d-4db4-b975-0e674c934c61"
    static let testData = JSONTestData()
    
    static var mainUser = TestDataManager.createMainUser() // will act as our main user for demo purposes -- e.g. the user profile will reflect user u0
    
    static func createMainUser() -> UserEntity? {
        let mainUserRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        mainUserRequest.predicate = NSPredicate(format: "ANY %K == %@", "name", "Tom")
        do {
            let mainUser = try TestDataManager.context.fetch(mainUserRequest).first!
            print("FOUND MAIN USER: \(mainUser)")
            return mainUser
        } catch {
            print("Could not initialize main user \(error.localizedDescription)")
        }
        return nil
    }
    
    static func saveFakeData() {
        TestDataManager.loadUsersFromJSON()
        TestDataManager.loadSongsFromJSON()
        TestDataManager.loadSongInstancesFromJSON()
        CoreRelationshipDataManager.assignAllInitialRelationships()
    }
    
    static func loadUsersFromJSON() {
        guard let users = testData.users else {
            print("Could not load users data")
            return
        }
        users.forEach({ user in _ =
            user.convertToManagedObject()
        })
        
        do {
            try TestDataManager.context.save()
        } catch {
            print("Error saving users to CoreData store \(error.localizedDescription)")
        }
    }

    static func loadSongsFromJSON() {
        guard let songs = testData.songs else {
            print("Could not load songs data")
            return
        }
             songs.forEach({ song in _ =
                 song.convertToManagedObject()
             })
             
             do {
                 try TestDataManager.context.save()
             } catch {
                 print("Error saving songs to CoreData store \(error.localizedDescription)")
             }
    }
    
    static func loadSongInstancesFromJSON() {
        guard let songInstances = TestDataManager.testData.songInstances else {
                print("Could not load song instances data")
                return
        }
             songInstances.forEach({ songInstance in _ =
                 songInstance.convertToManagedObject()
             })
             
             do {
                 try TestDataManager.context.save()
             } catch {
                 print("Error saving song instances to CoreData store \(error.localizedDescription)")
             }
    }
    
    
    static func setInitialRelationships() {
        // assigning friendships
//        CoreRelationshipDataManager.userIsFriends(user: TestDataManager.mainUser, friend: u2)
//        CoreRelationshipDataManager.userIsFriends(user: TestDataManager.mainUser, friend: u3)
        
        // assigning follow request to Main User
//        CoreRelationshipDataManager.userSentFollowRequest(from: u1, to: TestDataManager.mainUser)
        
        // assigning follow request sent by Main User
//        CoreRelationshipDataManager.userSentFollowRequest(from: TestDataManager.mainUser, to: u4)
        CoreRelationshipDataManager.assignInitialFriendshipsToUser()
        CoreRelationshipDataManager.assignMainUsersSentFollowRequests()
        CoreRelationshipDataManager.assignInitialFollowRequestsForMainUser()
        
        // need to assign stash relationships
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

struct JSONTestData {
    var users: [User]?
    var songs: [Song]?
    var songInstances: [SongInstance]?
    
    init() {
        guard let usersPath = Bundle.main.path(forResource: "users", ofType: "json") else {
            print("Yo! no users Path!")
            return
        }
        do {
            if let jsonData = try String(contentsOfFile: usersPath).data(using: .utf8) {
                let decoder = JSONDecoder()
                users = try decoder.decode([User].self, from: jsonData)
                print("USERS -> \(users ?? [User]())")
            }
        } catch {
               print("Error occurred for users decoding process \(error.localizedDescription)")
        }
        
        guard let songsPath = Bundle.main.path(forResource: "songs", ofType: "json") else {
            print("Yo! no songs Path!")
            return
        }
        do {
            if let jsonData = try String(contentsOfFile: songsPath).data(using: .utf8) {
                let decoder = JSONDecoder()
                songs = try decoder.decode([Song].self, from: jsonData)
            }
        } catch {
          print("Error occurred for song decoding process \(error.localizedDescription)")
       }
                    
        guard let songInstancesPath = Bundle.main.path(forResource: "song_instances", ofType: "json") else {
                print("Yo! no songInstances Path!")
                return
        }
        do {
            if let jsonData = try String(contentsOfFile: songInstancesPath).data(using: .utf8) {
            let decoder = JSONDecoder()
            songInstances = try decoder.decode([SongInstance].self, from: jsonData)
            print("SONGINSTANCES -> \(songInstances ?? [SongInstance]())")
            }
        } catch {
            print("Error occurred for song instances decoding process \(error.localizedDescription)")
        }
    }
}
