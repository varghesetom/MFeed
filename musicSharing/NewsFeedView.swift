
import SwiftUI
import UIKit
import CoreData

struct NewsFeedView: View {
    /*
     NavigationView that sets up tab bar with the ScrollTweets()
     and Profile view
     */
    @Binding var selection: Int
    var body: some View {
        TabView(selection: $selection) {
            ScrollTweets().tabItem { Text("Feed")}.tag(1)
            ProfileView().tabItem{ Text("Profile")}.tag(2)
        }.onAppear(perform: {
            CoreDataManager.emptyDB()
            CoreDataManager.saveFakeData()
        })
    }
}

struct ScrollTweets: View {
    let colors: [Color] = [.red, .green, .blue]
    @FetchRequest(entity: SongInstanceEntity.entity(), sortDescriptors: [NSSortDescriptor(key: "song_name", ascending: true)]) var fetchedSongInstances: FetchedResults<SongInstanceEntity>

    var body: some View {
        let songInstances = fetchedSongInstances.map( {
            SongInstance(instanceEntity: $0)
        })
        return NavigationView {
            ScrollView(.vertical) {
                VStack(spacing: 50) {
                    ForEach(songInstances, id: \.self) {
                        MusicTweet(songInstance: $0)
                    }
                }
            }
            .background(Color.black)
            .navigationBarTitle("OnTheSpot")
        }
        
    }
}


struct MusicTweet: View {
    @State var songInstance: SongInstance
    @State var width = CGFloat(370)
    @State var height = CGFloat(180)
    @State var alignment = Alignment.center
    
    var body: some View {
        let image = UIImage(named: songInstance.instanceOf.image ?? "northern_lights") ?? UIImage(named: "northern_lights")  // if the image in songInstance can't be found in Assets, then provide a default image
        return VStack(alignment: .center, spacing: 0) {
//            Text("Gabagool")
            Text("\(songInstance.playedBy.name)")
                .font(.system(.headline, design: .monospaced))
                .font(.largeTitle)
                .minimumScaleFactor(0.6)
                .allowsTightening(true)
                .frame(width: 370, height: 50, alignment: .center) // red rectangle gets its own frame -- easier than ZStack
                .background(Color.red)
            HStack(alignment: .center, spacing: 15) {
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 80, alignment: .center)
                    .padding(.leading, 20)   // affected by padding with the buttons
                VStack(alignment: .leading) {
                    Text("\(songInstance.instanceOf.name)")
                        .foregroundColor(.black)
                        .underline()
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    Text("\(songInstance.instanceOf.artist ?? "Unknown")")
                        .foregroundColor(.black)
                        .italic()
                        .bold()
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    Text("\(songInstance.instanceOf.genre ?? "Unknown")")
                        .foregroundColor(.black)
                        .fontWeight(.medium)
                        .italic()
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    HStack(spacing: 10) {
                        TweetButton("Stash", songInstance)
                        TweetButton("Convo", songInstance)
                        TweetButton("Like", songInstance)
                    }
                    .padding(.top, 30)
                    .padding(.trailing, 10)
                }.padding(.leading, 30)
            }
            .frame(width: width, height: height, alignment: alignment)  // the orange rectangle will have its own frame to avoid ZStack
            .background(Color.orange)
        }
    }
}

struct TweetButton: View {
    @State var action: String
    @State var songInstance: SongInstance
    
    init(_ action: String, _ songInstance: SongInstance) {
        // initialize State variables so can use them after initialization in Button
        _action = .init(initialValue: action)
        _songInstance = .init(initialValue: songInstance)
    }
    
    var body: some View {
        Button(action: {
            print("\(self.action) clicked")  // add to stash action
            self.buttonFunctionality()
        }) {
            Text("\(action)")
                .font(.caption)
        }
            .buttonStyle(ButtonBackground())
    }
    
    func buttonFunctionality() -> Void {
        switch self.action {
        case "Stash":
            print("Stashed")
            CoreDataManager.userStashesSong(songInstance: self.songInstance.convertToManagedObject())
        case "Convo":
            print("Convoed")
            CoreDataManager.userCommentsOnSong(songInstance: self.songInstance.convertToManagedObject())
        case "Like":
            print("Liked")
            CoreDataManager.userLikesSong(songInstance: self.songInstance.convertToManagedObject())
        default:
            fatalError("Need proper action argument for TweetButton functionality")
        }
    }
}

struct ButtonBackground: ButtonStyle {
    @State private var firstGradientColor = Color.orange
    @State private var secondGradientColor = Color.red
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(5)
            .compositingGroup()
            .opacity(configuration.isPressed ? 0.5 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .scaledToFit()
    }
}


struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView(selection: .constant(1))
    }
}
