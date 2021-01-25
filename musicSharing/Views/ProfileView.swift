//
//  ProfileView.swift
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
                        .allowsTightening(true)
                        .minimumScaleFactor(0.7)
                    if self.userProfile.isMainUser || self.userProfile.isFriendOfMainUser {
                        Text("\(self.userProfile.user.user_bio!)")
                            .foregroundColor(.white)
                            .font(.subheadline)
                            .italic()
                            .allowsTightening(true)
                            .minimumScaleFactor(0.5)
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
            else {     // not a friend or main user -> so can send a follow request
                FollowRequestButtonView().environmentObject(self.userProfile)
            }
        }
        .frame(width: 300, height: 300, alignment: .center)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.blue, lineWidth: 4))
    }
}

struct FollowRequestButtonView: View {
    @EnvironmentObject var userProfile: ProfileViewModel
    @State var showRequestAlert = false
    var body: some View {
        Button(action: {
            self.showRequestAlert.toggle()
        }) {
            Text("Send Friend Request?")
        }.alert(isPresented: $showRequestAlert) {
            Alert(title: Text("Friend Request"),
                  message: Text("Do you want to send a friend request to \(self.userProfile.user.name)"),
                  primaryButton: .default(Text("Yes")) {
                    self.userProfile.receivedFollowRequestFromMainUser()
                  },
                  secondaryButton: .cancel(Text("Nah")))
        }
        .buttonStyle(FollowRequestStyle())
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
                    GenreSeekingButton(genre: "Rock", userProfile: self.userProfile, didToggle: self.$userProfile.toggleRock)
                    GenreSeekingButton(genre: "Classical", userProfile: self.userProfile, didToggle: self.$userProfile.toggleClassical)
                    GenreSeekingButton(genre: "Techno", userProfile: self.userProfile, didToggle: self.$userProfile.toggleTechno)
                }
                Spacer()
                HStack {
                    GenreSeekingButton(genre: "HipHop", userProfile: self.userProfile, didToggle: self.$userProfile.toggleHipHop)
                    GenreSeekingButton(genre: "Country", userProfile: self.userProfile, didToggle: self.$userProfile.toggleCountry)
                    GenreSeekingButton(genre: "Religious", userProfile: self.userProfile, didToggle: self.$userProfile.toggleReligious)
                }
            }
        }.onAppear() {
            self.userProfile.updateToggledGenres()
        }
    }
}

struct GenreSeekingButton: View {
    @State var genre: String
    @ObservedObject var userProfile: ProfileViewModel
    @Binding var didToggle: Bool
    @State private var chosenGenre = LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange]), startPoint: .leading, endPoint: .trailing)
    @State private var unselected = LinearGradient(gradient: Gradient(colors: [ Color.white, Color.gray]), startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Button(action: {
            if self.userProfile.isMainUser {
                if self.didToggle {  // display effect was on when clicked so remove genre relationship
                    if self.userProfile.checkIfUserAlreadyHasGenre(genreName: self.genre) {
                        self.userProfile.removeGenreRelationships(genreName: self.genre)
                    }
                } else {  // display effect was off and clicked so add the relationship
                    if !self.userProfile.checkIfUserAlreadyHasGenre(genreName: self.genre) { // check if already has genre before needing to add
                        let userEnt = self.userProfile.TDManager.getUser(self.userProfile.user.id.uuidString)
                        let genreEnt = self.userProfile.TDManager.getGenreEntity(genre: Genre(genre: self.genre))
                        self.userProfile.TDManager.userToggleGenre(user: userEnt!, genreEntity: genreEnt!)
                    }
                }
                self.userProfile.updateToggledGenres()
            }
        }) {
            Text("\(genre)")
                .padding(2)
                .font(.subheadline)
                .allowsTightening(true)
        }
        .buttonStyle(self.didToggle ? GenreSeekingStyle(selectedColor: chosenGenre) : GenreSeekingStyle(selectedColor: unselected))
    }
    
}

struct BottomHalfOfProfile: View {
    // will contain the most recent music tweet and Stash, Friends, and Edit buttons
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
            MusicTweet(MusicTweetViewModel(self.userProfile.TDManager, self.userProfile.TDManager.getRecentlyListenedSongFromUser(self.userProfile.user.id.uuidString)![0]), Alignment.bottomLeading)
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
    @ObservedObject var profileButtons: ProfileButtonsViewModel
    var body: some View {
        Button(action: {
            self.isStashSheet.toggle()
            self.profileButtons.updateStashedSongs()
        }) {
            Text("Stash")
        }.sheet(isPresented: $isStashSheet) {
            NavigationView {
                List {
                    ForEach(self.profileButtons.stashedSongInstances, id: \.self) { songInst in
                        Text("\(songInst.songName)")
                            .foregroundColor(.blue)
                            .minimumScaleFactor(0.5)
                            .allowsTightening(true)
                            .onTapGesture {
                                if let url = URL(string: songInst.songLink) {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                    .onDelete(perform: self.deleteStashedSong)
                }
                .navigationBarTitle("Stashed Songs")
            }
        }
    }
    
    func deleteStashedSong(at offsets: IndexSet) {
        let songInstAtIndex = self.profileButtons.stashedSongInstances[offsets.first!]
        self.profileButtons.stashedSongInstances.remove(atOffsets: offsets)
        self.profileButtons.removeStashedSong(songInstToBeRemoved: songInstAtIndex)
    }
}

struct ProfileFriendsButtonView: View {
    @Binding var isFriendSheet: Bool
    @ObservedObject var profileButtons: ProfileButtonsViewModel
    
    var body: some View {
        Button(action: {
            self.isFriendSheet.toggle()
            self.profileButtons.updateFriends()
        }) {
            Text("Friends")
        }.sheet(isPresented: $isFriendSheet) {
            NavigationView {
                List {
                    ForEach(self.profileButtons.userFriends, id: \.self) { friend in
                        NavigationLink(destination: ProfileView(userProfile: ProfileViewModel(self.profileButtons.userProfile.TDManager, friend))) {
                                Text("\(friend.name)")
                            }
                    }
                }
                .navigationBarTitle("Friends")
            }
        }
    }
}

struct ProfileFollowRequestsButtonView: View {
    @Binding var isFollowerSheet: Bool
    @ObservedObject var profileButtons: ProfileButtonsViewModel
    @State var showAlert = false
    @State var currentRequester: User? = nil       // track the last clicked friend from list for the alert--can't present alerts within the ForEach of the List directly
    
    var body: some View {
        Button(action: {
            self.isFollowerSheet.toggle()
            self.profileButtons.updateReceived()
        }) {
            Text("Follow Requests")
        }.sheet(isPresented: $isFollowerSheet) {
            NavigationView {
                List {
                    ForEach(self.profileButtons.followsRequestedFrom, id: \.self) { requester in
                        Button(action: {
                            self.currentRequester = requester
                            self.showAlert = true
                        }) {
                            Text("\(requester.name)")
                        }
                    }
                    .onDelete(perform: self.deleteFriendRequest)
                    .alert(isPresented: self.$showAlert) {
                        Alert(title: Text("Accept Friend Request \(self.currentRequester!.name)"),
                              message: Text("Do you want to accept? You'll both be able to see each other's profiles"),
                              primaryButton: .default(Text("Yes"), action: {
                                self.showAlert = false
                                
                                self.profileButtons.acceptFriendRequest(requester: self.currentRequester!)
                              }),
                              secondaryButton: .cancel(Text("Never mind"), action: {
                                self.showAlert = false
                              })
                        )
                    }
                }
                .navigationBarTitle("Received Friend Requests")
            }
        }
    }
    
    func deleteFriendRequest(at offsets: IndexSet) {
        let requester = self.profileButtons.followsRequestedFrom[offsets.first!]
        self.profileButtons.followsRequestedFrom.remove(atOffsets: offsets)
        self.profileButtons.removeFriendRequest(requester: requester)
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

