

import Foundation
import SwiftUI
import CoreData


/*
 A comment can only exist if there is a user and a song instance.
 */
enum CommentType: String, Codable  {
    case great
    case interesting
    case love
}

struct Comment: Codable, Hashable {
    
    var user: User
    var comment: CommentType
    var timeCommented: Date
    var forSongInst: SongInstance
    
    func convertToManagedObject(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> CommentEntity {
        let commentEntity = NSEntityDescription.insertNewObject(forEntityName: "CommentEntity", into: context!) as! CommentEntity
        commentEntity.comment_type = self.comment.rawValue
        commentEntity.time_commented = self.timeCommented
        commentEntity.comment_for = self.forSongInst.instantiateEntityFromExisting(context)
        commentEntity.commented_by = self.user.instantiateEntityFromExisting(context)
        return commentEntity
    }
}

extension Comment {
    init(commentEntity: CommentEntity) {
        self.user = User(userEntity: commentEntity.commented_by!)
        self.comment = CommentType.init(rawValue: commentEntity.comment_type!)!
        self.timeCommented = commentEntity.time_commented!
        self.forSongInst = SongInstance(instanceEntity: commentEntity.comment_for!)
    }
}
