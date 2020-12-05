//
//  CoreDataTests.swift
//  musicSharingTests
//
//  Created by Varghese Thomas on 03/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import XCTest
import CoreData
@testable import musicSharing

class CoreDataTests: XCTestCase {
    
    var sut: CoreDataStoreContainer!
//    var TDManager: TestDataManager!
    
    override func setUp() {
        super.setUp()
        sut = CoreDataStoreContainer(.inMemory)
//        TDManager = TestDataManager(.inMemory)
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
//        TDManager = nil
    }
    
    func testSetupPersistentStore() {
        XCTAssertTrue(self.sut.persistentContainer.persistentStoreCoordinator.persistentStores.count > 0)
    }
    
    func testValidBackgroundContext() {
        XCTAssertEqual(self.sut.backgroundContext.concurrencyType, .privateQueueConcurrencyType)
    }
    
    func testValidMainContext() {
        XCTAssertEqual(self.sut.context.concurrencyType, .mainQueueConcurrencyType)
    }
    
//    func testLoadingJSON() {
//        XCTAssertNotNil(TDManager.testData, "json data must exist")
//        XCTAssertTrue(TDManager.loadSongsFromJSON() == true, "test manager loading songs must be true")
//        XCTAssertTrue(TDManager.loadUsersFromJSON() == true, "test manager loading users must be true")
//        XCTAssertTrue(TDManager.loadSongInstancesFromJSON() == true, "test manager loading song instances must be true")
//    }
//
//    func testAssigningTestRelationships() {
//        XCTAssertTrue(TDManager.assignInitialFriendshipsToUser() == true, "test manager assigning initial friendships must be true")
//        XCTAssertTrue(TDManager.assignMainUsersSentFollowRequests() == true, "test manager assigning initial sent follow requests must be true")
//        XCTAssertTrue(TDManager.assignInitialFollowRequestsForMainUser() == true, "test manager assigning initial follow requests to user must be true")
//    }
//
//    func testDataRetrievals() {
//        XCTAssertNotNil(TDManager.CDataRetManager.getUserWithName("Tom"), "getting 'Tom' user must not be nil")
//        XCTAssertNil(TDManager.CDataRetManager.getUserWithName("asfljaslfkjaslkdf"), "getting nonsense name must be nil")
//    }
//
//    func testDeletions() {
//        XCTAssertTrue(TDManager.deleteAllSongs() == true, "test manager failed to delete all songs")
//        XCTAssertTrue(TDManager.deleteAllUsers() == true, "test manager failed to delete all users")
//    }
}
