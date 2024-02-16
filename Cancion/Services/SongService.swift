//
//  SongService.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

@Observable class SongService {
    var songID = "1712222236"
    var activeSong: Song?
    var searchResultSongs = MusicItemCollection<Song>()
    var searchTerm = ""
    var searchActive = false
    
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
                var searchRequest = MusicCatalogSearchRequest(term: searchTerm, types: [Song.self])
                searchRequest.limit = 5
                let searchResponse = try await searchRequest.response()
                
                // Update the user interface with the search response.
                await self.apply(searchResponse, for: searchTerm)
            } catch {
                print("Search request failed with error: \(error).")
                await self.reset()
            }
        }
    }

    @MainActor
    private func apply(_ searchResponse: MusicCatalogSearchResponse, for searchTerm: String) {
        if self.searchTerm == searchTerm {
            self.searchResultSongs = searchResponse.songs
        }
    }
    
    
    @MainActor
    private func reset() {
        self.searchResultSongs = []
    }
}
