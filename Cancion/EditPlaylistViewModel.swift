//
//  EditPlaylistViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/29/24.
//

import SwiftUI
import MusicKit
import SwiftData
import PhotosUI

@Observable class EditPlaylistViewModel {
    var playlistName = ""
    var item: PhotosPickerItem?
    var showError = false
    var coverImage: Image?
    var playlist: Playlistt?
    var playlistFilters: [Filter]?
    var filteredDates: [String : String] = [:]
    var genError: GenErrors?
    var playlistSongSort: LimitSortType?
    var coverData: Data?
    var smartRulesActive: Bool = true
    var dropdownActive = false
    var matchRules: String?
    var liveUpdating: Bool?
    
    var limit: Int?
    var limitType: String?
    var limitSortType: String?
    
    @MainActor
    func assignViewModelValues(playlist: Playlistt, filters: [Filter]) {
        playlistName = playlist.name
        matchRules = playlist.matchRules
        smartRulesActive = playlist.smartRules ?? false
        coverData = playlist.cover
        if let playlistFilterStrings = playlist.filters {
            let matchingFilters = filters.filter {
                playlistFilterStrings.contains($0.id.uuidString)
            }
            self.playlistFilters = matchingFilters
        }
        
        liveUpdating = playlist.liveUpdating
        limit = playlist.limit
        limitType = playlist.limitType
        limitSortType = playlist.limitSortType
        for filter in filters {
            if let filterDateString = filter.date {
                filteredDates[filter.id.uuidString] = filterDateString
            }
        }
    }
    
    @MainActor
    func handleEditPlaylist(songService: SongService, playlist: Playlistt, filters: [Filter]) async -> Bool {
        let songIDs = await songService.fetchMatchingSongIDs(dates: filteredDates, filterrs: filters, limit: limit, limitType: limitType, limitSortType: limitSortType, matchRules: matchRules, smartRules: smartRulesActive)
        let filterStrings = filters.map {$0.id.uuidString}
        guard !songIDs.isEmpty else {
            genError = .emptySongs
            showError = true
            return false
        }
        
        if playlistName != playlist.name && !playlistName.isEmpty {
            playlist.name = playlistName
        } else if playlist.name.isEmpty {
            genError = .emptyName
            return false
        }
        
        if !songIDs.isEmpty && songIDs != playlist.songs {
            playlist.songs = songIDs
            songService.playlistSongs = Array(songService.ogSongs).filter {
                songIDs.contains($0.id.rawValue)
            }
        }
        if let cover = coverData {
            playlist.cover = nil
            playlist.cover = cover
        }
        if let limit, limit != playlist.limit {
            playlist.limit = limit
        }
        if let limitType = limitType, limitType != playlist.limitType {
            playlist.limitType = limitType
        }
        if filterStrings != playlist.filters {
            playlist.filters = []
            playlist.filters = filterStrings
        }
        if let playlistFilters = playlist.filters {
            let matchingFilters = filters.filter {
                playlistFilters.contains($0.id.uuidString)
            }
            for filter in matchingFilters {
                if let filterrDate = filteredDates[filter.id.uuidString] {
                    filter.date = filterrDate
                }
            }
        }
        
        if matchRules != playlist.matchRules {
            playlist.matchRules = matchRules
        }
        if liveUpdating != playlist.liveUpdating {
            playlist.liveUpdating = liveUpdating ?? false
        }
        if smartRulesActive != playlist.smartRules {
            playlist.smartRules = smartRulesActive
        }
        if let limitSortType, limitSortType != playlist.limitSortType {
            switch LimitSortType(rawValue: limitSortType) {
            case .artist:
                playlistSongSort = .artist
            case .mostPlayed:
                playlistSongSort = .mostPlayed
            case .lastPlayed:
                playlistSongSort = .lastPlayed
            case .mostRecentlyAdded:
                playlistSongSort = .mostRecentlyAdded
            case .title:
                playlistSongSort = .title
            default:
                playlistSongSort = .mostPlayed
            }
            playlist.limitSortType = playlistSongSort?.rawValue
        }
        return true
    }
    
    @MainActor
    func resetViewModelValues() {
        playlistName = ""
        coverData = nil
        smartRulesActive = true
        filteredDates = [:]
    }
}
