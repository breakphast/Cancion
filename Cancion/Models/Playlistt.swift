//
//  Playlista.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/1/24.
//

import Foundation
import SwiftUI
import SwiftData
import AppIntents

@Model
class Playlistt {
    var id: UUID
    var name: String
    var smartRules: Bool?
    var limit: Int?
    var limitType: String?
    var limitSortType: String?
    var filters: [String]? = []
    var liveUpdating: Bool
    var sortOption: String?
    var songs: [String]
    var cover: Data? = nil
    var matchRules: String?
    var urlString: String?
    
    init(id: UUID = UUID(), title: String = "", smartRules: Bool? = true, limit: Int? = 25, limitType: String? = "items", limitSortType: String? = "most played", filters: [String] = [], liveUpdating: Bool = true, sortOption: String? = "most played", songs: [String] = [], cover: Data? = nil, matchRules: String? = "any", urlString: String? = nil) {
        self.id = id
        self.name = title
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
        self.urlString = urlString
    }
}

struct PlaylistaEntity: AppEntity, Identifiable {
    var id: UUID
    var name: String
    var smartRules: Bool?
    var limit: Int?
    var limitType: String?
    var limitSortType: String?
    var filters: [String]?
    var liveUpdating: Bool
    var sortOption: String?
    var songs: [String]
    var cover: Data?
    var matchRules: String?
    var urlString: String?
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(stringLiteral: name)
    }
    
    static var defaultQuery = PlaylistaQuery()
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Playlista"
    
    init(id: UUID, title: String, smartRules: Bool? = nil, limit: Int? = nil, limitType: String? = nil, limitSortType: String? = nil, filters: [String]? = nil, liveUpdating: Bool, sortOption: String? = nil, songs: [String], cover: Data? = nil, matchRules: String? = nil, urlString: String? = nil) {
        self.id = id
        self.name = title
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
        self.urlString = urlString
    }
    
    init(item: Playlistt) {
        self.id = item.id
        self.name = item.name
        self.smartRules = item.smartRules
        self.limit = item.limit
        self.limitType = item.limitType
        self.limitSortType = item.limitSortType
        self.filters = item.filters
        self.liveUpdating = item.liveUpdating
        self.sortOption = item.sortOption
        self.songs = item.songs
        self.cover = item.cover
        self.matchRules = item.matchRules
        self.urlString = item.urlString
    }
}

struct PlaylistaQuery: EntityQuery {
    let playlistManager = PlaylistManager()
    
    func entities(for identifiers: [PlaylistaEntity.ID]) async throws -> [PlaylistaEntity] {
        var entities: [PlaylistaEntity] = []
        let items = try await playlistManager.fetchItems()
        print(items.map { $0.id.uuidString })
        for item in items {
            entities.append(PlaylistaEntity(item: item))
        }
        
        return entities
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
    case lastPlayed = "last played"
    case mostRecentlyAdded = "most recently added"
    case title = "title"
    case artist = "artist"
    case random = "random"
}

struct PlaylistManager {
    @Environment(PlaylistViewModel.self) var playlistViewModel
    @Environment(PlaylistGeneratorViewModel.self) var playlistGenViewModel
    
    let container: ModelContainer = {
        do {
            let container = try ModelContainer(for: Playlistt.self)
            return container
        } catch {
            fatalError("Failed to create container: \(error)")
        }
    }()
    let descriptor = FetchDescriptor<Playlistt>()
    
    @MainActor
    func fetchItems() async throws -> [Playlistt] {
        let context = container.mainContext
        let items = try context.fetch(descriptor)
        return items
    }
}
