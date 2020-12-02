
import SwiftUI
import UIKit
import CoreData

struct ScrollTweets: View {

    @FetchRequest(entity: SongInstanceEntity.entity(), sortDescriptors: [NSSortDescriptor(key: "song_name", ascending: true)]) var fetchedSongInstances: FetchedResults<SongInstanceEntity>
    @State var isShareViewShown = false
    
    var body: some View {
        let songInstances = fetchedSongInstances.map( {
            SongInstance(instanceEntity: $0)
        })
        return NavigationView {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)
                ScrollView(.vertical) {
                    VStack(spacing: 50) {
                        ForEach(songInstances, id: \.self) {
                            MusicTweet(songInstance: $0)
                        }
                    }
                }
                .padding(.top, 1) // prevents scrollview from going under navbar
            }
            .background(Color.black)
            .navigationBarTitle("MusicSharing")
            .navigationBarItems(trailing: Button("Share") {
                self.isShareViewShown.toggle()
            })
        }
    .
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
            HStack() {
                Spacer()
                Text("\(songInstance.playedBy.name)")
                    .font(.system(.headline, design: .monospaced))
                    .font(.largeTitle)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .alignmentGuide(.center) { d in d[.leading] }
                Spacer()
                Spacer()
                Text("\(getFormattedDateStampForTweet(songInstance.dateListened))")
                    .font(.system(.subheadline, design: .monospaced))
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .alignmentGuide(.center) { d in d[.trailing]}
                Spacer()
            }
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
                }.padding(.leading, 30)
            }
            .frame(width: width, height: height, alignment: alignment)  // the orange rectangle will have its own frame to avoid ZStack
            .background(Color.orange)
            HStack(spacing: 10) {
                Spacer()
                TweetButton("Stash", songInstance)
                Spacer()
                TweetButton("Convo", songInstance)
                Spacer()
                TweetButton("Like", songInstance)
                Spacer()
            }
//            .padding(.top, 30)
//            .padding(.trailing, 10)
            .frame(width: width, height: 70, alignment: alignment)
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
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
        }
            .buttonStyle(ButtonBackground())
    }
    
    func buttonFunctionality() -> Void {
        // TODO - fix bug where duplicate tweets appear after clicking on a random user's stash button
        switch self.action {
        case "Stash":
            print("Stashed")
            CoreRelationshipDataManager.userStashesSong(songInstance: self.songInstance.convertToManagedObject())
        case "Convo":
            print("Convoed")
            CoreRelationshipDataManager.userCommentsOnSong(songInstance: self.songInstance.convertToManagedObject())
        case "Like":
            print("Liked")
            CoreRelationshipDataManager.userLikesSong(songInstance: self.songInstance.convertToManagedObject())
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


//func getDateFormatter() -> DateFormatter{
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .short
//    return formatter
//}

// helper function for formatting dates
func getFormattedDateStampForTweet(_ date: Date) -> String{
    let components = Calendar.current.dateComponents([.month, .day,.hour, .minute], from: date)
    let month = components.month ?? 1
    let day = components.day ?? 1
    let hour = components.hour ?? 0
    let minute = components.minute ?? 0
//    print("ORIGINAL: \(date)\n(FORMATTED: \(month)/\(day)@\(hour):\(minute)")
    return "\(month)/\(day)@\(hour):\(minute)"
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(selection: .constant(1))
    }
}
