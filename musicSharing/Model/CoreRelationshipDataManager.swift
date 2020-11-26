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
    
    static func userStashesSong(user: UserEntity = TestDataManager.mainUser, songInstance: SongInstanceEntity) {
        user.addToStashes_this(songInstance)
    }
    
    static func userListenedToSong(user: UserEntity = TestDataManager.mainUser, songInstance: SongInstanceEntity) {
        user.addToListened_to(songInstance)
    }
    
    static func userLikesSong(user: UserEntity = TestDataManager.mainUser, songInstance: SongInstanceEntity) {
        user.addToLikes_this(songInstance)
    }
    
    static func userCommentsOnSong(user: UserEntity = TestDataManager.mainUser, songInstance: SongInstanceEntity) {
        user.addToCommented_on(songInstance)
    }
    
    static func userIsFriends(user: UserEntity = TestDataManager.mainUser, friend: UserEntity) {
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
}

