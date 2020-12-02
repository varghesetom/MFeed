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
     
     Most of these functions take the POV of the main user so a main_user default argument is given as well
     */
    static var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    static func userStashesSong(user: UserEntity = TestDataManager.mainUser!, songInstance: SongInstanceEntity) {
        user.addToStashes_this(songInstance)
    }
    
    static func userListenedToSong(user: UserEntity = TestDataManager.mainUser!, songInstance: SongInstanceEntity) {
        user.addToListened_to(songInstance)
    }
    
    static func userLikesSong(user: UserEntity = TestDataManager.mainUser!, songInstance: SongInstanceEntity) {
        user.addToLikes_this(songInstance)
    }
    
    static func userCommentsOnSong(user: UserEntity = TestDataManager.mainUser!, songInstance: SongInstanceEntity) {
        user.addToCommented_on(songInstance)
    }
    
    static func userIsFriends(user: UserEntity = TestDataManager.mainUser!, friend: UserEntity) {
        user.addToIs_friends_with(friend)
    }
    
    static func userSentFollowRequest(from: UserEntity, to: UserEntity) {
        from.addToSent_follow_request(to)
    }
    
    /* Deleting Database relationships */
    
    static func userUnlikesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.removeFromLikes_this(songInstance)
    }

    static func userUncommentsSong(user: UserEntity, songInstance: SongInstanceEntity) {
           user.removeFromCommented_on(songInstance)
       }
    
    static func userUnstashesSong(user: UserEntity, songInstance: SongInstanceEntity) {
        user.removeFromStashes_this(songInstance)
    }
    
    static func assignAllInitialRelationships() {
        CoreRelationshipDataManager.assignInitialFollowRequestsForMainUser()
        CoreRelationshipDataManager.assignMainUsersSentFollowRequests()
        CoreRelationshipDataManager.assignInitialFriendshipsToUser()
    }
    
    // Initial relationship assignments for  TEST DATA
    static func assignInitialFriendshipsToUser() {
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let bobFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        bobFriendRequest.predicate = NSPredicate(format: "name == %@", "Bob LobLaw")
        do {
            let sarah = try TestDataManager.context.fetch(sarahFriendRequest).first!
            CoreRelationshipDataManager.userIsFriends(user: TestDataManager.mainUser!, friend: sarah)
            let bob = try TestDataManager.context.fetch(bobFriendRequest).first!
            CoreRelationshipDataManager.userIsFriends(user: TestDataManager.mainUser!, friend: bob)
            try TestDataManager.context.save()
        } catch {
            print("Could no assign friendship between test users and main user \(error.localizedDescription)")
        }
    }
    
    static func assignInitialFollowRequestsForMainUser() {
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let peterRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        peterRequest.predicate = NSPredicate(format: "name == %@", "Peter Parker")
        do {
            let peter = try TestDataManager.context.fetch(peterRequest).first!
                CoreRelationshipDataManager.userSentFollowRequest(from: peter, to: TestDataManager.mainUser!)
            try TestDataManager.context.save()
        } catch {
            print("Could not assign follow requests sent by test users to main user \(error.localizedDescription)")
        }
    }
    
    static func assignMainUsersSentFollowRequests() {
        let sarahFriendRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        sarahFriendRequest.predicate = NSPredicate(format: "name == %@", "Sarah Connor")
        let cousinVinnyRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        cousinVinnyRequest.predicate = NSPredicate(format: "name == %@", "Vinny Gambini")
        do {
            let myCousinVinny = try TestDataManager.context.fetch(cousinVinnyRequest).first!
            CoreRelationshipDataManager.userSentFollowRequest(from: TestDataManager.mainUser!, to: myCousinVinny)
            try TestDataManager.context.save()
        } catch {
            print("Could not assign follow requests sent to test users by main user \(error.localizedDescription)")
        }
    }
}

