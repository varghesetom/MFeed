

/*
 Nothing here will pertain until Spotify API can properly work with project. Until then, fake data will be used as a substitute and for demo purposes 
 
 */



//
//import SwiftUI
//import UIKit
//import Combine
//
//struct Constants {
//    static let SpotifyClientID = ""
//    static let SpotifyRedirectURL = URL(string: "spotify-ios-quick-start://spotify-login-callback")!
////    static let SpotifySessionKey = "spotifySessionKey"
//}
//
//struct TestSpotifyView: View {
//    @ObservedObject var spotModel = Spot()
//    @State private var songName = ""
//
//    var body: some View {
//        Group {
//            Button("Tap Me") {
//                self.spotModel.didTapConnect()  // this example utilizes the Github https://github.com/spotify/ios-sdk/blob/master/DemoProjects/SPTLoginSampleAppSwift/SPTLoginSampleAppSwift/ViewController.swift
////                self.spotModel.connect()  // unsure whether this would work -- this utilizes the example in the Quick Start homepage https://developer.spotify.com/documentation/ios/quick-start/
//
//            }
//            Text(self.spotModel.trackLabel)
//        }
//    }
//}
//
//class Spot: NSObject, ObservableObject, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {
//
//    @Published var imageView = UIImageView()
//    @Published var playURI = ""
//    @Published var trackLabel = ""
//    private var SpotifyClientID = Constants.SpotifyClientID
//    private var SpotifyRedirectURL = Constants.SpotifyRedirectURL
//    private var lastPlayerState: SPTAppRemotePlayerState?
//    private var accessToken = ""
//
//
//    lazy var configuration: SPTConfiguration = {
//       let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURL)
//       // Set the playURI to a non-nil value so that Spotify plays music after authenticating and App Remote can connect
//       // otherwise another app switch will be required
//       configuration.playURI = ""
//
//       // Set these url's to your backend which contains the secret to exchange for an access token
//       // You can use the provided ruby script spotify_token_swap.rb for testing purposes
//       configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
//       configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
//       return configuration
//    }()
//
//    lazy var sessionManager: SPTSessionManager = {
//        let manager = SPTSessionManager(configuration: configuration, delegate: self)
//        return manager
//    }()
//
//    lazy var appRemote: SPTAppRemote = {
//        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
//        appRemote.delegate = self
//        return appRemote
//    }()
//
//    @objc func didTapConnect() {
//        /*
//         Scopes let you specify exactly what types of data your application wants to
//         access, and the set of scopes you pass in your call determines what access
//         permissions the user is asked to grant.
//         */
//        let scope: SPTScope = [.appRemoteControl, .playlistReadPrivate]
//        if #available(iOS 11, *) {
//            sessionManager.initiateSession(with: scope, options: .clientOnly) // take advantage of SFAuthenticationSession
//        } else {
//            print("Sorry! No can do")
////            sessionManager.initiateSession(with: scope, options: .clientOnly, presenting: self)  // doesn't work because presenting needs UIView controller // Use this on iOS versions < 11 to use SFSafariViewController
//        }
//    }
//
//    // initiate authorization and connect to Spotify -- if successful will call "appRemoteDidEstablishConnection"
//    func connect() {
//      self.appRemote.authorizeAndPlayURI(self.playURI)
//    }
//
//    // sets up our delegate here in App Remote
//    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
//        print("connected")
//        appRemote.playerAPI?.delegate = self
//        appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
//            if let error = error {
//                print("Error subscribing to player state:" + error.localizedDescription)
//            }
//        })
//        self.fetchPlayerState()
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
//        lastPlayerState = nil
//    }
//
//    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
//        lastPlayerState = nil
//    }
//
//    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
//        debugPrint("Track name: %@", playerState.track.name)
//    }
//
//    // might not need this...
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        appRemote.connectionParameters.accessToken = session.accessToken
//        appRemote.connect()
//    }
//
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        print("failed")
//    }
//
//    //TOKEN NECESSARY WHEN NEED TO SWITCH TO APP
//    func application(open url: URL) {
//        let parameters = appRemote.authorizationParameters(from: url);
//        if let access_token = parameters?[SPTAppRemoteAccessTokenKey] {
//            appRemote.connectionParameters.accessToken = access_token
//            self.accessToken = access_token
//        } else if (parameters?[SPTAppRemoteErrorDescriptionKey]) != nil {
//            // Show the error
//        }
//    }
//
//    func fetchPlayerState() {
//        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
//            if let error = error {
//                print("Error getting player state:" + error.localizedDescription)
//            } else if let playerState = playerState as? SPTAppRemotePlayerState {
//                self?.update(playerState: playerState)
//            }
//        })
//    }
//
//    func update(playerState: SPTAppRemotePlayerState) {
//         if lastPlayerState?.track.uri != playerState.track.uri {
//             fetchArtwork(for: playerState.track)
//         }
//         lastPlayerState = playerState
//         trackLabel = playerState.track.name
//     }
//
//    func fetchArtwork(for track:SPTAppRemoteTrack) {
//           appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
//               if let error = error {
//                   print("Error fetching track image: " + error.localizedDescription)
//               } else if let image = image as? UIImage {
//                   self?.imageView.image = image
//               }
//           })
//       }
//
//    // MARK: - Actions
//
//    func didTapPauseOrPlay(_ button: UIButton) {
//        if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
//            appRemote.playerAPI?.resume(nil)
//        } else {
//            appRemote.playerAPI?.pause(nil)
//        }
//    }
//
//    // will disconnect from App Remote once we leave our application
//    func applicationWillResignActive(_ application: UIApplication) {
//      if self.appRemote.isConnected {
//        self.appRemote.disconnect()
//      }
//    }
//
//    // will re-connect to App Remote once we re-open our application
//    func applicationDidBecomeActive(_ application: UIApplication) {
//      if let _ = self.appRemote.connectionParameters.accessToken {
//        self.appRemote.connect()
//      }
//    }
//}
//
//
//
