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

func matches(song: Song, filter: FilterModel, date: Date?) -> Bool {
    switch filter.condition {
    case Condition.equals.rawValue:
        switch filter.type {
        case FilterType.artist.rawValue:
            return song.artistName.lowercased() == filter.value.lowercased()
        case FilterType.title.rawValue:
            return song.title.lowercased() == filter.value.lowercased()
        case FilterType.dateAdded.rawValue:
            if let dateAdded = song.libraryAddedDate, let date {
                return areDatesEqual(date1: dateAdded, date2: date)
            }
        case FilterType.lastPlayedDate.rawValue:
            if let dateAdded = song.lastPlayedDate, let date {
                return areDatesEqual(date1: dateAdded, date2: date)
            }
        default:
            return false
        }
    case Condition.contains.rawValue:
        switch filter.type {
        case FilterType.artist.rawValue:
            return song.artistName.lowercased().contains(filter.value.lowercased())
        case FilterType.title.rawValue:
            return song.title.lowercased().contains(filter.value.lowercased())
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
    case Condition.before.rawValue:
        switch filter.type {
        case FilterType.dateAdded.rawValue:
            if let dateAdded = song.libraryAddedDate, let date {
                return dateAdded < date
            }
        case FilterType.lastPlayedDate.rawValue:
            if let dateAdded = song.lastPlayedDate, let date {
                return dateAdded < date
            }
        default:
            return false
        }
        return false
    case Condition.after.rawValue:
        switch filter.type {
        case FilterType.dateAdded.rawValue:
            if let dateAdded = song.libraryAddedDate, let date {
                return dateAdded > date
            }
        case FilterType.lastPlayedDate.rawValue:
            if let dateAdded = song.lastPlayedDate, let date {
                return dateAdded > date
            }
        default:
            return false
        }
    default:
        return false
    }
    return false
}

func areDatesEqual(date1: Date, date2: Date) -> Bool {
    let calendar = Calendar.current
    return calendar.isDate(date1, equalTo: date2, toGranularity: .day) &&
    calendar.isDate(date1, equalTo: date2, toGranularity: .month) &&
    calendar.isDate(date1, equalTo: date2, toGranularity: .year)
}

enum FilterType: String, CaseIterable {
    case artist = "artist"
    case title = "title"
    case plays = "play count"
    case dateAdded = "date added"
    case lastPlayedDate = "last played"
}
