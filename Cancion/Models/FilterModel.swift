//
//  ArtistFilterModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/1/24.
//

import Foundation
import SwiftData
import MusicKit

@Model
class FilterModel {
    var id: UUID
    var type: String
    var value: String
    var condition: String
    
    init(id: UUID = UUID(), type: String = "artist", value: String = "", condition: String = "equals") {
        self.id = id
        self.type = type
        self.value = value
        self.condition = condition
    }
}

func matches(song: Song, filter: FilterModel) -> Bool {
    switch filter.condition {
    case "equals":
        switch filter.type {
        case FilterType.artist.rawValue:
            return song.artistName == filter.value
        case FilterType.title.rawValue:
            return song.title == filter.value
        default:
            return false
        }
    default:
        return false
    }
}

enum FilterType: String {
    case artist = "artist"
    case title = "title"
}
