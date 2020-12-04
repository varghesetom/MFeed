//
//  ProfileView.swift
//  schoolProject
//
//  Created by Varghese Thomas on 19/11/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import SwiftUI
import CoreData

#if DEBUG
struct ProfileView: View {
    var body: some View {
        VStack {
            UserBox()
            Spacer()
            BottomHalfOfProfile()
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)  // need to set frame to max possible otherwise the sides will still appear as white
        .background(Color.black.edgesIgnoringSafeArea(.all))
        
    }
}
#endif

// will contain the most recent music tweet (which also means including a date attribute...) and Stash, Friends, and Edit buttons
struct BottomHalfOfProfile: View {
    @State var isStashSheet = false
    @State var isFriendSheet = false
    @State var isFollowerSheet = false
    @State var stashedSongInstances = [SongInstance]()
    @State var userFriendEntities = [User]()
    @State var receivedEntities = [User]()
    @State var sentEntities = [User]()
    var CDataRetManager = CoreDataRetrievalManager()
    
    init() {
//        _mostRecentSong = .init(fetchRequest: CDataRetManager.getRecentlyListenedSongFromMainUser)
////        _userStashedSongs = .init(fetchRequest: CDataRetManager.getStashFromMainUser)
//        _userFriendEntities = .init(fetchRequest: CDataRetManager.getMainUsersFriends)
//        _receivedEntities = .init(fetchRequest: CDataRetManager.getReceivedFollowRequestsForMainUser)
//        _sentEntities = .init(fetchRequest: CDataRetManager.getFollowRequestsSentByMainUser)
    }
    
    var body: some View {
        if let userStashedSongEntities = CDataRetManager.getStashFromMainUser() {
            stashedSongInstances = userStashedSongEntities.map {
                SongInstance(instanceEntity: $0)
            }
        }

//        let mostRecentSongInstanceEntity = mostRecentSong[0]
//
//        let userFriends = userFriendEntities.map {
//            User(userEntity: $0)
//        }
//        let followsRequestedFrom = receivedEntities.map {
//            User(userEntity: $0)
//        }
//        let usersRequestedToBeFriends = sentEntities.map {
//            User(userEntity: $0)
//        }
        
        return AnyView(
            VStack {
                Text("Recent Song")
                    .foregroundColor(.white)
                    .font(.headline)
                    .underline()
                MusicTweet(songInstance: mostRecentSongInstanceEntity, alignment: Alignment.bottomLeading).scaleEffect(0.85)
                HStack {
                    Spacer()
                    Button(action: {
                        self.isStashSheet.toggle()
                    }) {
                        Text("Stash")
                    }.sheet(isPresented: $isStashSheet) {
                        List {
                            ForEach(stashedSongInstances, id: \.self) {
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
                            ForEach(userFriends, id: \.self) {
                                Text("Friend: \($0.name)")
                            }
                        }
                    }
                    Spacer()
                    Button(action: {
                        self.isFollowerSheet.toggle()
                        print("The other fetched result was \(usersRequestedToBeFriends)")
                    }) {
                        Text("Follow Requests")
                    }.sheet(isPresented: $isFollowerSheet) {
                        List {
                            ForEach(followsRequestedFrom, id: \.self) {
                                Text("Request from: \($0.name)")
                            }
                        }
                    }
                    Spacer()
                }
            }
        )
    }
}

struct UserBox: View {
    private var CDataRetManager = CoreDataRetrievalManager()
    private var user: User
    
    init() {
        self.user = User(userEntity: CDataRetManager.fetchMainUser()!)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Image("johnsmith")
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
                    Text("\(user.user_bio!)")
                        .foregroundColor(.white)
                        .font(.subheadline)
                        .italic()
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    Spacer()
                    Spacer()
                }
                Spacer()
                Spacer()
            }
            HStack {
                VStack(alignment: .center) {
                    Spacer()
                    Spacer()
                    HStack {
                        GenreSeeking(genre: "Rock")
                        GenreSeeking(genre: "Classical")
                        GenreSeeking(genre: "Techno")
                    }
                    Spacer()
                    HStack {
                        GenreSeeking(genre: "HipHop")
                        GenreSeeking(genre: "Country")
                        GenreSeeking(genre: "Religious")
                    }
                }
            }
        }
        .frame(width: 300, height: 300, alignment: .center)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue, lineWidth: 4))
    }
}

struct GenreSeeking: View {
    @State var genre: String
    @State var didSelectGenre = false
    @State private var chosenGenre = LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing)
    @State private var unselected = LinearGradient(gradient: Gradient(colors: [ Color.white, Color.gray]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Button(action: {
            self.didSelectGenre.toggle()
        }) {
            Text("\(genre)")
                .padding(2)
                .font(.subheadline)
                .allowsTightening(true)
        }
        .buttonStyle(didSelectGenre ? GenreSeekingStyle(selectedColor: chosenGenre) : GenreSeekingStyle(selectedColor: unselected))
    }
}

struct GenreSeekingStyle: ButtonStyle {
    
    @State var selectedColor: LinearGradient
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(15)
            .foregroundColor(.black)
            .background(RoundedRectangle(cornerRadius: 10).fill(selectedColor))
            .compositingGroup()
            .shadow(color: .blue, radius: 20)
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 1.2 : 1.0)
            .cornerRadius(5)
            .scaledToFit()
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            UserBox()
            Spacer()
            BottomHalfOfProfile()
            Spacer()
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)  // need to set frame to max possible otherwise the sides will still appear as white
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
