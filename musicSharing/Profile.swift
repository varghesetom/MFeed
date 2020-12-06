//
//  Profile.swift
//  musicSharing
//
//  Created by Varghese Thomas on 06/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation

class Profile: ObservableObject {
    @Published var stashedSongInstances = [SongInstance]()
    @Published var stashedSongInstances = [SongInstance]()
    @Published var userFriends = [User]()
    @Published var followsRequestedFrom = [User]()
    @Published var usersRequestedToBeFriends = [User]()
    @Published var mostRecentSong = [SongInstance]()
    var TDManager: TestDataManager
    private var user: User
    private var isMainUser = true
    private var isFriendOfMainUser = false
    
    init(_ manager: TestDataManager, user: User) {
        self.TDManager = manager
        self.user = User(userEntity: self.TDManager.fetchMainUser()!)
        determineUser(manager: self.TDManager, person: user, isMainUser: &isMainUser, isFriendOfMainUser: &isFriendOfMainUser)
    }
    
}
