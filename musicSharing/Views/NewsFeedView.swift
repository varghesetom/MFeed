
import SwiftUI
import UIKit
import CoreData

struct ScrollTweets: View {

    @FetchRequest(entity: SongInstanceEntity.entity(), sortDescriptors: [NSSortDescriptor(key: "date_listened", ascending: false)]) var fetchedSongInstances: FetchedResults<SongInstanceEntity>
    
    @State var isShareViewShown = false
    @State var isSearchViewShown = false
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
                            MusicTweet(MusicTweetViewModel(self.TDManager, $0))
                        }
                    }
                }
                .padding(.top, 1) // prevents scrollview from going under navbar
            }
            .background(Color.black)
            .navigationBarTitle("MusicSharing")
            .navigationBarItems(trailing:
                HStack {
                    Button("Search") {
                        self.isSearchViewShown.toggle()
                    }
                    Button("Share") {
                        self.isShareViewShown.toggle()
                    }
                }
            )
        }
        .sheet(isPresented: $isShareViewShown) {
            SharedInstanceView(self.TDManager)
        }
        .sheet(isPresented: $isSearchViewShown) {
            SearchBarView(self.TDManager)
        }
    }
}

struct MusicTweet: View {
    @State var width = CGFloat(370)
    @State var height = CGFloat(180)
    @State var alignment = Alignment.center
    @State var showProfile = false
    @State var openSongLink = false
    @ObservedObject var mtModel: MusicTweetViewModel
    
    init(_ mtModel: MusicTweetViewModel, _ alignment: Alignment = Alignment.center) {
        self.mtModel = mtModel
        _alignment = .init(initialValue: alignment)        
    }
    
    var body: some View {
        let songInst = SongInstance(instanceEntity: self.mtModel.songInstEnt)
        return VStack(alignment: .center, spacing: 0) {
            HStack() {
                Spacer()
                Button(action: {
                    self.showProfile.toggle()
                }) {
                    Text("\(songInst.playedBy.name)").allowsTightening(true).minimumScaleFactor(0.7)
                }.sheet(isPresented: $showProfile) {
                    if songInst.playedBy.id == User(userEntity: self.mtModel.TDManager.fetchMainUser()!).id {
                        ProfileView(userProfile: ProfileViewModel(self.mtModel.TDManager, User(userEntity: self.mtModel.TDManager.fetchMainUser()!)))
                    } else {
                        ProfileView(userProfile: ProfileViewModel(self.mtModel.TDManager, songInst.playedBy))
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
                if self.mtModel.numLikes > 0 {
                    LikeView(numLikes: self.mtModel.numLikes)
                }
                if songInst.playedBy.id == User(userEntity: self.mtModel.TDManager.fetchMainUser()!).id {
                    DeleteMusicTweet(songInst: songInst).environmentObject(self.mtModel)
                        .padding(.trailing, 10)
                }
            }
            .frame(width: 370, height: 50, alignment: .center)
            .background(Color.red)
            MusicTweetBodyView(width: width, height: height, alignment: alignment).environmentObject(self.mtModel)
            HStack(spacing: 10) {
                Spacer()
                TweetButton(actionName: "Stash", actionFunction: self.mtModel.stashCurrentTweet).environmentObject(self.mtModel)
                Spacer()
                TweetButton(actionName: "Convo").environmentObject(self.mtModel)
                Spacer()
                TweetButton(actionName: "Like", actionFunction: self.mtModel.addLikeAndUpdate).environmentObject(self.mtModel)
                Spacer()
            }
            .frame(width: width, height: 70, alignment: alignment)
            .background(Color.orange)
        }.onAppear {
            self.mtModel.getLikes()
        }
    }
}

struct MusicTweetBodyView: View {
    @State var width = CGFloat(370)
    @State var height = CGFloat(180)
    @State var alignment = Alignment.center
    @EnvironmentObject var mtModel: MusicTweetViewModel
    
    var body: some View {
        let songInst = SongInstance(instanceEntity: self.mtModel.songInstEnt)
        return HStack(alignment: .center, spacing: 15) {
            Spacer()
            Image("\(songInst.playedBy.avatar!)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 100, alignment: .center)
                .padding(.leading, 20)   // affected by padding with the buttons
            Spacer()
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
            .frame(width: 120, height: 100, alignment: .center)
            Spacer()
        }
        .frame(width: width, height: height, alignment: alignment)  // the orange rectangle will have its own frame to avoid ZStack
        .background(Color.orange)
    }
}

struct TweetButton: View {
    var actionName: String
    var actionFunction: (() -> Void)? = nil
    @EnvironmentObject var mtModel: MusicTweetViewModel
    @State var showConvo = false
    
    var body: some View {
        Button(action: {
            print("\(self.actionName) clicked")  // add to stash action
            if self.actionName == "Convo" {
                self.showConvo.toggle()
            }
            if let function = self.actionFunction {
                function()
                print("function: \(String(describing: function))")
            }
        }) {
            Text("\(actionName)")
                .font(.caption)
                .minimumScaleFactor(0.7)
                .allowsTightening(true)
        }.buttonStyle(TweetButtonBackground())
         .sheet(isPresented: $showConvo) {
            ConvoView(self.mtModel.TDManager, self.mtModel.songInstEnt, dismiss: self.$showConvo).environmentObject(self.mtModel)
        }
    }
}

struct DeleteMusicTweet: View {
    @State var songInst: SongInstance
    @State var promptDelete = false
    @EnvironmentObject var mtModel: MusicTweetViewModel
    var body: some View {
        Button(action: {
            self.promptDelete.toggle()
        }) {
            Image(systemName: "trash")
        }.alert(isPresented: $promptDelete) {
            Alert(title: Text("Delete"), message: Text("Are you sure you want to delete your song?"), primaryButton: .cancel(), secondaryButton: .destructive(Text("Delete"), action: {
                self.mtModel.deleteSongInstance()
            }))
        }.padding(.leading)
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
