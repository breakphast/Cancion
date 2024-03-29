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
    var ogSongs = [Song]()
    var sortedSongs = [Song]()
    var limitFilter = LimitFilter(active: false, limit: "25", limitTypeSelection: "items", limitSortSelection: "most played", condition: .contains, value: "")
    var filters: [any SongFilterModel] = [TitleFilter(value: "", condition: .contains)]
    var fetchLimit: Int = 1500
    var ogPlaylistSongs = [Song]()
    var playlistSongs = [Song]()
    var emptyLibrary = false
    
    public func smartFilterSongs(limit: Int, by sortProperty: LibrarySongSortProperties, artist: String? = nil) async throws {
        var libraryRequest = MusicLibraryRequest<Song>()
        
        switch sortProperty {
        case .playCount:
            libraryRequest.sort(by: \.playCount, ascending: false)
        case .artistName:
            libraryRequest.sort(by: \.artistName, ascending: true)
        }
        
        if let artist {
            libraryRequest.filter(matching: \.artistName, equalTo: artist)
        }
        
        do {
            let libraryResponse = try await libraryRequest.response()
            await self.apply(libraryResponse)
        } catch {
            emptyLibrary = true
        }
    }
    
    public enum LibrarySongSortProperties: String {
        case playCount
        case artistName
    }
    
    @MainActor
    private func apply(_ libraryResponse: MusicLibraryResponse<Song>) {
        self.searchResultSongs = libraryResponse.items
        self.ogSongs = Array(libraryResponse.items).filter { $0.artwork != nil }.filter  {$0.playParameters != nil}
        self.sortedSongs = Array(libraryResponse.items).filter { $0.artwork != nil }.filter  {$0.playParameters != nil}
        self.randomSongs = self.sortedSongs.filter { $0.artwork != nil }.shuffled()
    }
}
