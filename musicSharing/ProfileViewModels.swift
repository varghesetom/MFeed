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
    var TDManager: TestDataManager
    var user: User
    @Published var isMainUser = false
    @Published var isFriendOfMainUser = false
    @Published var isStranger = false
    
    @Published var toggledGenres = [Genre]()
    @Published var toggleRock = false
    @Published var toggleClassical = false
    @Published var toggleTechno = false
    @Published var toggleHipHop = false
    @Published var toggleCountry = false
    @Published var toggleReligious = false
    @Published var displayButtonEffect = false
    
    init(_ manager: TestDataManager, _ person: User) {
        self.TDManager = manager
        self.user = person
        self.determineUser()
    }
    
    func determineUser() {
        if self.determineIfMainUser() {
            print("\(self.user.name) is main ")
            self.isMainUser = true
        }
        else if self.TDManager.isUserFriendsWithMainUser(id: self.user.id) {
            print("\(self.user.name) is friends ")
            self.isFriendOfMainUser = true
        }
        else {
            print("\(self.user.name) is not friends ")
            self.isStranger = true
            
        }
    }
    
    func determineIfMainUser() -> Bool {
        return self.user == User(userEntity: self.TDManager.fetchMainUser()!) ? true : false
    }
    
    func checkIfUserAlreadyHasGenre(genreName: String) -> Bool {
        let genreEnts = self.TDManager.getGenresForUser(id: self.user.id)
        if let unwrappedEnts = genreEnts {
            toggledGenres = unwrappedEnts.map {
                Genre(genreEntity: $0)
            }
        }
        if toggledGenres.filter({ genreName == $0.genre}).count > 0 {
            print("Exists in user's genres")
            return true
        }
        return false
    }
    
    func removeGenreRelationships(genreName: String) {
        let userEnt = self.TDManager.getUser(self.user.id.uuidString)
        toggledGenres = self.TDManager.getAllGenreForUser(id: self.user.id, genreName: genreName)
        for genre in toggledGenres {
            if genre.genre == genreName {
                let genreEnt = self.TDManager.getGenreEntity(genre: genre)
                print("Untoggling relationship \(genre.genre) for \(User(userEntity: userEnt!))")
                self.TDManager.userUntogglesGenre(user: userEnt!, genreEntity: genreEnt!)
                toggledGenres = toggledGenres.filter { $0.genre != genreName }
            }
        }
        try! self.TDManager.context!.save()
        print("\nAfter untoggling, user's current genres are \(toggledGenres)")
    }
    
    func updateToggledGenres() {
        toggleRock = false
        toggleReligious = false
        toggleClassical = false
        toggleTechno = false
        toggleCountry = false
        toggleHipHop = false
        if let userGenreEnts = self.TDManager.getGenresForUser(id: self.user.id) {
            toggledGenres = userGenreEnts.map { Genre(genreEntity: $0)}
        }
        for toggled in toggledGenres {
            switch toggled.genre {
            case "Rock": toggleRock = true
            case "Classical": toggleClassical = true
            case "Techno": toggleTechno = true
            case "HipHop": toggleHipHop = true
            case "Country": toggleCountry = true
            case "Religious": toggleReligious = true
            default:
                print("\nUnknown genre\n")
            }
        }
        print("User: \(self.user.name)'s genres: \(self.toggledGenres)")
        print("TOGGLED: \(toggleRock), \(toggleClassical), \(toggleTechno), \(toggleHipHop), \(toggleCountry), \(toggleReligious)")
    }
    
    func nonMainUserDidInitialToggle() {
        if self.isFriendOfMainUser {
            if let userGenreEnts = self.TDManager.getGenresForUser(id: self.user.id) {
                toggledGenres = userGenreEnts.map { Genre(genreEntity: $0)}
            }
            for toggled in toggledGenres {
                switch toggled.genre {
                case "Rock": toggleRock = true
                case "Classical": toggleClassical = true
                case "Techno": toggleTechno = true
                case "HipHop": toggleHipHop = true
                case "Country": toggleCountry = true
                case "Religious": toggleReligious = true
                default:
                    print("\nUnknown genre\n")
                }
            }
        }
    }

}


class ProfileButtonsViewModel: ObservableObject {
    // used to track a user's songs, friends, and follow requests
    
    @Published var stashedSongInstances = [SongInstance]()
    @Published var userFriends = [User]()
    @Published var followsRequestedFrom = [User]()
    @Published var usersRequestedToBeFriends = [User]()
    @Published var mostRecentSong = [SongInstance]()
    @ObservedObject var userProfile: ProfileViewModel
    
    init(userProfile: ProfileViewModel) {
        self.userProfile = userProfile
    }

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
