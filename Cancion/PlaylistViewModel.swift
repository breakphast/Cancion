//
//  PlaylistViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/7/24.
//

import Foundation
import SwiftUI
import MusicKit

@Observable class PlaylistViewModel {
    var playCountAscending = false
    var searchActive = false
    var selectedFilter: String? = nil
    var songSort: LimitSortType = .artist
    var sortTitle: String = ""
    var cover: Data?
    
    var playlistSongs: [Song] = []
    var ogPlaylistSongs = [Song]()
    var playlist: Playlista?
        
    func filterSongsByText(text: String, songs: inout [Song], using staticSongs: [Song]){
        if !text.isEmpty {
            songs = staticSongs.filter { $0.title.lowercased().contains(text.lowercased()) || $0.artistName.lowercased().contains(text.lowercased()) && $0.artwork != nil }
        } else {
            songs = staticSongs.filter { $0.artwork != nil }
        }
    }
    
    func assignSongs(sortType: LimitSortType) {
        switch playCountAscending {
        case false:
            switch sortType {
            case .mostRecentlyAdded:
                playlistSongs = playlistSongs.filter { $0.libraryAddedDate != nil }.sorted { $0.libraryAddedDate! > $1.libraryAddedDate! }
            case .mostPlayed:
                playlistSongs = playlistSongs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
            case .lastPlayed:
                playlistSongs = playlistSongs.filter { $0.lastPlayedDate != nil }.sorted { $0.lastPlayedDate! > $1.lastPlayedDate! }
            case .title:
                playlistSongs = playlistSongs.sorted { $0.title.lowercased() < $1.title.lowercased()}
            case .artist:
                playlistSongs = playlistSongs.sorted { $0.artistName.lowercased() < $1.artistName.lowercased()}
            default:
                playlistSongs = playlistSongs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
            }
        case true:
            switch sortType {
            case .mostRecentlyAdded:
                playlistSongs = playlistSongs.filter { $0.libraryAddedDate != nil }.sorted { $0.libraryAddedDate! < $1.libraryAddedDate! }
            case .mostPlayed:
                playlistSongs = playlistSongs.sorted { $0.playCount ?? 0 < $1.playCount ?? 0 }
            case .lastPlayed:
                playlistSongs = playlistSongs.filter { $0.lastPlayedDate != nil }.sorted { $0.lastPlayedDate! < $1.lastPlayedDate! }
            case .title:
                playlistSongs = playlistSongs.sorted { $0.title.lowercased() > $1.title.lowercased()}
            case .artist:
                playlistSongs = playlistSongs.sorted { $0.artistName.lowercased() > $1.artistName.lowercased()}
            default:
                playlistSongs = playlistSongs.sorted { $0.playCount ?? 0 < $1.playCount ?? 0 }
            }
        }
    }
    
    func assignSortTitles(sortType: LimitSortType) {
        songSort = sortType
        switch songSort {
        case .artist:
            sortTitle = PlaylistSongSortOption.artist.rawValue.uppercased()
        case .mostPlayed:
            sortTitle = PlaylistSongSortOption.plays.rawValue.uppercased()
        case .lastPlayed:
            sortTitle = PlaylistSongSortOption.lastPlayed.rawValue.uppercased()
        case .mostRecentlyAdded:
            sortTitle = PlaylistSongSortOption.dateAdded.rawValue.uppercased()
        case .title:
            sortTitle = PlaylistSongSortOption.title.rawValue.uppercased()
        default:
            sortTitle = PlaylistSongSortOption.plays.rawValue.uppercased()
        }
    }
    
    func setPlaylistSongs(songs: [Song]) async -> Bool {
        let matchingSongs = Array(songs).filter {
            playlist?.songs.contains($0.id.rawValue) ?? false
        }
        
        playlistSongs = matchingSongs
        ogPlaylistSongs = matchingSongs
        
        if let limitSortType = playlist?.limitSortType, let sortOption = LimitSortType(rawValue: limitSortType) {
            songSort = sortOption
        }
        return !playlistSongs.isEmpty
    }
    
    @MainActor
    func resetPlaylistViewModelValues() {
        playCountAscending = false
        searchActive = false
        selectedFilter = nil
        songSort = .artist
        sortTitle = ""
        
        playlistSongs = []
        ogPlaylistSongs = [Song]()
        playlist = nil
    }
}
