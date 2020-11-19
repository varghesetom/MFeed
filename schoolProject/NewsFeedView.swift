
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
            Text("Profile").tabItem{ Text("Profile")}.tag(2)
        }.onAppear(perform: {
            CoreDataManager.emptyDB()
            CoreDataManager.saveFakeData()
        })
        
    }
}

struct ScrollTweets: View {
    let colors: [Color] = [.red, .green, .blue]
    @FetchRequest(entity: SongInstanceEntity.entity(), sortDescriptors: [NSSortDescriptor(key: "instance_id", ascending: true)]) var fetchedSongInstances: FetchedResults<SongInstanceEntity>

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
            .background(Color.gray)
            .navigationBarTitle("OnTheSpot")
        }
        
    }
}

/*
 Don't need Zstack with rectangle (orange) and Vstack because can use frame modifiers and then apply the color modifier afterwards.
 
 Hard to work with Zstack
 
 create separate class with static methods to work with the CoreData (e.g. addToStash, addLike)
 */

struct MusicTweet: View {
    @State var songInstance: SongInstance
    
    var body: some View {
        let image = UIImage(named: songInstance.instanceOf.image ?? "northern_lights") ?? UIImage(named: "northern_lights")  // if the image in songInstance can't be found in Assets, then provide a default image
        return VStack(alignment: .center, spacing: 0) {
//            Text("Gabagool")
            Text("\(songInstance.playedBy.name)")
                .font(.system(.headline, design: .monospaced))
                .font(.largeTitle)
                .frame(width: 370, height: 50, alignment: .center) // red rectangle gets its own frame -- easier than ZStack
                .background(Color.red)
            HStack(alignment: .center, spacing: 15) {
//                Image("northern_lights")
                Image(uiImage: image!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 80, alignment: .center)
                    .padding(.leading, 20)   // is affected by the padding as well with the buttons
                VStack(alignment: .leading) {
//                    Text("Adagio for Strings").underline()
                    Text("\(songInstance.instanceOf.name)")
                        .underline()
//                    Text("Tiesto")
                    Text("\(songInstance.instanceOf.artist ?? "Unknown")")
                        .italic()
                        .bold()
                    Text("\(songInstance.instanceOf.genre ?? "Unknown")")
//                    Text("Trance")
                        .fontWeight(.medium)
                        .italic()
                    HStack(spacing: 10) {
                        Button(action: {
                            print("Stash clicked")  // add to stash action
                        }) {
                            Text("Stash")
                        }
                            .buttonStyle(ButtonBackground())
                        Button(action: {
                            print("Convo clicked")  // open Conversation stored so far
                        }) {
                            Text("Convo")
                        }
                            .buttonStyle(ButtonBackground())
                        Button(action: {
                            print("Like clicked")
                        }) {
                            Text("Like")       // "like" the musical share/tweet
                        }
                            .buttonStyle(ButtonBackground())
                    }
                    .padding(.top, 30)
                    .padding(.trailing, 10)
                }.padding(.leading, 30)
            }
            .frame(width: 370, height: 180, alignment: .center)  // the orange rectangle will have its own frame to avoid ZStack
            .background(Color.orange)
        }
    }
}

struct ButtonBackground: ButtonStyle {
    @State private var firstGradientColor = Color("DarkGreen")
    @State private var secondGradientColor = Color("LightGreen")
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(10)
            .foregroundColor(.white)
            .background(Color.red)
            .cornerRadius(5)
            .scaledToFit()
    }
}


struct NewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        NewsFeedView(selection: .constant(1))
    }
}
