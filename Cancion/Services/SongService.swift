//
//  SongService.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

@Observable class SongService {
    var songID = "1684365931"
    
    var activeSong: Song?
    var searchResultSongs = MusicItemCollection<Song>()
    var sortedSongs = [Song]()
    var searchTerm = ""
    var searchActive = false
    
    init() {
        Task {
            try await randommmm()
        }
    }
    
    public func fetchSong(id: String) async throws {
        do {
            let songRequest = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(rawValue: id))
            let songResponse = try await songRequest.response()
            if let songResult = songResponse.items.first {
                self.activeSong = songResult
            }
        } catch {
            print("Failed.")
        }
    }
    
    public func requestUpdatedSearchResults(for searchTerm: String) async throws {
        if searchTerm.isEmpty {
            await self.reset()
        } else {
            do {
                var searchRequest = MusicLibrarySearchRequest(term: searchTerm, types: [Song.self])
                searchRequest.limit = 25
                let searchResponse = try await searchRequest.response()
                
                // Update the user interface with the search response.
                await self.apply(searchResponse, for: searchTerm)
            } catch {
                print("Search request failed with error: \(error).")
                await self.reset()
            }
        }
    }
    
    public func randommmm() async throws {
        var libraryRequest = MusicLibraryRequest<Song>()
        libraryRequest.sort(by: \.playCount, ascending: false)
        libraryRequest.limit = 50
        let libraryResponse = try await libraryRequest.response()
        
        self.searchResultSongs = libraryResponse.items
        self.sortedSongs = libraryResponse.items.sorted(by: { $0.artistName.lowercased() > $1.artistName.lowercased() })
        for song in self.searchResultSongs {
            print(song.title, song.playCount ?? "nil")
        }
    }

    @MainActor
    private func apply(_ searchResponse: MusicLibrarySearchResponse, for searchTerm: String) {
        if self.searchTerm == searchTerm {
            self.searchResultSongs = searchResponse.songs
        }
    }
    
    
    @MainActor
    private func reset() {
        self.searchResultSongs = []
    }
}
