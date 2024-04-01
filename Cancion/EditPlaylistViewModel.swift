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
    var playlist: Playlista?
//    var filters: [FilterModel] = []
    var filteredDates: [String : String]?
    var genError: GenErrors?
    var playlistSongSort: LimitSortType?
    var coverData: Data?
    var smartRulesActive: Bool = true
    var dropdownActive = false
    
    func handleEditPlaylist(songService: SongService, playlist: Playlista, filters: [FilterModel]) async -> Bool {
        let songIDs = await songService.fetchMatchingSongIDs(playlist: playlist, dates: filteredDates, filters: filters)
        
        guard !songIDs.isEmpty else {
            genError = .emptySongs
            showError = true
            return false
        }
//        if playlistName.isEmpty && playlist.name.isEmpty {
//            genError = .emptyName
//            return false
//        }
//        guard !playlistName.isEmpty && !playlist.name.isEmpty else {
//            print(playlist.name)
//            genError = .emptyName
//            return false
//        }
        
        if !songIDs.isEmpty && songIDs != playlist.songs {
            playlist.songs = songIDs
            songService.playlistSongs = Array(songService.ogSongs).filter {
                songIDs.contains($0.id.rawValue)
            }
        }
        if playlistName != playlist.name && !playlistName.isEmpty {
            playlist.name = playlistName
        }
        if let cover = coverData {
            playlist.cover = cover
        }
        if playlist.limit != playlist.limit {
            playlist.limit = playlist.limit
        }
        if playlist.limitType != playlist.limitType {
            playlist.limitType = playlist.limitType
        }
        if filters != playlist.filters {
            playlist.filters = []
            playlist.filters = filters
        }
        if let playlistFilters = playlist.filters {
            for filter in playlistFilters {
                if let filterrDate = filteredDates?[filter.id.uuidString] {
                    filter.date = filterrDate
                }
            }
        }
        
        if playlist.matchRules != playlist.matchRules {
            playlist.matchRules = playlist.matchRules
        }
        if playlist.liveUpdating != playlist.liveUpdating {
            playlist.liveUpdating = playlist.liveUpdating
        }
        if smartRulesActive != playlist.smartRules {
            playlist.smartRules = smartRulesActive
        }
        if playlist.limitSortType != playlist.limitSortType {
            playlist.limitSortType = playlist.limitSortType
            if let limitSortType = playlist.limitSortType {
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
            }
        }
        return true
//                playlist.resetViewModelValues()
        
//                dismiss()
//                homeViewModel.generatorActive = false
    }
    
    @MainActor
    func resetViewModelValues() {
        playlistName = ""
        coverData = nil
        smartRulesActive = true
        filteredDates = [:]
    }
    
    @MainActor
    func addPlaylistToDatabase(playlist: Playlista, modelContext: ModelContext) async -> Bool {
        modelContext.insert(playlist)
        return true
    }
}
