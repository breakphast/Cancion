//
//  ArtistFilterModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/1/24.
//

import Foundation
import SwiftData

@Model
class ArtistFilterModel {
    var id: UUID
    
    var value: String
    var condition: String
    
    init(id: UUID = UUID(), value: String = "", condition: String = "equals") {
        self.id = id
        self.value = value
        self.condition = condition
    }
}
