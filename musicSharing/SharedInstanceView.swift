//
//  SharedInstanceView.swift
//  musicSharing


import SwiftUI

// user form to add a song instance
struct SharedInstanceView: View {
    @State var songName = ""
    @State var songArtist = ""
    @State var songGenre = ""
    @State var songMood = ""
    @State var songLink = ""
    @State var songLength = ""
    let genres = ["Rock", "Country", "Hip-Hop", "Rap", "Classical", "Pop", "Trance"]
    let moods = ["In My Feels", "Chill", "Feel-Good", "Melancholy", "Pump-Up"]
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Add song")) {
                    TextField("Enter song name", text: $songName)
                    TextField("Paste song link here", text: $songLink)
                }
                Section(header: Text("Optional Info")) {
                    Picker("Select genre", selection: $songGenre) {
                        ForEach(genres, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    Picker("Select mood", selection: $songMood) {
                        ForEach(moods, id: \.self) {
                            Text("\($0)")
                        }
                    }
                    TextField("Enter song artist", text: $songArtist)
                    TextField("How long?", text: $songLength).keyboardType(.decimalPad)
                }
            }
            Button(action: {
                self.createSongInstance()
            }) {
               Text("Share")
            }
        }
//        .navigationBarTitle("Share a song")
    }
    
    func createSongInstance() {
        print("creating song instance...")
        // Defensive Programming Checks
        
        let newSong = Song(name: songName, artist: songArtist, genre: songGenre, songLength: Decimal(string: songLength) ?? 0.0)
        
//           TestDataManager.saveSongInstance(songName: "Blue Bayou", instanceOf: newSong, playedBy: <#T##UserEntity#>, artist: <#T##String#>, genre: <#T##String#>, songLength: <#T##Decimal#>)
        print("finished creating song instance")
    }
    
    func isValidSongName(_ name: String) -> Bool {
        if name.count == 0 {
            return false
        }
        return true
    }
}

// Defensive Programming
// 1. Check song name is within a certain range (e.g 0 < name < 120)
// 2. Check if song artist is within a certain range (e.g 0 < name < 120)
// 3. Check if song length is nonsense (e.g. "Enter song length in format: X.Y where X = minutes, Y = seconds" alert )
// 4. Check if inappropriate words are used


struct SharedInstanceView_Previews: PreviewProvider {
    static var previews: some View {
        SharedInstanceView()
    }
}
