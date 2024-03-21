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
    var date: String?
    
    init(id: UUID = UUID(), type: String = "artist", value: String = "", condition: String = "is", date: String? = nil) {
        self.id = id
        self.type = type
        self.value = value
        self.condition = condition
        self.date = date
    }
}

func matches(song: Song, filter: FilterModel, date: Date?) -> Bool {
    let filterValue = filter.value.lowercased().trimmingCharacters(in: .whitespaces)
    
    switch filter.condition {
    case Condition.equals.rawValue:
        switch filter.type {
        case FilterType.artist.rawValue:
            return song.artistName.lowercased() == filterValue
        case FilterType.title.rawValue:
            return song.title.lowercased() == filterValue
        case FilterType.dateAdded.rawValue, FilterType.lastPlayedDate.rawValue:
            if let songDate = (filter.type == FilterType.dateAdded.rawValue ? song.libraryAddedDate : song.lastPlayedDate), let filterDate = date {
                return areDatesEqual(date1: songDate, date2: filterDate)
            }
        default:
            break
        }
        
    case Condition.contains.rawValue, Condition.doesNotContain.rawValue:
        let contains = (filter.type == FilterType.artist.rawValue && song.artistName.lowercased().contains(filterValue)) || (filter.type == FilterType.title.rawValue && song.title.lowercased().contains(filterValue))
        return filter.condition == Condition.contains.rawValue ? contains : !contains
        
    case Condition.greaterThan.rawValue, Condition.lessThan.rawValue:
        if filter.type == FilterType.plays.rawValue, let plays = song.playCount, let value = Int(filterValue) {
            return filter.condition == Condition.greaterThan.rawValue ? plays > value : plays < value
        }
        
    case Condition.before.rawValue, Condition.after.rawValue:
        if let songDate = (filter.type == FilterType.dateAdded.rawValue ? song.libraryAddedDate : filter.type == FilterType.lastPlayedDate.rawValue ? song.lastPlayedDate : nil), let filterDate = date {
            return filter.condition == Condition.before.rawValue ? songDate < filterDate : songDate > filterDate
        }
        
    default:
        break
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
