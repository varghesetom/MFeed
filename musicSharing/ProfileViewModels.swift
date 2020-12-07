//
//  Profile.swift
//  musicSharing
//
//  Created by Varghese Thomas on 06/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import SwiftUI

class ProfileViewModel: ObservableObject {
    // used to track info on whether profile is the main user, friend, or stranger. Is used to initialize all the profile view components in "ProfileView".
    @Published var TDManager: TestDataManager
    @Published var user: User = User(name: "", user_bio: "", avatar: "")
    @Published var isMainUser = true
    @Published var isFriendOfMainUser = false
    
    init(_ manager: TestDataManager, _ person: User) {
        self.TDManager = manager
        determineUser(manager: manager, person: person, isMainUser: &isMainUser, isFriendOfMainUser: &isFriendOfMainUser)
        self.user = person
    }
    
    func determineUser(manager: TestDataManager, person: User, isMainUser: inout Bool, isFriendOfMainUser: inout Bool) {
        
        if !self.isMainUser(manager: manager, check: person) {
            isMainUser = false
        }
        if manager.isUserFriendsWithMainUser(id: person.id) {
            isFriendOfMainUser = true
        }
    }
    
    func isMainUser(manager: TestDataManager, check: User) -> Bool {
        return check == User(userEntity: manager.fetchMainUser()!) ? true : false
    }
}

class ProfileButtonsViewModel: ObservableObject {
    // used as an observed object to track a user's songs, friends, and follow requests
    
    @Published var stashedSongInstances = [SongInstance]()
    @Published var userFriends = [User]()
    @Published var followsRequestedFrom = [User]()
    @Published var usersRequestedToBeFriends = [User]()
    @Published var mostRecentSong = [SongInstance]()
    @ObservedObject var userProfile: ProfileViewModel
    
    init(userProfile: ProfileViewModel) {
        self.userProfile = userProfile
    }
//    var TDManager: TestDataManager
//    private var user: User
//    private var isMainUser = true
//    private var isFriendOfMainUser = false
//
//    init(_ manager: TestDataManager, person: User) {
//        self.TDManager = manager
//        self.user = person
//    }

    func update() {
        self.updateStashedSongs()
        self.updateFriends()
        self.updateReceived()
        self.updateSent()
    }
    
    func updateMostRecentSong() {
        if let mostRecentSongInstanceEntity = self.userProfile.TDManager.getRecentlyListenedSongFromUser(self.userProfile.user.id.uuidString) {
            self.mostRecentSong = mostRecentSongInstanceEntity.map {
                SongInstance(instanceEntity: $0)
            }
        }
    }
    
    func updateStashedSongs() {
        if let userStashedSongEntities = self.userProfile.TDManager.getStashFromUser(self.userProfile.user.id.uuidString) {
            self.stashedSongInstances = userStashedSongEntities.map {
                SongInstance(instanceEntity: $0)
            }
        }
    }
    
    func updateFriends() {
        if let userFriendEntities = self.userProfile.TDManager.getUsersFriends(self.userProfile.user.id.uuidString) {
            self.userFriends = userFriendEntities.map {
                User(userEntity: $0)
            }
        }
    }
    
    func updateReceived() {
        if let receivedEntities = self.userProfile.TDManager.getReceivedFollowRequestsForUser(self.userProfile.user.id.uuidString) {
            self.followsRequestedFrom = receivedEntities.map {
                User(userEntity: $0)
            }
        }
    }
    
    func updateSent() {
        if let sentEntities = self.userProfile.TDManager.getFollowRequestsSentByUser(self.userProfile.user.id.uuidString) {
            self.usersRequestedToBeFriends = sentEntities.map {
                User(userEntity: $0)
            }
        }
    }
}
