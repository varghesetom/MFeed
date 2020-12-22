
import SwiftUI

class UserAuth: ObservableObject {
  
  @Published var isLoggedIn = false
  
  func login() {
    self.isLoggedIn = true
  }
  
  func logout() {
    self.isLoggedIn = false
  }
}


struct LoginView: View {
    @State var userName: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    @EnvironmentObject var userAuth: UserAuth
    var title: LocalizedStringKey = "MFeed"
    var localUserName: LocalizedStringKey = "Username"
    var localPassword: LocalizedStringKey = "Password"
    var localLogin: LocalizedStringKey = "Login"
    
    var body: some View {
        if !userAuth.isLoggedIn {
            return AnyView(
                VStack {
                    Text(title).font(.title)
                    Spacer(minLength: 10)
                    VStack(alignment: .center) {
                        HStack {
                            Spacer(minLength: 50)
                            TextField(localUserName, text: $userName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Spacer(minLength: 50)
                        }
                        HStack {
                            Spacer(minLength: 50)
                            SecureField(localPassword, text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Spacer(minLength: 50)
                        }
                        Button(action: {
                            self.saveUserName(userName: self.userName)
                            self.userAuth.login()
                        }, label: {
                            Text(localLogin)
                        }).disabled(self.userName.isEmpty)
                    }
                }
            )
        } else {
            return AnyView(ContentView())
        }
    }
    
    func saveUserName(userName: String) {
      UserDefaults.standard.set(userName, forKey: "username")
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
