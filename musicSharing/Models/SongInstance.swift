//
//  SongInstance.swift
//  musicSharing
//
//  Created by Varghese Thomas on 07/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
 
struct SongInstance: Codable, Identifiable, Hashable {
    
    public var id: UUID = UUID()
    let songName: String  // need additional attribute so can use NSSortDescriptor--using the id leads to an Obj-C thread exception
    let songLink: String
    let dateListened: Date
    var instanceOf: Song
    var playedBy: User
    var likers = [User]()
    var stashers = [User]()
    var comments = [Comment]()
    
    
    func convertToManagedObject(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> SongInstanceEntity {
        let instanceEntity = NSEntityDescription.insertNewObject(forEntityName: "SongInstanceEntity", into: context!) as! SongInstanceEntity
        instanceEntity.instance_id = self.id
        instanceEntity.date_listened = self.dateListened
        instanceEntity.song_name = self.songName
        instanceEntity.song_link = self.songLink
        instanceEntity.instance_of = self.instanceOf.convertToManagedObject(context)
        instanceEntity.liked_by = NSSet()
        instanceEntity.stashed_by = NSSet()
        instanceEntity.has_comments = NSSet()
        instanceEntity.played_by = self.playedBy.convertToManagedObject(context)
        print("converted to managed object: \(self.id), \(self.songName), \(self.playedBy.name)")
        return instanceEntity
    }
    
}


extension SongInstance {
    init(instanceEntity: SongInstanceEntity) {
        self.id = instanceEntity.instance_id!
        self.songName = instanceEntity.song_name!
        self.songLink = instanceEntity.song_link!
        self.dateListened = instanceEntity.date_listened!
        self.instanceOf = Song(songEntity: instanceEntity.instance_of!)
        self.playedBy = User(userEntity: instanceEntity.played_by!)
        self.likers = self.getPeopleLikes(instanceEntity: instanceEntity)
        self.stashers = self.getStashers(instanceEntity: instanceEntity)
        self.comments = self.getComments(instanceEntity: instanceEntity)
    }
    
    func instantiateEntityFromExisting(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> SongInstanceEntity {
        return SongInstanceEntity(context: context!)
    }
    
    // look into removing these helper methods below -- can do the fetches and all within the data manager class
    func getPeopleLikes(instanceEntity: SongInstanceEntity) -> [User] {
        // for each SongInstanceEntity, get all the people who liked the song
        var likers = [User]()
        if instanceEntity.liked_by?.allObjects as? [UserEntity] == nil {
            return likers
        }
        for liker in instanceEntity.liked_by!.allObjects as! [UserEntity]{
            let user = User(userEntity: liker)
            likers.append(user)
        }
        return likers
    }
    
    func getStashers(instanceEntity: SongInstanceEntity) -> [User] {
        var stashers = [User]()
        if instanceEntity.stashed_by?.allObjects as? [UserEntity] == nil {
            return stashers
        }
        for stasher in instanceEntity.stashed_by!.allObjects as! [UserEntity] {
            let user = User(userEntity: stasher)
            stashers.append(user)
        }
        return stashers
    }
    
    func getComments(instanceEntity: SongInstanceEntity) -> [Comment] {
        var comments = [Comment]()
        if instanceEntity.has_comments?.allObjects as? [Comment] == nil {
            return comments
        }
        for commentEnt in instanceEntity.has_comments!.allObjects as! [CommentEntity] {
            let comment = Comment(commentEntity: commentEnt)
            comments.append(comment)
        }
        return comments
    }
}

