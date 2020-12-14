//
//  Song.swift
//  musicSharing
//
//  Created by Varghese Thomas on 07/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct Song: Codable, Identifiable, Hashable {
    
    public var id: UUID
    let name: String
    let artist: String?
    let genre: String?
    let image: String
    let songLength: Decimal?
    
    init(songId: UUID = UUID(), name: String, artist: String? = nil, genre: String? = nil, image: String = "northern_lights", songLength: Decimal?) {
        self.id = songId
        self.name = name
        self.artist = artist
        self.genre = genre
        self.image = image
        self.songLength = songLength
    }
    
    func convertToManagedObject(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> SongEntity {
        let songEntity = NSEntityDescription.insertNewObject(forEntityName: "SongEntity", into: context!) as! SongEntity
        songEntity.song_id = self.id
        songEntity.song_name = self.name
        songEntity.artist_name = self.artist
        songEntity.genre = self.genre
        songEntity.song_image = self.image
        songEntity.song_length = self.songLength as NSDecimalNumber?
        return songEntity
    }
}

extension Song {
    init(songEntity: SongEntity) {
        self.id = songEntity.song_id!
        self.name = songEntity.song_name!
        self.artist = songEntity.artist_name ?? "Unknown"
        self.genre = songEntity.genre ?? "Unknown"
        self.image = songEntity.song_image ?? "northern-lights"
        self.songLength = songEntity.song_length?.decimalValue ?? 0.00
    }
}
