//
//  MusicTweetViewModel.swift
//  musicSharing
//
//  Created by Varghese Thomas on 12/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import SwiftUI

class MusicTweetViewModel: ObservableObject {
    var TDManager: TestDataManager
    var songInstEnt: SongInstanceEntity
//    @ObservedObject var lvModel: LikeViewModel
    @Published var numLikes = 0
    
    init(_ manager: TestDataManager, _ songInstEnt: SongInstanceEntity) {
        self.TDManager = manager
        self.songInstEnt = songInstEnt
//        self.lvModel = LikeViewModel(self.TDManager, self.songInstEnt)
    }
    
    func belongsToMainUser() -> Bool {
        let songInst = SongInstance(instanceEntity: songInstEnt)
        return songInst.playedBy.id == User(userEntity: self.TDManager.fetchMainUser()!).id ? true : false
    }
    
    func showLikes() -> Bool {
        return self.numLikes > 0 ? true : false
    }
    
    func stashCurrentTweet() -> Void{
        self.TDManager.userStashesSong(user: self.TDManager.fetchMainUser()!, songInstance: songInstEnt)
    }
    
    func addLikeAndUpdate() -> Void {
        print("Before adding like relationship: \(self.numLikes)")
        self.TDManager.userLikesSong(user: self.TDManager.fetchMainUser()!, songInstance: songInstEnt)
        self.getLikes()
        print("Current # of likes: \(self.numLikes)")
    }
    
    func getLikes() {
        self.numLikes = self.TDManager.getLikesForSongInstID(songInstID: songInstEnt.instance_id! )
        print("In LVModel, the # is \(numLikes)")
    }

    func deleteSongInstance() {
        _ = self.TDManager.deleteSongInstance(songInstID: songInstEnt.instance_id!)
    }
}
