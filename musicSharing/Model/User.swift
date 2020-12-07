
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
    
    func convertToManagedObject(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> UserEntity {
        // reconfigure to avoid mismatching when testing. Core Data gets confused when it thinks multiple NSEntityDescriptions claim NSManagedObject subclasses
        let userEntity = NSEntityDescription.insertNewObject(forEntityName: "UserEntity", into: context!) as! UserEntity
        userEntity.userID = self.id
        userEntity.name = self.name
        userEntity.bio = self.user_bio
        userEntity.avatar = self.avatar
        userEntity.toggled_genre = NSSet()
        for genre in self.genres {
            userEntity.addToToggled_genre(genre.convertToManagedObject())
        }
        return userEntity
    }

}


extension User {
    init(userEntity: UserEntity) {
        self.id = userEntity.userID!
        self.name = userEntity.name ?? "Unknown"
        self.user_bio = userEntity.bio ?? "prefers to keep an air of mystery"
        self.avatar = userEntity.avatar ?? "northern-lights"
        self.genres = []
        self.genres = self.getGenres(userEntity: userEntity)
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
}




