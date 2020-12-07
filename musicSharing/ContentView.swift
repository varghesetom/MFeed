

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
//        AppView(selection: .constant(1))
        Text("")
    }
}
#endif

struct MainUser {
    static var idMainUser = "947be968-e95d-4db4-b975-0e674c934c61"
}

struct ContentView: View {
    // uncomment below to test looking at from a different main user
//    let TDManager = TestDataManager()
//    let user: User
//    let bobID = "93d95053-e625-4e60-a48c-fb04421f0d9f"
    
//    init() {
//        guard TDManager.getUser(bobID) != nil else {
//            print("Couldn't get bobFriend")
//            self.user = User(name: "", user_bio: "", avatar: "")
//            return
//        }
//        self.user = User(userEntity: TDManager.getUser("93d95053-e625-4e60-a48c-fb04421f0d9f")!)
//    }
    @State var selection = 1
    var body: some View {
        AppView(selection: $selection)
//        ScrollTweets(TDManager)
//        ProfileView(TDManager, self.user)
    }
}


struct AppView: View {
    /*
     NavigationView that sets up tab bar with the ScrollTweets()
     and Profile view
     */
    @Binding var selection: Int
    @State var didAppear = false
    @State var alreadyLoaded = 0
    let TDManager = TestDataManager()
    let user: User
    
    init(selection: Binding<Int>) {
        _selection =  selection
        self.user = User(userEntity: TDManager.fetchMainUser()!)
    }
    
    var body: some View {
        TabView(selection: $selection){
            ScrollTweets(self.TDManager).tabItem {
                Image(systemName: "house")
                Text("Feed")
            }.tag(1)
            ProfileView(userProfile: ProfileViewModel(self.TDManager, self.user)).tabItem{
                Image(systemName: "person")
                Text("Profile")
            }.tag(2)
        }.onAppear(
            perform: {
                if self.alreadyLoaded == 0 {
                    _ = self.TDManager.emptyDB()
                    self.TDManager.saveFakeData()
                    self.alreadyLoaded += 1
                }
            }).onAppear() {
                UITabBar.appearance().barTintColor = .black
            }.accentColor(.white)
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
