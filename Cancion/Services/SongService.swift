//
//  SongService.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

@Observable class SongService {
    var randomSongs = [Song]()
    var searchResultSongs = MusicItemCollection<Song>()
    var sortedSongs = [Song]()
    var limitFilter = LimitFilter(active: false, limit: 25, limitTypeSelection: "items", limitSortSelection: "most played", condition: .contains, value: "")
    var filters: [any SongFilterModel] = [ArtistFilter(value: "", condition: .equals)]
    var fetchLimit: Int = 100
    
    init() {
        Task {
            try await smartFilterSongs(limit: fetchLimit, by: .playCount)
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
        self.randomSongs = Array(libraryResponse.items).shuffled()
    }
}
