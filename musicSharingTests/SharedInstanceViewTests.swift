import XCTest
import SwiftUI
import CoreData
@testable import musicSharing

class SharedInstanceViewTests: XCTestCase {
    var sut: CoreDataStoreContainer!
    var songDescription: NSEntityDescription!
    var songInstanceDescription: NSEntityDescription!
    var userDescription: NSEntityDescription!
    
    override func setUp() {
        super.setUp()
        sut = CoreDataStoreContainer(.inMemory)
        songDescription = NSEntityDescription.entity(forEntityName: "SongEntity", in: sut.backgroundContext)
        songInstanceDescription = NSEntityDescription.entity(forEntityName: "SongInstanceEntity", in: sut.backgroundContext)
        userDescription = NSEntityDescription.entity(forEntityName: "UserEntity", in: sut.backgroundContext)
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
    }
    
    func testCheckIfSongAlreadyExists() {
        let shared = SharedInstanceView(TestDataManager(.inMemory, backgroundContext: sut.backgroundContext))
        let testSongName = "Test Song"
        let testSong = Song(name: testSongName, artist: "Rocky", genre: "Rock", songLength: 0.0)
        XCTAssertFalse(shared.checkIfSongAlreadyExists(testSongName), "No song must exist yet")
        _ = shared.TDManager.addSongEntity(song: testSong)
        XCTAssertTrue(shared.checkIfSongAlreadyExists(testSongName), "song must exist")
    }
    
    func testIfValidSong() {
        let shared = SharedInstanceView(TestDataManager(.inMemory, backgroundContext: sut.backgroundContext))
        XCTAssertTrue(shared.isValidSongLink("blah.com"))
        XCTAssertTrue(shared.isValidSongName("Blue Bayou"))
        XCTAssertTrue(shared.didProvideCorrectRequiredInfo(songName: "test", songLink: "test"))
    }
    
    func testGetSong() {
        let shared = SharedInstanceView(TestDataManager(.inMemory, backgroundContext: sut.backgroundContext))
        let testSongName = "Test Song"
        let testSong = Song(name: testSongName, artist: "Rocky", genre: "Rock", songLength: 0.0)
        _ = shared.TDManager.addSongEntity(song: testSong)
        let returnedSongEnt = shared.TDManager.getSong(testSongName)
        XCTAssertNotNil(returnedSongEnt)
    }
    
    func testCreatingSongInstance() {
        let shared = SharedInstanceView(TestDataManager(.inMemory, backgroundContext: sut.backgroundContext))
        let testSongName = "Test Song"
        let testSongLink = "example.com"
        let testSong = Song(name: testSongName, artist: "Rocky", genre: "Rock", songLength: 0.0)
        let id = MainUser.idMainUser
        let tomUser = User(id: UUID(uuidString: id)!, name: "Tom", user_bio: "", avatar: "")
        _ = shared.TDManager.addUserEntity(user: tomUser)
        _ = shared.TDManager.addSongEntity(song: testSong)
        XCTAssertNotNil(shared.addOnlySongInstanceIfSongExists(testSong, tomUser))
    }
    
}
