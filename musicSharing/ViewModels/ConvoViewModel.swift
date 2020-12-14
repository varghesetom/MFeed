//
//  ConvoViewModel.swift
//  musicSharing
//
//  Created by Varghese Thomas on 14/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import SwiftUI

class ConvoViewModel: ObservableObject {
    var manager: TestDataManager
    var songInstEnt: SongInstanceEntity
    var toggleGreatComment = false
    var toggleInterestingComment = false
    var toggleLoveComment = false
    @Published var comments = [Comment]()
    
    init(_ manager: TestDataManager, _ songInstEnt: SongInstanceEntity) {
        self.manager = manager
        self.songInstEnt = songInstEnt
    }
    
    func getAllCommentsForSongInstance() {
        let songInstID = SongInstance(instanceEntity: self.songInstEnt).id
        guard self.manager.getCommentsForSongInstID(songInstID: songInstID) != nil else {
            print("Couldn't load song comments")
            return
        }
        comments = self.manager.getCommentsForSongInstID(songInstID: songInstID)!
        print("Comments fetched...\(comments)")
    }
    
    func getEnhancedCommentFromCommentType(_ commentType: CommentType) -> String {
        switch commentType {
        case .great:
            return EnhancedComment.greatSong
        case .interesting:
            return EnhancedComment.interestingSong
        case .love:
            return EnhancedComment.loveSong
        }
    }
    
    func addCommentBasedOnActionType(_ enhancedCommentType: String) {
        let translatedCommentType = self.getCommentTypeFromEnhancedComment(enhancedCommentType)
        self.manager.addCommentEntity(commentType: translatedCommentType, songInstEnt: self.songInstEnt, userEnt: self.manager.fetchMainUser()!)
    }
    
    func getCommentTypeFromEnhancedComment(_ enhancedCommentType: String) -> CommentType {
        switch enhancedCommentType {
        case EnhancedComment.greatSong:
            return CommentType.great
        case EnhancedComment.interestingSong:
            return CommentType.interesting
        case EnhancedComment.loveSong:
            return CommentType.love
        default:
            print("Couldn't match enhanced comment type. Default will be 'Interesting' comment type")
            return CommentType.interesting
        }
    }
}
