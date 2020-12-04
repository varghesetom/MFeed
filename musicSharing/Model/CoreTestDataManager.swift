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
    
    init(_ memoryType: StorageType = .persistent) {
        self.memoryType = memoryType
    }
    lazy var context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    lazy var testData = JSONTestData()
    lazy var CRManager = CoreRelationshipDataManager()
    lazy var CDataRetManager = CoreDataRetrievalManager()
    
    func saveFakeData() {
        print("SAVING FAKE DATA")
        self.loadUsersFromJSON()
        self.loadSongsFromJSON()
        self.loadSongInstancesFromJSON()
        self.assignAllInitialRelationships()
    }
    
    func loadUsersFromJSON() {
        guard let users = testData.users else {
            print("Could not load users data")
            return
        }
        users.forEach({ user in _ =
            user.convertToManagedObject(self.context!)
        })
        
        do {
            try self.context!.save()
        } catch {
            print("Error saving users to CoreData store \(error.localizedDescription)")
        }
    }

    func loadSongsFromJSON() {
        guard let songs = testData.songs else {
            print("Could not load songs data")
            return
        }
         songs.forEach({ song in _ =
            song.convertToManagedObject(self.context!)
         })
         
         do {
            try self.context!.save()
         } catch {
             print("Error saving songs to CoreData store \(error.localizedDescription)")
         }
    }
    
    func loadSongInstancesFromJSON() {
        guard let songInstances = testData.songInstances else {
                print("Could not load song instances data")
                return
        }
         songInstances.forEach({ songInstance in _ =
            songInstance.convertToManagedObject(self.context!)
         })
         
         do {
            try self.context!.save()
         } catch {
             print("Error saving song instances to CoreData store \(error.localizedDescription)")
         }
    }
    
    // INITIAL RELATIONSHIPS
    func assignAllInitialRelationships() {
        self.assignInitialFollowRequestsForMainUser()
        self.assignMainUsersSentFollowRequests()
        self.assignInitialFriendshipsToUser()
        // need to assign stash relationships
    }
    
    func assignInitialFriendshipsToUser() {
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
        } catch {
            print("Could no assign friendship between test users and main user \(error.localizedDescription)")
        }
    }
    
    func assignInitialFollowRequestsForMainUser() {
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let peterRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        peterRequest.predicate = NSPredicate(format: "name == %@", "Peter Parker")
        do {
            let peter = try self.context!.fetch(peterRequest).first!
            CRManager.userSentFollowRequest(from: peter, to: CDataRetManager.fetchMainUser()!)
            try self.context!.save()
        } catch {
            print("Could not assign follow requests sent by test users to main user \(error.localizedDescription)")
        }
    }
    
    func assignMainUsersSentFollowRequests() {
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let cousinVinnyRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        cousinVinnyRequest.predicate = NSPredicate(format: "name == %@", "Vinny Gambini")
        do {
            let myCousinVinny = try self.context!.fetch(cousinVinnyRequest).first!
            CRManager.userSentFollowRequest(from: CDataRetManager.fetchMainUser()!, to: myCousinVinny)
            try self.context!.save()
        } catch {
            print("Could not assign follow requests sent to test users by main user \(error.localizedDescription)")
        }
    }
    
    // CLEARING CORE DATA METHODS
    func emptyDB() {
        print("EMPTYING DB")
        self.deleteAllSongs()
        self.deleteAllUsers()
    }
    
    func deleteAllSongs(/*_ context: NSManagedObjectContext*/) {
        let songFetchRequest: NSFetchRequest<SongEntity> = SongEntity.fetchRequest()
        do {
            let songs = try self.context!.fetch(songFetchRequest)
            songs.forEach{ self.context!.delete($0)}
        } catch {
            print("Error deleting Songs: \(error.localizedDescription)")
        }
    }
    
    func deleteAllUsers() {
        let userFetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        do {
            let users = try self.context!.fetch(userFetchRequest)
            users.forEach{ context!.delete($0)}
        } catch {
            print("Error deleting Users: \(error.localizedDescription)")
        }
    }
    
    func saveSongInstance(songName: String, instanceOf: Song, playedBy: UserEntity, artist: String = "", genre: String = "", songLength: Decimal?) {
       
        let song = Song(name: songName, artist: artist, genre: genre, image: "", songLength: songLength ?? 0.0)
        let newSongInstance = SongInstance(id: UUID(), songName: songName, dateListened: Date(), instanceOf: song, playedBy: User(userEntity: playedBy))
        do {
            newSongInstance.convertToManagedObject(self.context!)
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
