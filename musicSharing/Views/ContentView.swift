

import SwiftUI
import CoreData



// AVATAR IMAGES SOURCED BELOW
// women head avatars -> "<a href='https://www.freepik.com/vectors/woman'>Woman vector created by ddraw - www.freepik.com</a>"
// men head avatars -> "<a href='https://www.freepik.com/vectors/fashion'>Fashion vector created by ddraw - www.freepik.com</a>"
struct MainUser {
    static var idMainUser = "947be968-e95d-4db4-b975-0e674c934c61"
}

struct ContentView: View {
    @State var selection = 1
    @Environment(\.managedObjectContext) var context
    var body: some View {
        AppView(selection: $selection)
    }
}


struct AppView: View {
    /* Tabbed Item View 
     */
    @Binding var selection: Int
    @State var didAppear = false
    @State var alreadyLoaded = 0
    let TDManager = TestDataManager()
    let user: User
    
    init(selection: Binding<Int>) {
//        _ = self.TDManager.emptyDB()
//        self.TDManager.saveFakeData()
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
        }.onAppear() {
                UITabBar.appearance().barTintColor = .black
            }.accentColor(.white)
    }
}
    
#if DEBUG
struct Start: PreviewProvider {
    
    static var previews: some View {
        Text("")
    }
}
#endif
