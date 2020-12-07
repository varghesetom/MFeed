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
                MainUserGenres(userProfile: self.userProfile)
            }
        }
        .frame(width: 300, height: 300, alignment: .center)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue, lineWidth: 4))
    }
}

struct MainUserGenres: View {
    @ObservedObject var userProfile: ProfileViewModel
    
    init(userProfile: ProfileViewModel){
        self.userProfile = userProfile
    }
    var body: some View {
        HStack {
            VStack(alignment: .center) {
                Spacer()
                Spacer()
                HStack {
                    GenreSeekingButton(genre: "Rock", userProfile: self.userProfile)
                    GenreSeekingButton(genre: "Classical", userProfile: self.userProfile)
                    GenreSeekingButton(genre: "Techno", userProfile: self.userProfile)
                }
                Spacer()
                HStack {
                    GenreSeekingButton(genre: "HipHop", userProfile: self.userProfile)
                    GenreSeekingButton(genre: "Country", userProfile: self.userProfile)
                    GenreSeekingButton(genre: "Religious", userProfile: self.userProfile)
                }
            }
        }
    }
}

struct GenreSeekingButton: View {
    @State var genre: String
    @ObservedObject var userProfile: ProfileViewModel
    @State var toggledGenres = [Genre]()
    @State var toggleRock = false
    @State var toggleClassical = false
    @State var toggleTechno = false
    @State var toggleHipHop = false
    @State var toggleCountry = false
    @State var toggleReligious = false
    @State var displayButtonEffect = false
    @State var turnOffInitialToggle = false
    @State private var chosenGenre = LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing)
    @State private var unselected = LinearGradient(gradient: Gradient(colors: [ Color.white, Color.gray]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Button(action: {
            if self.userProfile.isMainUser {
                if self.displayButtonEffect {  // display effect was on and now turning it off
                    self.displayButtonEffect = false
                    self.turnOffInitialToggle = true
                    if self.checkIfUserAlreadyHasGenre(genreName: self.genre) {
                        print("User did toggle genre")
                        self.removeGenreRelationships(genreName: self.genre)
                    }
                } else {  // turning on the display
                    self.displayButtonEffect = true
                    
                    // check if already has genre before needing to add
                    if !self.checkIfUserAlreadyHasGenre(genreName: self.genre) {
                        print("User did not toggle genre")
                        let userEnt = self.userProfile.TDManager.getUser(self.userProfile.user.id.uuidString)
                        let genreEnt = self.userProfile.TDManager.getGenreEntity(genre: Genre(genre: self.genre))
                        self.userProfile.TDManager.userToggleGenre(user: userEnt!, genreEntity: genreEnt!)
                    }
                }
            }
        }) {
            Text("\(genre)")
                .padding(2)
                .font(.subheadline)
                .allowsTightening(true)
        }
        .onAppear() {
                print("\n\n\nNextUpdate")
                self.getInitialToggledGenres()
        }
        .buttonStyle((self.ifMainUserSelectedAndDidSelect() || self.didInitialToggle()) && !self.turnOffInitialToggle ? GenreSeekingStyle(selectedColor: chosenGenre) : GenreSeekingStyle(selectedColor: unselected))
    }
    

    func ifMainUserSelectedAndDidSelect() -> Bool {
        return (self.userProfile.isMainUser && self.displayButtonEffect) ? true : false
    }

    func getInitialToggledGenres() {
        if let userGenreEnts = self.userProfile.TDManager.getGenresForUser(id: self.userProfile.user.id) {
            toggledGenres = userGenreEnts.map { Genre(genreEntity: $0)}
        }
//        toggledGenres = self.userProfile.getUpdatedToggled(toggledGenres: &toggledGenres)
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
        print("User: \(self.userProfile.user.name)'s genres: \(self.toggledGenres)")
        print("TOGGLED: \(toggleRock), \(toggleClassical), \(toggleTechno), \(toggleHipHop), \(toggleCountry), \(toggleReligious)")
    }
    
    func didInitialToggle() -> Bool {
        if self.turnOffInitialToggle { return false }
        switch genre {
        case "Rock": return self.toggleRock
        case "Classical": return self.toggleClassical
        case "Techno" : return self.toggleTechno
        case "HipHop": return self.toggleHipHop
        case "Country": return self.toggleCountry
        case "Religious": return self.toggleReligious
        default:
            print("Ignoring")
            return false
        }
    }
    
    func checkIfUserAlreadyHasGenre(genreName: String) -> Bool {
        let genreEnts = self.userProfile.TDManager.getGenresForUser(id: self.userProfile.user.id)
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
        let userEnt = self.userProfile.TDManager.getUser(self.userProfile.user.id.uuidString)
        toggledGenres = self.userProfile.TDManager.getAllGenreForUser(id: self.userProfile.user.id, genreName: genreName)
        for genre in toggledGenres {
            if genre.genre == genreName {
                let genreEnt = self.userProfile.TDManager.getGenreEntity(genre: genre)
                print("Untoggling relationship \(genre.genre) for \(User(userEntity: userEnt!))")
                self.userProfile.TDManager.userUntogglesGenre(user: userEnt!, genreEntity: genreEnt!)
                let fil = self.userProfile.user.genres.filter { $0.genre != genreName}
                toggledGenres = toggledGenres.filter { $0.genre != genreName }
                toggledGenres = fil
            }
        }
        try! self.userProfile.TDManager.context!.save()
        print("\nAfter untoggling, user's current genres are \(toggledGenres)")
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
        print("User -> \(self.userProfile.user.name) isMain: \(self.userProfile.isMainUser), isFriend: \(self.userProfile.isFriendOfMainUser), isStranger: \(self.userProfile.isStranger)")
    }
    
    var body: some View {
        
        VStack {
            if self.userProfile.isMainUser || self.userProfile.isFriendOfMainUser {
                ProfileRecentSongView(userProfile: self.userProfile)
                HStack {
                    Spacer()
                    ProfileStashButtonView(isStashSheet: self.$isStashSheet, profileButtons: self.profileButtons)
                    Spacer()
                    if self.userProfile.isMainUser {
                        
                        ProfileFriendsButtonView(isFriendSheet: self.$isFriendSheet, profileButtons: self.profileButtons)
                         Spacer()
                         ProfileFollowRequestsButtonView(isFollowerSheet: self.$isFollowerSheet, profileButtons: self.profileButtons)
                         Spacer()
                    }
                }
            } else {
                Text("Information Unavailable")
            }
        }
    }
}


struct ProfileRecentSongView: View {
    @State var mostRecentSong = [SongInstance]()
    var userProfile: ProfileViewModel
    
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
        }
        .onAppear(){
            if let mostRecentSongInstanceEntity = self.userProfile.TDManager.getRecentlyListenedSongFromUser() {
                self.mostRecentSong = mostRecentSongInstanceEntity.map {
                    SongInstance(instanceEntity: $0)
                }
            }
        }
    }
}

struct ProfileStashButtonView: View {
    @Binding var isStashSheet: Bool
    var profileButtons: ProfileButtonsViewModel
    var body: some View {
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
    }
}

struct ProfileFriendsButtonView: View {
    @Binding var isFriendSheet: Bool
    var profileButtons: ProfileButtonsViewModel
    
    var body: some View {
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
    }
}

struct ProfileFollowRequestsButtonView: View {
    @Binding var isFollowerSheet: Bool
    var profileButtons: ProfileButtonsViewModel
    
    var body: some View {
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

