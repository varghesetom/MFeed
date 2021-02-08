//
//  SharedInstanceView.swift
//  musicSharing

// Defensive Programming
// 1. Check song name is within a certain range (e.g 0 < name < 120)
// 2. Check if song artist is within a certain range (e.g 0 < name < 120)
// 3. Check if song length is nonsense (e.g. "Enter song length in format: X.Y where X = minutes, Y = seconds" alert )
// 4. Check if inappropriate words are used



import SwiftUI

enum ActiveAlert {
    case missingName
    case missingLink
    case missingBoth
}

// user form to add a song instance
struct SharedInstanceView: View {
    @State var songName = ""
    @State var songArtist = ""
    @State var songGenre = ""
    @State var songMood = ""
    @State var songLink = ""
    @State var songLength = ""
    @State var showAlert = false
    @State var alertCase = ActiveAlert.missingName
    let genres = ["Rock", "Country", "Hip-Hop", "Rap", "Classical", "Pop", "Trance"]
    let moods = ["In My Feels", "Chill", "Feel-Good", "Melancholy", "Pump-Up"]
    var TDManager: TestDataManager
    
    init(_ manager: TestDataManager) {
        self.TDManager = manager
    }
    
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
                Section {
                    Button(action: {
                        self.createSongInstance()
                    }) {
                       Text("Share")
                    }
                }
            }.navigationBarTitle("Share a song")
        }.alert(isPresented: $showAlert) {
            switch alertCase {
            case .missingBoth:
                return Alert(title: Text("Invalid Input"), message: Text("Need to provide both song name and song link!"), dismissButton: .default(Text("Continue")))
            case .missingName:
                return Alert(title: Text("Invalid Name"), message: Text("Need to provide song name!"), dismissButton: .default(Text("Continue")))
            case .missingLink:
                return Alert(title: Text("Invalid Link"), message: Text("Need to provide song link!"), dismissButton: .default(Text("Continue")))
            }
        }
    }
    
    func createSongInstance() {
        // check if required info is inputted and correct. Then create a SongInstance entity as well as the SongEntity if it's not already been created
        print("creating song instance...")
        if self.didProvideCorrectRequiredInfo(songName: songName, songLink: songLink) {
            if !self.checkIfSongAlreadyExists(songName) {
                _ = self.addSongAndSongInstance(songName, songLink)
            } else {
                let fetchedSong = Song(songEntity: TDManager.getSong(songName)!)
                let fetchedUser = User(userEntity: TDManager.fetchMainUser()!)
                _ = self.addOnlySongInstanceIfSongExists(fetchedSong, fetchedUser)
            }
            print("finished creating song instance")
        }
    }
    
    func didProvideCorrectRequiredInfo(songName: String, songLink: String) -> Bool {
        if !(self.isValidSongName(songName)) && !(self.isValidSongLink(songLink)) {
            showAlert = true
            alertCase = .missingBoth
            return false
        }
        else if !self.isValidSongName(songName) {
            showAlert = true
            alertCase = .missingName
            return false
        }
        else if !self.isValidSongLink(songLink) {
            showAlert = true
            alertCase = .missingLink
            return false
        }
        return true
    }
    
    func isValidSongName(_ name: String) -> Bool {
        return name.count > 0 ? true : false
    }
    
    func isValidSongLink(_ link: String) -> Bool {
        return link.count > 0 ? true : false
    }
    
    func checkIfSongAlreadyExists(_ name: String) -> Bool {
        let lower = name.lowercased()
        return TDManager.checkIfSongExists(lower) || TDManager.checkIfSongExists(name) ? true : false
    }
    
    func addSongAndSongInstance(_ songName: String, _ songLink: String) -> SongInstanceEntity? {
        let song: Song = Song(name: "", songLength: 0.0)
        let songInstance: SongInstance = SongInstance(songName: "", songLink: songLink, dateListened: Date(), instanceOf: song, playedBy: User(userEntity: self.TDManager.fetchMainUser()!))
        _ = TDManager.addSongEntity(song: song)
        return TDManager.addSongInstanceEntity(songInstance: songInstance)
    }
    
    func addOnlySongInstanceIfSongExists(_ song: Song, _ user: User) -> SongInstanceEntity? {
        return TDManager.addSongInstanceEntity(songInstance: SongInstance(songName: song.name, songLink: songLink, dateListened: Date(), instanceOf: song, playedBy: user))
    }
    
}



