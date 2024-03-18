//
//  Playlista.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/1/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
class Playlista {
    var id: UUID
    var title: String
    var smartRules: Bool?
    var limit: Int?
    var limitType: String?
    var limitSortType: String?
    var filters: [FilterModel]? = []
    var liveUpdating: Bool
    var sortOption: String?
    var songs: [String]
    var cover: Data? = nil
    var matchRules: String?
    
    init(id: UUID = UUID(), title: String = "", smartRules: Bool? = true, limit: Int? = 25, limitType: String? = "items", limitSortType: String? = "most played", filters: [FilterModel]? = [], liveUpdating: Bool = true, sortOption: String? = "most played", songs: [String] = [], cover: Data? = nil, matchRules: String? = "any") {
        self.id = id
        self.title = title
        self.smartRules = smartRules
        self.limit = limit
        self.limitType = limitType
        self.limitSortType = limitSortType
        self.filters = filters
        self.liveUpdating = liveUpdating
        self.sortOption = sortOption
        self.songs = songs
        self.cover = cover
        self.matchRules = matchRules
    }
}

enum LimitType: String, CaseIterable {
    case items = "items"
    case minutes = "minutes"
    case hours = "hours"
}

enum Limit {
    case items(value: String)
    case minutes(value: String)
    case hours(value: String)
    
    static func limits(forType rawType: String) -> [Limit] {
        guard let type = LimitType(rawValue: rawType) else { return [] }
        switch type {
        case .items:
            return [.items(value: "25"), .items(value: "50"), .items(value: "100"), .items(value: "250"), .items(value: "500")]
        case .minutes:
            return [.minutes(value: "15"), .minutes(value: "30"), .minutes(value: "45"), .minutes(value: "60")]
        case .hours:
            return [.hours(value: "1"), .hours(value: "3"), .hours(value: "5"), .hours(value: "12")]
        }
    }
    
    var value: String {
        switch self {
        case .items(let value), .minutes(let value), .hours(let value):
            return value
        }
    }
}

enum LimitSortType: String, CaseIterable {
    case mostPlayed = "most played"
    case mostRecentlyAdded = "most recently added"
    case title = "title"
    case artist = "artist"
    case random = "random"
}
