
/* in addition to the member-wise initializers, providing additional initializer using an Entity instance to create the following structs.
 
    Each struct instance can also create an entity instance as well with a ".convertToManagedObject()" method
 */
import Foundation
import SwiftUI
import CoreData

struct User: Codable, Identifiable, Hashable {
    public var id: UUID = UUID()
    let name: String
    let user_bio: String?
    let avatar: String?
    var genres: [Genre]
//    var comments: [Comment]
    
    func convertToManagedObject(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> UserEntity {
        // reconfigure to avoid mismatching when testing. Core Data gets confused when it thinks multiple NSEntityDescriptions claim NSManagedObject subclasses
        let userEntity = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: context!) as! UserEntity
        userEntity.userID = self.id
        userEntity.name = self.name
        userEntity.bio = self.user_bio
        userEntity.avatar = self.avatar
        userEntity.toggled_genre = NSSet()
        userEntity.commented_on = NSSet()
        for genre in self.genres {
            userEntity.addToToggled_genre(genre.convertToManagedObject())
        }
//        for comment in self.comments {
//            userEntity.addToCommented_on(comment.convertToManagedObject())
//        }
        return userEntity
    }

}


extension User {
    init(userEntity: UserEntity) {
        print("creating user from userEnt: \(userEntity)")
        self.id = userEntity.userID!
        self.name = userEntity.name ?? "Unknown"
        self.user_bio = userEntity.bio ?? "prefers to keep an air of mystery"
        self.avatar = userEntity.avatar ?? "northern-lights"
        self.genres = []
//        self.comments = []
//        self.genres = self.getGenres(userEntity: userEntity)
//        self.comments = self.getComments(userEntity: userEntity)
    }
    
    func instantiateEntityFromExisting(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> UserEntity {
        return UserEntity(context: context!)
    }
    
    func getGenres(userEntity: UserEntity) -> [Genre] {
        var genres = [Genre]()
        if userEntity.toggled_genre?.allObjects as? [GenreEntity] == nil {
            return genres
        }
        for genreEnt in userEntity.toggled_genre!.allObjects as! [GenreEntity] {
            let toggled = Genre(genreEntity: genreEnt)
            genres.append(toggled)
        }
        return genres
    }
//
//    func getComments(userEntity: UserEntity) -> [Comment] {
//        var comments = [Comment]()
//        if userEntity.commented_on?.allObjects as? [CommentEntity] == nil {
//            return comments
//        }
//        for commentEnt in userEntity.commented_on!.allObjects as! [CommentEntity] {
//            let commented = Comment(commentEntity: commentEnt)
//            comments.append(commented)
//        }
//        return comments
//    }
}




