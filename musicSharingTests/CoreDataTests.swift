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
    
    var coreDataStack: CoreDataStoreContainer!
    var TDManager: TestDataManager!
    
    override func setUp() {
        super.setUp()
        coreDataStack = CoreDataStoreContainer(.inMemory)
        TDManager = TestDataManager(.inMemory)
        TDManager.saveFakeData()
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        coreDataStack = nil
        TDManager = nil
    }
    
    func testLoadingJSON() {
        XCTAssertNotNil(TDManager.testData, "json data must exist")
        XCTAssertTrue(TDManager.loadSongsFromJSON() == true, "test manager loading songs must be true")
        XCTAssertTrue(TDManager.loadUsersFromJSON() == true, "test manager loading users must be true")
        XCTAssertTrue(TDManager.loadSongInstancesFromJSON() == true, "test manager loading song instances must be true")
    }
    
    func testAssigningTestRelationships() {
        XCTAssertTrue(TDManager.assignInitialFriendshipsToUser() == true, "test manager assigning initial friendships must be true")
        XCTAssertTrue(TDManager.assignMainUsersSentFollowRequests() == true, "test manager assigning initial sent follow requests must be true")
        XCTAssertTrue(TDManager.assignInitialFollowRequestsForMainUser() == true, "test manager assigning initial follow requests to user must be true")
    }
    
    func testDataRetrievals() {
        XCTAssertNotNil(TDManager.CDataRetManager.getUserWithName("Tom"), "getting 'Tom' user must not be nil")
        XCTAssertNil(TDManager.CDataRetManager.getUserWithName("asfljaslfkjaslkdf"), "getting nonsense name must be nil")
    }
    
    func testDeletions() {
        XCTAssertTrue(TDManager.deleteAllSongs() == true, "test manager failed to delete all songs")
        XCTAssertTrue(TDManager.deleteAllUsers() == true, "test manager failed to delete all users")
    }
}
