
import SwiftUI
import UIKit
import CoreData

struct ScrollTweets: View {

    @FetchRequest(entity: SongInstanceEntity.entity(), sortDescriptors: [NSSortDescriptor(key: "date_listened", ascending: false)]) var fetchedSongInstances: FetchedResults<SongInstanceEntity>
    
    @State var isShareViewShown = false
    var TDManager: TestDataManager
    
    init(_ manager: TestDataManager) {
        self.TDManager = manager
    }
    
    var body: some View {
        let songInstanceEntities = fetchedSongInstances.map( {
            $0
        })
        
        return NavigationView {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)
                ScrollView(.vertical) {
                    VStack(spacing: 50) {
                        ForEach(songInstanceEntities, id: \.self) {
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
        .sheet(isPresented: $isShareViewShown) {
            SharedInstanceView(self.TDManager)
        }
    }
}

struct MusicTweet: View {
    @State var songInstance: SongInstanceEntity
    @State var width = CGFloat(370)
    @State var height = CGFloat(180)
    @State var alignment = Alignment.center
    
    var body: some View {
        let songInst = SongInstance(instanceEntity: songInstance)
        let image = UIImage(named: songInst.instanceOf.image) ?? UIImage(named: "northern_lights")  // if the image in songInstance can't be found in Assets, then provide a default image
        return VStack(alignment: .center, spacing: 0) {
            HStack() {
                Spacer()
                Text("\(songInst.playedBy.name)")
                    .font(.system(.headline, design: .monospaced))
                    .font(.largeTitle)
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .alignmentGuide(.center) { d in d[.leading] }
                Spacer()
                Spacer()
                Text("\(getFormattedDateStampForTweet(songInst.dateListened))")
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
                    Text("\(songInst.instanceOf.name)")
                        .foregroundColor(.black)
                        .underline()
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    Text("\(songInst.instanceOf.artist ?? "Unknown")")
                        .foregroundColor(.black)
                        .italic()
                        .bold()
                        .minimumScaleFactor(0.5)
                        .allowsTightening(true)
                    Text("\(songInst.instanceOf.genre ?? "Unknown")")
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
    var action: String
    var songInstanceEntity: SongInstanceEntity
    var TDManager: TestDataManager
    
    init(_ action: String, _ songInstanceEntity: SongInstanceEntity) {
        self.action = action
        self.songInstanceEntity = songInstanceEntity
        self.TDManager = TestDataManager()
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
            .buttonStyle(TweetButtonBackground())
    }
    
    func buttonFunctionality() -> Void {
        switch self.action {
        case "Stash":
            print("Stashed")
            TDManager.userStashesSong(user: TDManager.fetchMainUser()!, songInstance: songInstanceEntity)
        case "Convo":
            print("Convoed")
            TDManager.userCommentsOnSong(user: TDManager.fetchMainUser()!, songInstance: songInstanceEntity)
        case "Like":
            print("Liked")
            TDManager.userLikesSong(user: TDManager.fetchMainUser()!, songInstance: songInstanceEntity)
        default:
            fatalError("Need proper action argument for TweetButton functionality")
        }
    }
}

struct TweetButtonBackground: ButtonStyle {
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

// helper function for formatting dates
func getFormattedDateStampForTweet(_ date: Date) -> String{
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.dateFormat = "MM/dd @ HH:mm"
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.locale = Locale.current
    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
    let dateTime = dateFormatter.string(from: date)
    print("ORIGINAL: \(date)")
    print("DATE FORMATTER VERSION: \(dateTime)")
    return dateTime
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(selection: .constant(1))
    }
}
