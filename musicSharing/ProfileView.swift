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
    @ObservedObject var userProfile: ProfileViewModel
    
    var body: some View {
        VStack {
            UserBox(userProfile: userProfile)
            Spacer()
            BottomHalfOfProfile(userProfile: userProfile)
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)  // need to set frame to max possible otherwise the sides will still appear as white
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct UserBox: View {
    @ObservedObject var userProfile: ProfileViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image(self.userProfile.user.avatar!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle()) // apply the clipshape before setting the frame otherwise won't get a full circle
                        .frame(width: 150, height: 160, alignment: .leading)
                    Spacer()
                }
                Spacer()
                VStack(alignment: .leading) {
                    Spacer()
                    Text("\(self.userProfile.user.name)")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .bold()
                    if self.userProfile.isMainUser || self.userProfile.isFriendOfMainUser {
                        Text("\(self.userProfile.user.user_bio!)")
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
            if self.userProfile.isMainUser || self.userProfile.isFriendOfMainUser {
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
    @State var mostRecentSong = [SongInstance]()
    @ObservedObject var userProfile: ProfileViewModel
    @ObservedObject var profileButtons: ProfileButtonsViewModel
    
    init(userProfile: ProfileViewModel) {
        self.userProfile = userProfile
        self.profileButtons = ProfileButtonsViewModel(userProfile: userProfile)
    }
    
    var body: some View {
         VStack {
            Text("Recent Song")
                .foregroundColor(.white)
                .font(.headline)
                .underline()
            if self.mostRecentSong.count == 0 {
                Text("No recently listened to song")
            } else {
                MusicTweet(self.userProfile.TDManager, songInstEnt: self.userProfile.TDManager.getRecentlyListenedSongFromUser(self.userProfile.user.id.uuidString)![0], Alignment.bottomLeading)
                    .scaleEffect(0.85)
            }
            HStack {
                Spacer()
                Button(action: {
                    self.isStashSheet.toggle()
                    self.profileButtons.updateStashedSongs()
                }) {
                    Text("Stash")
                }.sheet(isPresented: $isStashSheet) {
                    List {
                        ForEach(self.profileButtons.stashedSongInstances, id: \.self) {
                            Text("Song: \($0.songName)")
                        }
                    }
                }
                Spacer()
                Button(action: {
                    self.isFriendSheet.toggle()
                    self.profileButtons.updateFriends()
                }) {
                    Text("Friends")
                }.sheet(isPresented: $isFriendSheet) {
                    List {
                        ForEach(self.profileButtons.userFriends, id: \.self) {
                            Text("Friend: \($0.name)")
                        }
                    }
                }
                Spacer()
                Button(action: {
                    self.isFollowerSheet.toggle()
                    self.profileButtons.updateReceived()
                    print("The other fetched result was \(self.profileButtons.usersRequestedToBeFriends)")
                }) {
                    Text("Follow Requests")
                }.sheet(isPresented: $isFollowerSheet) {
                    List {
                        ForEach(self.profileButtons.followsRequestedFrom, id: \.self) {
                            Text("Request from: \($0.name)")
                        }
                    }
                }
                Spacer()
            }
         }.onAppear(){
            if let mostRecentSongInstanceEntity = self.userProfile.TDManager.getRecentlyListenedSongFromUser() {
                self.mostRecentSong = mostRecentSongInstanceEntity.map {
                    SongInstance(instanceEntity: $0)
                }
            }
        }
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

