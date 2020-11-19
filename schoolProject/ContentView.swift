

import SwiftUI
import CoreData

/* TODOS
    1. Implement scroll View that has each Tweet populated with User's songs that they have listened to
    2. Create Stash Button Functionality -> add a song shown on Feed to User's stash
    3. Create Like Button Functionality -- and display Likes on tweet
    4. Create Convo Button Functionality -> collect all the comments and display them in order
    5. Add Date as a variable in SongEntity so can use a sortDescriptor to have them sorted by date when user listened to song
    6. Restructure the CoreData Model to have an explicit SongInstance vs CoreSong. Currently every song instance that appears is treated uniquely which means a song can appear repeatedly with the same name, artist, and genre but will be treated uniquely because it will have its own UUID. This means the Stash button would be able to add both instances even though they are the same song. Either implement a check for duplicates with the Stash functionality or add another entity
    7. UserProfile needs to have a working view
            -> differentiate between personal and others. Only the personal view can have an editable stash. All other stashes on other people's profiles will be read-only.
    8. Add systemImages for the TabItems
    9. Include "default" image if song doesn't have an image
    10. Include "default" image for user avatar if not set
    11. Add Search bar in Feed view -> would require using a UIView, not built-in with SwiftUI
    12. Implement a timer functionality for dummy project where a timer will go off to signify a new song instance to be included in the Feed to be interacted with
    
 */

#if DEBUG
struct Start: PreviewProvider {
    
    static var previews: some View {
//        MusicTweet()
//        NewsFeed(selection: .constant(1))
        Text("")
    }
}
#endif

struct ContentView: View {
    @State private var selection = 1
    var body: some View {
        
//        TestSpotifyView()
//        MusicTweet()
        NewsFeedView(selection: $selection)
//        CoreDataView()
    }
}


struct CoreDataView: View {
    
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
                    CoreDataManager.emptyDB()
                    CoreDataManager.saveFakeData()
                    guard let bob = CoreDataManager.getUserWithName("Bob") else {
                        print("No bob was found")
                        return
                    }
                    guard let bobSongInstanceEntities = CoreDataManager.getSongInstancesFromUser(bob) else {
                        print("No bob songs were found")
                        return
                    }
                    print("Bob listens to the following songs:")
                    bobSongInstanceEntities.forEach({
                        let songInstance = SongInstance(instanceEntity: $0)
                        print("\(songInstance.instanceOf.name)")
                        })
                }) {
                    Text("Test Delete/Create/Read")
                }
                
                Button(action: {
                    guard !self.fetchedBobEntity.isEmpty else { return }
                    let bobEntity = self.fetchedBobEntity.first!
                    if let songInstanceEntities = CoreDataManager.getSongInstancesFromUser(bobEntity) {
                        print("Got first song from User Bob")
                        let first = songInstanceEntities.first!
                        CoreDataManager.userLikesSong(user: bobEntity, songInstance: first)
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
    

