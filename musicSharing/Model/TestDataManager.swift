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
      Class is responsible only for injecting test data into Core Data.
     */
    let memoryType: StorageType
//    let privateContext: NSManagedObjectContext?
//    let context: NSManagedObjectContext?
    
    init(_ memoryType: StorageType = .persistent) {
        self.memoryType = memoryType
//        self.privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        self.context = {
//             var trueContext = CoreDataStoreContainer(.inMemory)?.persistentContainer.viewContext
//             if self.memoryType == .persistent {
//                 trueContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
//             }
//             return trueContext
//         }()
    }

    lazy var context: NSManagedObjectContext? = {
         var trueContext = CoreDataStoreContainer(.inMemory)?.persistentContainer.viewContext
         if self.memoryType == .persistent {
             trueContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
         }
         return trueContext
     }()
//        lazy var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext

    
    lazy var testData = JSONTestData()
    lazy var CRManager = CoreRelationshipDataManager(self.memoryType)
    lazy var CDataRetManager = CoreDataRetrievalManager(self.memoryType)
    
    func saveFakeData() {
        print("SAVING FAKE DATA")
        _ = self.loadUsersFromJSON()
        _ = self.loadSongsFromJSON()
        _ = self.loadSongInstancesFromJSON()
        _ = self.assignAllInitialRelationships()
    }
    
    func loadUsersFromJSON() -> Bool {
        guard let users = testData.users else {
            print("Could not load users data")
            return false
        }
        users.forEach({ user in _ =
            user.convertToManagedObject(self.context!)
        })
        do {
            try self.context!.save()
            return true
        } catch {
            print("Error saving users to CoreData store \(error.localizedDescription)")
            return false
        }
    }

    func loadSongsFromJSON() -> Bool{
        guard let songs = testData.songs else {
            print("Could not load songs data")
            return false
        }
         songs.forEach({ song in _ =
            song.convertToManagedObject(self.context!)
         })
         do {
            try self.context!.save()
            return true
         } catch {
             print("Error saving songs to CoreData store \(error.localizedDescription)")
            return false
         }
    }
    
    func loadSongInstancesFromJSON() -> Bool{
        guard let songInstances = testData.songInstances else {
                print("Could not load song instances data")
                return false
        }
         songInstances.forEach({ songInstance in _ =
            songInstance.convertToManagedObject(self.context!)
         })
         do {
            try self.context!.save()
            return true
         } catch {
             print("Error saving song instances to CoreData store \(error.localizedDescription)")
            return false
         }
    }
    
    // INITIAL RELATIONSHIPS
    func assignAllInitialRelationships() -> Bool {
        _ = self.assignInitialFollowRequestsForMainUser()
        _ = self.assignMainUsersSentFollowRequests()
        _ = self.assignInitialFriendshipsToUser()
        // need to assign stash relationships
        return true
    }
    
    func assignInitialFriendshipsToUser() -> Bool{
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let bobFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        bobFriendRequest.predicate = NSPredicate(format: "name == %@", "Bob LobLaw")
        do {
            let sarah = try self.context!.fetch(sarahFriendRequest).first!
            CRManager.userIsFriends(user: CDataRetManager.fetchMainUser()!, friend: sarah)
            let bob = try self.context!.fetch(bobFriendRequest).first!
            CRManager.userIsFriends(user: CDataRetManager.fetchMainUser()!, friend: bob)
            try self.context!.save()
            return true
        } catch {
            print("Could no assign friendship between test users and main user \(error.localizedDescription)")
            return false
        }
    }
    
    func assignInitialFollowRequestsForMainUser() -> Bool{
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let peterRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        peterRequest.predicate = NSPredicate(format: "name == %@", "Peter Parker")
        do {
            let peter = try self.context!.fetch(peterRequest).first!
            CRManager.userSentFollowRequest(from: peter, to: CDataRetManager.fetchMainUser()!)
            try self.context!.save()
            return true
        } catch {
            print("Could not assign follow requests sent by test users to main user \(error.localizedDescription)")
            return false
        }
    }
    
    func assignMainUsersSentFollowRequests() -> Bool {
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let cousinVinnyRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        cousinVinnyRequest.predicate = NSPredicate(format: "name == %@", "Vinny Gambini")
        do {
            let myCousinVinny = try self.context!.fetch(cousinVinnyRequest).first!
            CRManager.userSentFollowRequest(from: CDataRetManager.fetchMainUser()!, to: myCousinVinny)
            try self.context!.save()
            return true
        } catch {
            print("Could not assign follow requests sent to test users by main user \(error.localizedDescription)")
            return false
        }
    }
    
    // CLEARING CORE DATA METHODS
    func emptyDB() -> Bool {
        print("EMPTYING DB")
        _ = self.deleteAllSongs()
        _ = self.deleteAllUsers()
        return true
    }
    
    func deleteAllSongs() -> Bool {
        let songFetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        do {
            let songs = try self.context!.fetch(songFetchRequest)
            songs.forEach{ self.context!.delete($0)}
            return true
        } catch {
            print("Error deleting Songs: \(error.localizedDescription)")
            return false
        }
    }
    
    func deleteAllUsers() -> Bool {
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let users = try self.context!.fetch(userFetchRequest)
            users.forEach{ context!.delete($0)}
            return true
        } catch {
            print("Error deleting Users: \(error.localizedDescription)")
            return false
        }
    }
    
    func saveSongInstance(songName: String, instanceOf: Song, playedBy: UserEntity, artist: String = "", genre: String = "", songLength: Decimal?) {
       
        let song = Song(name: songName, artist: artist, genre: genre, image: "", songLength: songLength ?? 0.0)
        let newSongInstance = SongInstance(id: UUID(), songName: songName, dateListened: Date(), instanceOf: song, playedBy: User(userEntity: playedBy))
        do {
            _ = newSongInstance.convertToManagedObject(self.context!)
            try self.context!.save()
        } catch {
            print("Couldn't save new song instance: \(error.localizedDescription)")
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
//            print("SONGINSTANCES -> \(songInstances ?? [SongInstance]())")
            }
        } catch {
            print("Error occurred for song instances decoding process \(error.localizedDescription)")
        }
    }
}
