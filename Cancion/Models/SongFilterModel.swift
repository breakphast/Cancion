//
//  FilterModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import SwiftUI
import MusicKit
import SwiftData

protocol SongFilterModel {
    var id: UUID { get }
    var condition: Condition { get set }
    var value: String { get set }
    func matches(song: Song) -> Bool
}

func matchess(song: Song, value: String, condition: String, type: FilterType) -> Bool {
    switch condition {
    case "equals":
        switch type {
        case .artist:
            return song.artistName == value
        case .title:
            return song.title == value
        }
    default:
        return false
    }
}

struct TitleFilter: SongFilterModel {
    var id = UUID()
    
    var value: String
    var condition: Condition
    
    func matches(song: Song) -> Bool {
        switch condition {
        case .equals:
            return song.title == value
        case .contains:
            return song.title.contains(value)
        default:
            return false
        }
    }
}

struct LimitFilter: SongFilterModel {
    var id = UUID()
    var active: Bool
    var limit: String
    var limitTypeSelection: String
    var limitSortSelection: String
    var condition: Condition
    var value: String
}

struct PlayCountFilter: SongFilterModel {
    var id = UUID()
    
    var playCount: Int
    var condition: Condition
    var value: String
    
    func matches(song: Song) -> Bool {
        switch condition {
        case .equals:
            return song.playCount == playCount
        default:
            return false
        }
    }
}

struct CompositeFilter: SongFilterModel {
    var id = UUID()
    var condition: Condition = .contains
    var value: String = ""
    
    private let filters: [SongFilterModel]
    
    init(filters: [SongFilterModel]) {
        self.filters = filters
    }
    
    func matches(song: Song) -> Bool {
        return filters.allSatisfy { $0.matches(song: song) }
    }
}

enum FilterTitle: String {
    case artist = "Artist"
    case title = "Title"
    case playCount = "Play Count"
}

enum ConditionalTitle: String {
    case equal = "is"
    case contains = "contains"
    case doesNotContain = "does not contain"
}

enum FilterType {
    case artist
    case title
}

enum Condition {
    case equals
    case contains
    case doesNotContain
    case greaterThan
    case lessThan
}

enum Conditionn: String {
    case equals = "equals"
}

extension SongFilterModel {
    func matches(song: Song) -> Bool { return true }
}
