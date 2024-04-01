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
    
    func fetchMatchingSongIDs(playlist: Playlista, dates: [String:String]?, filterrs: [Filter]?) async -> [String] {
        var filteredSongs = ogSongs
        var totalDuration = 0.0
        if let rules = playlist.matchRules, let rulesActive = playlist.smartRules, rulesActive {
            if rules == MatchRules.all.rawValue, let filterrs {
                filteredSongs = ogSongs
                for filter in filterrs {
                    if let dates, let filterrDate = dates[filter.id.uuidString] {
                        let datedate = Helpers().dateFormatter.date(from: filterrDate)
                        filteredSongs = filteredSongs.filter { matches(song: $0, filter: filter, date: datedate) }
                    } else {
                        filteredSongs = filteredSongs.filter { matches(song: $0, filter: filter, date: nil) }
                    }
                }
            } else if rules == MatchRules.any.rawValue, let filterrs {
                filteredSongs = ogSongs.filter { song in
                    filterrs.contains { filter in
                        matches(song: song, filter: filter, date: filter.date == nil ? nil : Helpers().dateFormatter.date(from: filter.date!))
                    }
                }
            }
        }
        
        if let limitSortType = playlist.limitSortType, let sort = LimitSortType(rawValue: limitSortType) {
            switch sort {
            case .mostPlayed:
                filteredSongs.sort { $0.playCount ?? 0 > $1.playCount ?? 0 }
            case .lastPlayed:
                filteredSongs = filteredSongs.filter { $0.lastPlayedDate != nil }.sorted { $0.lastPlayedDate! > $1.lastPlayedDate! }
            case .mostRecentlyAdded:
                filteredSongs = filteredSongs.filter { $0.libraryAddedDate != nil }.sorted { $0.libraryAddedDate! > $1.libraryAddedDate! }
            case .title:
                filteredSongs.sort { $0.title.lowercased() < $1.title.lowercased() }
            case .artist:
                filteredSongs.sort { $0.artistName.lowercased() < $1.artistName.lowercased() }
            case .random:
                filteredSongs.shuffle()
            }
        }
                
        if let limit = playlist.limit {
            var limitedSongs = [Song]()
            switch playlist.limitType {
            case LimitType.items.rawValue:
                limitedSongs = Array(filteredSongs.prefix(limit))
            case LimitType.hours.rawValue:
                let maxMinutes = limit * 60
                for song in filteredSongs {
                    if let duration = song.duration {
                        if (totalDuration + (duration / 60)) <= Double(maxMinutes) {
                            limitedSongs.append(song)
                            totalDuration += (duration / 60)
                        } else {
                            break
                        }
                    }
                }
            case LimitType.minutes.rawValue:
                let maxMinutes = limit
                for song in filteredSongs {
                    if let duration = song.duration {
                        if (totalDuration + (duration / 60)) <= Double(maxMinutes) {
                            limitedSongs.append(song)
                            totalDuration += (duration / 60)
                        } else {
                            break
                        }
                    }
                }
            default:
                break
            }
            
            return limitedSongs.map { $0.id.rawValue }
        }
        
        return filteredSongs.map { $0.id.rawValue }
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
