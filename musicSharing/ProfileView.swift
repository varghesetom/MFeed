//
//  ProfileView.swift
//  schoolProject
//
//  Created by Varghese Thomas on 19/11/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import SwiftUI

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
    @FetchRequest(fetchRequest: CoreDataManager.getRecentlyListenedSongFromMainUser) var mostRecentSong: FetchedResults<SongInstanceEntity>
    
    var body: some View {
        guard mostRecentSong.count > 0 else {
            return AnyView(Text("No Song Listens").foregroundColor(.white))
        }
        let songInstance = SongInstance(instanceEntity: mostRecentSong.first!)
        return AnyView(
            VStack {
                Text("Recent Song")
                    .foregroundColor(.white)
                    .font(.headline)
                    .underline()
                MusicTweet(songInstance: songInstance, alignment: Alignment.bottomLeading).scaleEffect(0.85)
                HStack {
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Text("Stash")
                    }
                    Spacer()
                    Button(action: {
                        
                    }) {
                        Text("Friends")
                    }
                    Spacer()
                    Button(action: {
                    
                    }) {
                        Text("Follow Requests")
                    }
                    Spacer()
                }
            }
        )
    }
}

struct UserBox: View {
    @State private var user = User(userEntity: CoreDataManager.mainUser)
    
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
