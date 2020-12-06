//
//  ProfileView.swift
//  schoolProject
//
//  Created by Varghese Thomas on 19/11/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import SwiftUI
import CoreData

struct ProfileView: View {
    private var TDManager: TestDataManager
    private var user: User
    private var isMainUser = true
    private var isFriendOfMainUser = false
    
    init(_ manager: TestDataManager, _ person: User) {
        self.TDManager = manager
        self.user = person
        // not main user -> determine if this person is a friend or not
        // if friend -> show everything
        // if not -> show only Name and Image with a "Send Follow"
        determineUser(manager: self.TDManager, person: user, isMainUser: &isMainUser, isFriendOfMainUser: &isFriendOfMainUser)
//        if !Self.isMainUser(manager: self.TDManager, check: person) {
//            self.isMainUser = false
//        }
//        if TDManager.isUserFriendsWithMainUser(id: person.id) {
//            self.isFriendOfMainUser = true
//        }
    }
    
    var body: some View {
        let mainUserView = UserView(TDManager, User(userEntity: TDManager.fetchMainUser()!))
        let friendView = UserView(TDManager, User(userEntity: TDManager.getUser(self.user.id.uuidString)!))
        if self.isMainUser {
            return mainUserView
        } else {
            return friendView
        }
    }
    
}

struct UserView: View {
    private var TDManager: TestDataManager
    private var user: User
    private var isMainUser = true
    private var isFriendOfMainUser = false
    
    init(_ manager: TestDataManager, _ user: User) {
        self.TDManager = manager
        self.user = user
        determineUser(manager: self.TDManager, person: user, isMainUser: &isMainUser, isFriendOfMainUser: &isFriendOfMainUser)
    }
    
    var body: some View {
        VStack {
            UserBox(self.TDManager, user: self.user)
            Spacer()
            BottomHalfOfProfile(self.TDManager, user: self.user)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)  // need to set frame to max possible otherwise the sides will still appear as white
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct UserBox: View {
    private var TDManager: TestDataManager
    private var user: User
    private var isMainUser = true
    private var isFriendOfMainUser = false
    
    init(_ manager: TestDataManager, user: User) {
        self.TDManager = manager
        self.user = User(userEntity: self.TDManager.fetchMainUser()!)
        determineUser(manager: self.TDManager, person: user, isMainUser: &isMainUser, isFriendOfMainUser: &isFriendOfMainUser)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(self.user.avatar!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle()) // apply the clipshape before setting the frame otherwise won't get a full circle
                        .frame(width: 150, height: 160, alignment: .leading)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Spacer()
                    Text("\(user.name)")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                    if self.isMainUser || self.isFriendOfMainUser {
                        Text("\(user.user_bio!)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .italic()
                            .minimumScaleFactor(0.5)
                            .allowsTightening(true)
                    }
                    Spacer()
                    Spacer()
                }
                Spacer()
                Spacer()
            }
            if self.isMainUser || self.isFriendOfMainUser {
                MainUserGenres()
            }
        }
        .frame(width: 300, height: 300, alignment: .center)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue, lineWidth: 4))
    }
}

struct MainUserGenres: View {
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Spacer()
                Spacer()
                HStack {
                    GenreSeekingButton(genre: "Rock")
                    GenreSeekingButton(genre: "Classical")
                    GenreSeekingButton(genre: "Techno")
                }
                Spacer()
                HStack {
                    GenreSeekingButton(genre: "HipHop")
                    GenreSeekingButton(genre: "Country")
                    GenreSeekingButton(genre: "Religious")
                }
            }
        }
    }
}

// will contain the most recent music tweet (which also means including a date attribute...) and Stash, Friends, and Edit buttons
struct BottomHalfOfProfile: View {
    @State var isStashSheet = false
    @State var isFriendSheet = false
    @State var isFollowerSheet = false
    @State var stashedSongInstances = [SongInstance]()
    @State var userFriends = [User]()
    @State var followsRequestedFrom = [User]()
    @State var usersRequestedToBeFriends = [User]()
    @State var mostRecentSong = [SongInstance]()
    var TDManager: TestDataManager
    private var user: User
    private var isMainUser = true
    private var isFriendOfMainUser = false
    
    init(_ manager: TestDataManager, user: User) {
        self.TDManager = manager
        self.user = User(userEntity: self.TDManager.fetchMainUser()!)
        determineUser(manager: self.TDManager, person: user, isMainUser: &isMainUser, isFriendOfMainUser: &isFriendOfMainUser)
    }
    var body: some View {
        VStack {
            Text("Recent Song")
                .foregroundColor(.white)
                .font(.headline)
                .underline()
            if mostRecentSong.count == 0 {
                Text("No recently listened to song")
            } else {
                MusicTweet(songInstance: self.TDManager.getRecentlyListenedSongFromUser()![0], alignment: Alignment.bottomLeading).scaleEffect(0.85)
            }
            HStack {
                Spacer()
                Button(action: {
                    self.isStashSheet.toggle()
                }) {
                    Text("Stash")
                }.sheet(isPresented: $isStashSheet) {
                    List {
                        ForEach(self.stashedSongInstances, id: \.self) {
                            Text("Song: \($0.songName)")
                        }
                    }
                }
                Spacer()
                Button(action: {
                    self.isFriendSheet.toggle()
                }) {
                    Text("Friends")
                }.sheet(isPresented: $isFriendSheet) {
                    List {
                        ForEach(self.userFriends, id: \.self) {
                            Text("Friend: \($0.name)")
                        }
                    }
                }
                Spacer()
                Button(action: {
                    self.isFollowerSheet.toggle()
                    print("The other fetched result was \(self.usersRequestedToBeFriends)")
                }) {
                    Text("Follow Requests")
                }.sheet(isPresented: $isFollowerSheet) {
                    List {
                        ForEach(self.followsRequestedFrom, id: \.self) {
                            Text("Request from: \($0.name)")
                        }
                    }
                }
                Spacer()
            }
        }
        .onAppear {
            if let mostRecentSongInstanceEntity = self.TDManager.getRecentlyListenedSongFromUser() {
                self.mostRecentSong = mostRecentSongInstanceEntity.map {
                    SongInstance(instanceEntity: $0)
                }
            }
            if let userStashedSongEntities = self.TDManager.getStashFromUser() {
                self.stashedSongInstances = userStashedSongEntities.map {
                    SongInstance(instanceEntity: $0)
                }
            }
            if let userFriendEntities = self.TDManager.getUsersFriends() {
                self.userFriends = userFriendEntities.map {
                    User(userEntity: $0)
                }
            }
            if let receivedEntities = self.TDManager.getReceivedFollowRequestsForUser() {
                self.followsRequestedFrom = receivedEntities.map {
                    User(userEntity: $0)
                }
            }
            if let sentEntities = self.TDManager.getFollowRequestsSentByUser() {
                self.usersRequestedToBeFriends = sentEntities.map {
                    User(userEntity: $0)
                }
            }
        }
    }
}

extension View {
    // bundle up the common functionalities for the ProfileView --> checking if the User is the main user, friend, or stranger
    
    func determineUser(manager: TestDataManager, person: User, isMainUser: inout Bool, isFriendOfMainUser: inout Bool) {
        
        if !Self.isMainUser(manager: manager, check: person) {
            isMainUser = false
        }
        if manager.isUserFriendsWithMainUser(id: person.id) {
            isFriendOfMainUser = true
        }
    }
    
    static func isMainUser(manager: TestDataManager, check: User) -> Bool {
        return check == User(userEntity: manager.fetchMainUser()!) ? true : false
    }
}



//struct ProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        VStack {
//            UserBox()
//            Spacer()
//            BottomHalfOfProfile()
//            Spacer()
//        }
//        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)  // need to set frame to max possible otherwise the sides will still appear as white
//        .background(Color.black.edgesIgnoringSafeArea(.all))
//    }
//}
