//
//  Genre.swift
//  musicSharing
//
//  Created by Varghese Thomas on 07/12/2020.
//  Copyright © 2020 Varghese Thomas. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData

struct Genre: Codable, Hashable {
    let genre: String
    
    func convertToManagedObject(_ context: NSManagedObjectContext? = CoreDataStoreContainer.shared?.backgroundContext) -> GenreEntity {
        let genreEntity = NSEntityDescription.insertNewObject(forEntityName: "GenreEntity", into: context!) as! GenreEntity
        genreEntity.genre_name = self.genre
        return genreEntity
    }
}

extension Genre {
    init(genreEntity: GenreEntity) {
        self.genre = genreEntity.genre_name ?? "Unknown"
    }
}
