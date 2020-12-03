

import SwiftUI
import CoreData

/* TODOS
    3. Create Like Button Functionality -- and display Likes on tweet
    4. Create Convo Button Functionality -> collect all the comments and display them in order
    5. Add Date as a variable in SongEntity so can use a sortDescriptor to have them sorted by date when user listened to song
            - This also means fixing the FetchRequest for getting the most recent song for user.
    7. UserProfile needs to have a working view
            -> differentiate between personal and others. Only the personal view can have an editable stash. All other stashes on other people's profiles will be read-only.
    9. Include "default" image if song doesn't have an image
    10. Include "default" image for user avatar if not set
    11. Add Search bar in Feed view -> would require using a UIView, not built-in with SwiftUI
    12. Implement a timer functionality for dummy project where a timer will go off to signify a new song instance to be included in the Feed to be interacted with
    
 */

#if DEBUG
struct Start: PreviewProvider {
    
    static var previews: some View {
//        MusicTweet()
        AppView(selection: .constant(1))
//        Text("")
    }
}
#endif

struct ContentView: View {
    
    @State private var selection = 1
    
    var body: some View {
        
//        TestSpotifyView()
//        MusicTweet()
//        ProfileView()
//        CoreDataExampleView()
        AppView(selection: $selection)  // set separately so can test whole view when building. If need to tinker solely with other views, can uncomment and isolate above to reduce build time
//        SharedInstanceView()
    }
}

func getCoreDataDBPath() {
    let path = FileManager
        .default
        .urls(for: .applicationSupportDirectory, in: .userDomainMask)
        .last?
        .absoluteString
        .replacingOccurrences(of: "file://", with: "")
        .removingPercentEncoding

    print("Core Data DB Path :: \(path ?? "Not found")")
}

struct AppView: View {
    /*
     NavigationView that sets up tab bar with the ScrollTweets()
     and Profile view
     */
    @Binding var selection: Int
    var body: some View {
        TabView(selection: $selection) {
            ScrollTweets().tabItem {
                Image(systemName: "house")
                Text("Feed")
            }.tag(1)
            ProfileView().tabItem{
                Image(systemName: "person")
                Text("Profile")
            }.tag(2)
        }.onAppear(
            perform: {
                TestDataManager.emptyDB()
                TestDataManager.saveFakeData()
        })
        .onAppear() {
                UITabBar.appearance().barTintColor = .black
        }
        .accentColor(.white)
    }
}


// below is only used for testing purposes to gather data 
struct CoreDataExampleView: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext
    @FetchRequest(entity: UserEntity.entity(), sortDescriptors: [NSSortDescriptor(key: "name", ascending: true)],
                  predicate: NSPredicate(format: "name == %@", "Bob")) var fetchedBobEntity: FetchedResults<UserEntity>
      @FetchRequest(entity: SongInstanceEntity.entity(),
                    sortDescriptors: [NSSortDescriptor(key: "song_name", ascending: true)]) var fetchedSongs: FetchedResults<SongInstanceEntity>

    var body: some View {

        let songInstances = fetchedSongs.map( {
            SongInstance(instanceEntity: $0)
        })
       
        return VStack {
            VStack {
                Button(action: {
                    TestDataManager.emptyDB()
                    TestDataManager.saveFakeData()
                    guard let bob = CoreDataRetrievalManager.getUserWithName("Bob") else {
                        print("No bob was found")
                        return
                    }
                    guard let bobSongInstanceEntities = CoreDataRetrievalManager.getSongInstancesFromUser(bob) else {
                        print("No bob songs were found")
                        return
                    }
                    print("Bob listens to the following songs:")
                    bobSongInstanceEntities.forEach({
                        print("\($0.instanceOf.name)")
                        })
                }) {
                    Text("Test Delete/Create/Read")
                }
                
                Button(action: {
                    guard !self.fetchedBobEntity.isEmpty else { return }
                    let bobEntity = self.fetchedBobEntity.first!
                    if let songInstanceEntities = CoreDataRetrievalManager.getSongInstancesFromUser(bobEntity) {
                        print("Got first song from User Bob")
                        let first = songInstanceEntities.first!
                        CoreRelationshipDataManager.userLikesSong(user: bobEntity, songInstance: first.convertToManagedObject())
                    }
                }) {
                    Text("Add Like")
                }
            }
            
            ForEach(songInstances, id: \.self) { instance in
                Group {
                    Text("Song: \(instance.instanceOf.name)")
                    ForEach(instance.likers, id: \.self) { liker in
                        Text("Liker: \(liker.name)")
                    }
                }
            }
        }
    }
}
    

// HACK with SWIFT example of orienting views
struct ExampleOrientationView: View {
    
    @State private var layoutVertically = false
    
    var body: some View {
        Group {
            if layoutVertically {
                VStack {
                    Group {
                        Text("Name: Paul")
                        Text("Country: England")
                        Text("Pets: Luna, Arya, and Toby")
                    }
                }
            } else {
                HStack {
                    Group {
                        Text("Name: Paul")
                        Text("Country: England")
                        Text("Pets: Luna, Arya, and Toby")
                    }
                }
            }
        }.onTapGesture {
            self.layoutVertically.toggle()
        }
    }
}
