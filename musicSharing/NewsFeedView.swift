
import SwiftUI
import UIKit
import CoreData

struct ScrollTweets: View {

    @FetchRequest(entity: SongInstanceEntity.entity(), sortDescriptors: [NSSortDescriptor(key: "date_listened", ascending: false)]) var fetchedSongInstances: FetchedResults<SongInstanceEntity>
    
    @State var isShareViewShown = false
    private var TDManager: TestDataManager
    
    init(_ manager: TestDataManager) {
        self.TDManager = manager
    }
    
    var body: some View {
        let songInstanceEntities = fetchedSongInstances.map( {
            $0
        }).filter { $0.instance_id != nil}
        
        return NavigationView {
            ZStack {
                Color.green.edgesIgnoringSafeArea(.all)
                ScrollView(.vertical) {
                    VStack(spacing: 50) {
                        ForEach(songInstanceEntities, id: \.self) {
                            MusicTweet(self.TDManager, songInstEnt: $0).environmentObject(LikeViewModel(self.TDManager, $0))
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
    @State var width = CGFloat(370)
    @State var height = CGFloat(180)
    @State var alignment = Alignment.center
    @State var showProfile = false
    @State var openSongLink = false
    @EnvironmentObject var lvModel: LikeViewModel
    var songInstEnt: SongInstanceEntity
    var TDManager: TestDataManager
    
    init(_ manager: TestDataManager, songInstEnt: SongInstanceEntity, _ alignment: Alignment = Alignment.center) {
        self.TDManager = manager
        self.songInstEnt = songInstEnt
        _alignment = .init(initialValue: alignment)
        
    }
    
    var body: some View {
        let songInst = SongInstance(instanceEntity: songInstEnt)
        return VStack(alignment: .center, spacing: 0) {
            HStack() {
                Spacer()
                Button(action: {
                    self.showProfile.toggle()
                }) {
                    Text("\(songInst.playedBy.name)").allowsTightening(true).minimumScaleFactor(0.7)
                }.sheet(isPresented: $showProfile) {
                    if songInst.playedBy.id == User(userEntity: self.TDManager.fetchMainUser()!).id {
                        ProfileView(userProfile: ProfileViewModel(self.TDManager, User(userEntity: self.TDManager.fetchMainUser()!)))
                    } else {
                        ProfileView(userProfile: ProfileViewModel(self.TDManager, songInst.playedBy))
                    }
                }
                Spacer()
                Text("\(getFormattedDateStampForTweet(songInst.dateListened))")
                    .font(.system(.subheadline, design: .monospaced))
                    .minimumScaleFactor(0.6)
                    .allowsTightening(true)
                    .alignmentGuide(.center) { d in d[.trailing]}
                Spacer()
                Spacer()
                if self.lvModel.numLikes > 0 {
                    LikeView(numLikes: self.lvModel.numLikes)
                }
            }
            .frame(width: 370, height: 50, alignment: .center) // red rectangle gets its own frame -- easier than ZStack
            .background(Color.red)
            HStack(alignment: .center, spacing: 15) {
                Image("\(songInst.playedBy.avatar!)")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 80, alignment: .center)
                    .padding(.leading, 20)   // affected by padding with the buttons
                VStack(alignment: .leading) {
                    Button(action: {
                        if let url = URL(string: songInst.songLink) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("\(songInst.instanceOf.name)")
                            .foregroundColor(.blue)
                            .italic()
                            .bold()
                            .minimumScaleFactor(0.5)
                            .allowsTightening(true)
                    }
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
                TweetButton(self.TDManager, "Stash", songInstEnt).environmentObject(self.lvModel)
                Spacer()
                TweetButton(self.TDManager, "Convo", songInstEnt).environmentObject(self.lvModel)
                Spacer()
                TweetButton(self.TDManager, "Like", songInstEnt).environmentObject(self.lvModel)
                Spacer()
            }
            .frame(width: width, height: 70, alignment: alignment)
            .background(Color.orange)
        }.onAppear {
            self.lvModel.getLikes()
        }
    }
}

struct TweetButton: View {
    var action: String
    var songInstanceEntity: SongInstanceEntity
    var TDManager: TestDataManager
    @State var showConvo = false
    @EnvironmentObject var lvModel: LikeViewModel
    
    init(_ manager: TestDataManager, _ action: String, _ songInstanceEntity: SongInstanceEntity) {
        self.TDManager = manager
        self.action = action
        self.songInstanceEntity = songInstanceEntity
    }
    
    var body: some View {
        Button(action: {
            print("\(self.action) clicked")  // add to stash action
            if self.action == "Convo" {
                self.showConvo.toggle()
            }
            self.buttonFunctionality()
        }) {
            Text("\(action)")
                .font(.caption)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
        }.buttonStyle(TweetButtonBackground())
         .sheet(isPresented: $showConvo) {
            ConvoView(manager: self.TDManager, songInstEnt: self.songInstanceEntity, dismiss: self.$showConvo).environmentObject(self.lvModel)
        }
    }
    
    func buttonFunctionality() -> Void {
        switch self.action {
        case "Stash":
            print("Stashed")
            self.TDManager.userStashesSong(user: self.TDManager.fetchMainUser()!, songInstance: songInstanceEntity)
        case "Convo":
            print("Convoed")
        case "Like":
            print("Before adding like relationship: \(self.lvModel.numLikes)")
            self.TDManager.userLikesSong(user: self.TDManager.fetchMainUser()!, songInstance: songInstanceEntity)
            self.lvModel.getLikes()
            print("Current # of likes: \(self.lvModel.numLikes)")
        default:
            fatalError("Need proper action argument for TweetButton functionality")
        }
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
    return dateFormatter.string(from: date)
}

struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        AppView(selection: .constant(1))
    }
}
