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
    var filters = [FilterModel]()
    var liveUpdating: Bool
    var sortOption: String
    var songs: [String]
    var cover: Data? = nil
    
    init(id: UUID = UUID(), title: String = "", smartRules: Bool = true, limit: Int = 25, liveUpdating: Bool = false, sortOption: String = "most played", songs: [String] = []) {
        self.id = id
        self.title = title
        self.smartRules = smartRules
        self.limit = limit
        self.liveUpdating = liveUpdating
        self.sortOption = sortOption
        self.songs = songs
    }
}
