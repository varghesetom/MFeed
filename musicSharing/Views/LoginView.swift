
import SwiftUI
import Foundation
import AuthenticationServices

struct LoginView: View {
    @State var userName: String = UserDefaults.standard.string(forKey: "username") ?? ""
    @State var password: String = UserDefaults.standard.string(forKey: "password") ?? ""
    @EnvironmentObject var userAuth: UserAuth
//    @ObservedObject var delegateHelper: SIWADelegateHelper
    
    var title: LocalizedStringKey = "MFeed"
    var localUserName: LocalizedStringKey = "Username"
    var localPassword: LocalizedStringKey = "Password"
    var localLogin: LocalizedStringKey = "Login"
    
    // testing search bar
    @State var query = ""
    
    var body: some View {
//        SignInWithApple()
//          .frame(width: 210, height: 45)
//          .onTapGesture(perform: handleAuthorizationAppleIDButtonPress)
//          .onAppear(perform: { self.performExistingAccountSetupFlows() })
        VStack {
            if self.userAuth.isLoggedIn {
                ContentView()
            }
            if !self.userAuth.isLoggedIn {
                VStack {
                    SearchBar(text: $query)
                        .padding()
                    Button(action: {
                        self.userAuth.login()
                    }) {
                        Text("Click")
                    }
                }
            }            
        }
    }
//    /// - Tag: perform_appleid_request
//    func handleAuthorizationAppleIDButtonPress() {
//
//      let request = ASAuthorizationAppleIDProvider().createRequest()
//      request.requestedScopes = [.fullName]
//
//      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//      authorizationController.delegate = delegateHelper
//      authorizationController.performRequests()
//    }
//
//    // - Tag: perform_appleid_password_request
//    /// Prompts the user if an existing iCloud Keychain credential or Apple ID credential is found.
//    func performExistingAccountSetupFlows() {
//      // Prepare requests for both Apple ID and password providers.
//      let requests = [ASAuthorizationAppleIDProvider().createRequest(),
//                      ASAuthorizationPasswordProvider().createRequest()]
//
//      // Create an authorization controller with the given requests.
//      let authorizationController = ASAuthorizationController(authorizationRequests: requests)
//      authorizationController.delegate = delegateHelper
//      authorizationController.performRequests()
//    }
}
//
class UserAuth: ObservableObject {

  @Published var isLoggedIn = false

  func login() {
    self.isLoggedIn = true
  }

  func logout() {
    self.isLoggedIn = false
  }
}
//
//struct SignInWithApple: UIViewRepresentable {
//
//  func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
//    return ASAuthorizationAppleIDButton()
//  }
//
//  func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
//  }
//}
//
//class SIWADelegateHelper: NSObject, ASAuthorizationControllerDelegate, ObservableObject {
//
//  public var fullName: String = ""
//  public var emailToUse: String = ""
//  @Published public var isSignedIn: Bool = false
//
//
//  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//      switch authorization.credential {
//        case let appleIDCredential as ASAuthorizationAppleIDCredential:
//
//          // Create an account in your system.
//          let userIdentifier = appleIDCredential.user
//          let fullName = appleIDCredential.fullName
//
//          // For the purpose of this demo app, store the `userIdentifier` in the keychain.
//          self.saveUserInKeychain(userIdentifier)
//
//          // For the purpose of this demo app, save the name and email for eventual display in the app
//          if let givenName = fullName?.givenName {
//            self.fullName = givenName
//          }
//          print("using apple id")
//          self.isSignedIn = true
//
//      case let passwordCredential as ASPasswordCredential:
//
//          // Sign in using an existing iCloud Keychain credential.
////          let username = passwordCredential.user
////          let password = passwordCredential.password
//          print("using password")
//
//      default:
//          break
//      }
//  }
//
//  private func saveUserInKeychain(_ userIdentifier: String) {
//      do {
//          try KeychainItem(service: "edu.jhu.ep.steele.josh.EPGradeBook.SignInWithApple.Details", account: "userIdentifier").saveItem(userIdentifier)
//      } catch {
//          print("Unable to save userIdentifier to keychain.")
//      }
//  }
//
//  /// - Tag: did_complete_error
//  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//      print("error \(error)")
//  }
//}
//
//
//
//struct LoginView_Previews: PreviewProvider {
//    static var previews: some View {
////        LoginView()
//        Text("")
//    }
//}
