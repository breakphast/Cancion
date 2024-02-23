//
//  SongService.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

@Observable class SongService {
    var activeSong: Song?
    var searchResultSongs = MusicItemCollection<Song>()
    var sortedSongs = [Song]()
    
    init() {
        Task {
            try await smartFilterSongs(limit: 100, by: .playCount)
            try await fetchSong()
        }
    }
    
    public func fetchSong() async throws {
        do {
            if let song = sortedSongs.randomElement() {
                activeSong = song
            }
        }
    }
    
    public enum LibrarySongSortProperties: String {
        case playCount
        case artistName
    }

    public func smartFilterSongs(limit: Int, by sortProperty: LibrarySongSortProperties, artist: String? = nil) async throws {
        var libraryRequest = MusicLibraryRequest<Song>()
        
        switch sortProperty {
        case .playCount:
            libraryRequest.sort(by: \.playCount, ascending: false)
        case .artistName:
            libraryRequest.sort(by: \.artistName, ascending: true)
        }
        
        libraryRequest.limit = limit
        if let artist {
            libraryRequest.filter(matching: \.artistName, equalTo: artist)
        }
        
        let libraryResponse = try await libraryRequest.response()
        await self.apply(libraryResponse)
    }
    
    @MainActor
    private func apply(_ libraryResponse: MusicLibraryResponse<Song>) {
        self.searchResultSongs = libraryResponse.items
        self.sortedSongs = Array(libraryResponse.items)
    }
}
