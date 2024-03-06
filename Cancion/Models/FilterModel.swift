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
    
    init(id: UUID = UUID(), type: String = "artist", value: String = "", condition: String = "is") {
        self.id = id
        self.type = type
        self.value = value
        self.condition = condition
    }
}

func matches(song: Song, filter: FilterModel) -> Bool {
    switch filter.condition {
    case Condition.equals.rawValue:
        switch filter.type {
        case FilterType.artist.rawValue:
            return song.artistName == filter.value
        case FilterType.title.rawValue:
            return song.title == filter.value
        default:
            return false
        }
    case Condition.contains.rawValue:
        switch filter.type {
        case FilterType.artist.rawValue:
            return song.artistName.contains(filter.value)
        case FilterType.title.rawValue:
            return song.title.contains(filter.value)
        default:
            return false
        }
    case Condition.greaterThan.rawValue:
        switch filter.type {
        case FilterType.plays.rawValue:
            if let plays = song.playCount, let value = Int(filter.value) {
                return plays > value
            }
        default:
            return false
        }
    case Condition.lessThan.rawValue:
        switch filter.type {
        case FilterType.plays.rawValue:
            if let plays = song.playCount, let value = Int(filter.value) {
                return plays < value
            }
        default:
            return false
        }
    default:
        return false
    }
    return false
}

enum FilterType: String, CaseIterable {
    case artist = "artist"
    case title = "title"
    case plays = "play count"
}
