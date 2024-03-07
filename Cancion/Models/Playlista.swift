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
    var smartRules: Bool
    var limit: Int
    var limitType: String
    var limitSortType: String
    var filters = [FilterModel]()
    var liveUpdating: Bool
    var sortOption: String
    var songs: [String]
    var cover: Data? = nil
    
    init(id: UUID = UUID(), title: String = "", smartRules: Bool = true, limit: Int = 25, limitType: String = "items", limitSortType: String = "most played", liveUpdating: Bool = false, sortOption: String = "most played", songs: [String] = []) {
        self.id = id
        self.title = title
        self.smartRules = smartRules
        self.limit = limit
        self.limitType = limitType
        self.limitSortType = limitSortType
        self.liveUpdating = liveUpdating
        self.sortOption = sortOption
        self.songs = songs
    }
}

enum Limit: String {
    case twentyFive = "25"
    case fifty = "50"
    case seventyFive = "75"
}

enum LimitType: String {
    case items = "items"
    case minutes = "minutes"
    case hours = "hours"
}

enum LimitSortType: String {
    case mostPlayed = "most played"
    case leastPlayed = "least played"
    case title = "title"
    case artist = "artist"
}
