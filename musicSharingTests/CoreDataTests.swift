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
    var TDManager: TestDataManager!
    
    override func setUp() {
        super.setUp()
        sut = CoreDataStoreContainer(.inMemory)
        TDManager = TestDataManager(.inMemory, backgroundContext: sut.backgroundContext)
    }

    override func tearDown() {
        super.tearDown()
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        TDManager = nil
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
    
    func testMatchingBackgroundContexts() {
        XCTAssertEqual(sut.backgroundContext, TDManager.context, "Test Data Manager is not using the same background context as the CoreDataContainer stack")
    }
    
    func testLoadingJSON() {
        XCTAssertNotNil(TDManager.testData, "json data must exist")
        XCTAssertTrue(TDManager.loadSongsFromJSON() == true, "test manager loading songs must be true")
        XCTAssertTrue(TDManager.loadUsersFromJSON() == true, "test manager loading users must be true")
        XCTAssertTrue(TDManager.loadSongInstancesFromJSON() == true, "test manager loading song instances must be true")
    }

//    func testDidSaveData() {
//        let newContext = sut.newDerivedContext()
//        let newTD = TestDataManager(.inMemory, backgroundContext: newContext)
//        expectation(
//          forNotification: .NSManagedObjectContextDidSave,
//          object: newContext) { _ in
//            return true
//        }
//        newContext?.perform {
//            newTD.saveFakeData()
//        }
//        waitForExpectations(timeout: 5.0) { error in
//            XCTAssertNil(error, "Could not save test data")
//        }
//    }

    func testDataRetrievals() {
        let newContext = sut.newDerivedContext()
        let newTD = TestDataManager(.inMemory, backgroundContext: newContext)
        
        let id = MainUser.idMainUser
        let tomUser = User(id: UUID(uuidString: id)!, name: "Tom", user_bio: "", avatar: "")
        let tomEnt = newTD.addUserEntity(user: tomUser)
        let sheilaUser = User(name: "Sheila", user_bio: "", avatar: "")
        let sheilaEnt = newTD.addUserEntity(user: sheilaUser)
        _ = newTD.userIsFriends(user: tomEnt!, friend: sheilaEnt!)
        
        let getTom = User(userEntity: newTD.getUserWithName("Tom")!)
        let getNull = newTD.getUserWithName("asfasdfas")
        let getTomsFriends = newTD.getUsersFriends(id)
        print("UUID: \(UUID(uuidString: id)!), \(id)")
        print("\(String(describing: getTomsFriends))")
//        let isSheila = User(userEntity: getTomsFriends![0])
        XCTAssertNotNil(getTom)
        XCTAssertNotNil(getTomsFriends)
//        XCTAssertEqual(isSheila.name, sheilaUser.name)
        XCTAssertNil(getNull)
        
    }

//    func testDeletions() {
//        let newContext = sut.newDerivedContext()
//        let newTD = TestDataManager(.inMemory, backgroundContext: newContext)
//        var didDeleteSongs = false
//        var didDeleteUsers = false
//        expectation(
//          forNotification: .NSManagedObjectContextDidSave,
//          object: newContext) { _ in
//            return true
//        }
//        newContext?.perform {
//            newTD.saveFakeData()
//            didDeleteSongs = newTD.deleteAllSongs()
//            didDeleteUsers = newTD.deleteAllUsers()
//        }
//        waitForExpectations(timeout: 5.0) { _ in
//            XCTAssertTrue(didDeleteSongs == true, "test manager failed to delete all songs")
//            XCTAssertTrue(didDeleteUsers == true, "test manager failed to delete all users")
//        }
//    }
}

