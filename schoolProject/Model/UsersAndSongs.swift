
/* in addition to the member-wise initializers, providing additional initializer using an Entity instance to create the following structs.
 
    Each struct instance can also create an entity instance as well with a ".convertToManagedObject()" method
 */
import Foundation

struct User: Codable, Identifiable, Hashable {
    public var id: UUID = UUID()
    let name: String
    let user_bio: String?
    let avatar: String?
    var listenedTo = [Song]()
    // add stash property
    
    func convertToManagedObject() -> UserEntity {
        let userEntity = UserEntity(context: CoreDataManager.context)
        userEntity.userID = self.id
        userEntity.name = self.name
        userEntity.bio = self.user_bio
        userEntity.avatar = self.avatar
        userEntity.listened_to = NSSet(object: self.listenedTo)
        return userEntity
    }
}


extension User {
    init(userEntity: UserEntity) {
        self.id = userEntity.userID!
        self.name = userEntity.name ?? "Unknown"
        self.user_bio = userEntity.bio ?? "prefers to keep an air of mystery"
        self.avatar = userEntity.avatar ?? "northern-lights"
//        self.listenedTo = self.getListenedTo(userEntity)
    }
    
//    func getListenedTo(_ userEntity: UserEntity) -> [Song] {
//        var songs = [Song]()
//        if ((userEntity.listened_to?.allObjects as? [SongEntity]) == nil) {
//            return songs
//        }
//        let r = userEntity.listened_to?.allObjects as? [SongEntity]
//        for listened in userEntity.listened_to!.allObjects as! [SongEntity]{
//            let song = Song(songEntity: listened)
//            songs.append(song)
//        }
//        return songs
//    }
    
}

struct Song: Codable, Identifiable, Hashable {
    
    public var id: UUID = UUID()
    let name: String
//    var playedBy: UUID!
    let artist: String?
    let genre: String?
    let image: String?
    let songLength: Decimal?
//    var likers = [User]()
//    // add convo property
//    // add stash relationship
//
//    var numLikes: Int {
//        return likers.count
//    }
    
    func convertToManagedObject() -> SongEntity {
        let songEntity = SongEntity(context: CoreDataManager.context)
        songEntity.song_id = self.id
        songEntity.song_name = self.name
        songEntity.artist_name = self.artist
        songEntity.genre = self.genre
        songEntity.song_image = self.image
        songEntity.song_length = self.songLength as NSDecimalNumber?
//        songEntity.liked_by = NSSet(object: self.likers)
        return songEntity
    }
}

//
extension Song {
    init(songEntity: SongEntity) {
        self.id = songEntity.song_id!
        self.name = songEntity.song_name!
        self.artist = songEntity.artist_name ?? "Unknown"
        self.genre = songEntity.genre ?? "Unknown"
        self.image = songEntity.song_image ?? "northern-lights"
        self.songLength = songEntity.song_length?.decimalValue ?? 0.00
//        self.likers = self.getPeopleLikes(songEntity: songEntity)
//        self.playedBy = User(userEntity: songEntity.played_by!)
    }
    
//    func getPeopleLikes(songEntity: SongEntity) -> [User] {
//        var likers = [User]()
//        if songEntity.liked_by?.allObjects as? [UserEntity] == nil {
//            return likers
//        }
//        for liker in songEntity.liked_by!.allObjects as! [UserEntity]{
//            let user = User(userEntity: liker)
//            likers.append(user)
//        }
//        return likers
//    }
}

struct SongInstance: Identifiable, Hashable {
    public var id: UUID = UUID()
    let instanceOf: Song
    let playedBy: User
    var likers = [User]()
    // add convo property
    // add stash relationship
    
    var numLikes: Int {
        return likers.count
    }
    
    func convertToManagedObject() -> SongInstanceEntity {
        let instanceEntity = SongInstanceEntity(context: CoreDataManager.context)
        instanceEntity.instance_id = self.id
        instanceEntity.instance_of = self.instanceOf.convertToManagedObject()
        instanceEntity.liked_by = NSSet(object: self.likers)
        instanceEntity.played_by = self.playedBy.convertToManagedObject()
        
        return instanceEntity
    }
}

extension SongInstance {
    init(instanceEntity: SongInstanceEntity) {
        self.id = instanceEntity.instance_id!
        self.instanceOf = Song(songEntity: instanceEntity.instance_of!)
        self.playedBy = User(userEntity: instanceEntity.played_by!)
        self.likers = self.getPeopleLikes(instanceEntity: instanceEntity)
    }
    
    func getPeopleLikes(instanceEntity: SongInstanceEntity) -> [User] {
        var likers = [User]()
        if instanceEntity.liked_by?.allObjects as? [UserEntity] == nil {
            return likers
        }
        for liker in instanceEntity.liked_by!.allObjects as! [UserEntity]{
            let user = User(userEntity: liker)
            likers.append(user)
        }
        return likers
    }
}


