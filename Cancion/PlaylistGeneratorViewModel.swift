//
//  PlaylistGeneratorswift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import Foundation
import SwiftUI
import MusicKit
import SwiftData

@Observable class PlaylistGeneratorViewModel {
    // MARK: - UI State Properties
    var keyboardHeight: CGFloat = 0
    var mainZIndex: CGFloat = 1000
    var activePlaylist: Playlista? = nil
    var showView = false
    var dropdownActive = false
    var showError = false
    
    // MARK: - Generator Properties & Values
    var image: Image?
    
    var playlistName = ""
    var coverData: Data?
    var matchRules: String? = MatchRules.all.rawValue
    var smartRulesActive: Bool = true
    var filters: [String] = []
    var filterModels: [Filter]?
    var filteredDates = [String : String]()
    var limitActive: Bool = true
    var limit: Int?
    var limitType: String?
    var limitSortType: String?
    var liveUpdating: Bool = true
    
    var genError: GenErrors?
    
    // MARK: - Generator Functions
    func fetchMatchingSongIDs(songs: [Song], filters: [Filter]?, matchRules: String?, limit: Int?, limitType: String?, limitSortType: String?) async -> [String] {
        var filteredSongs = songs
        var totalDuration = 0.0
        if let matchRules, smartRulesActive {
            if matchRules == MatchRules.all.rawValue, let filters {
                filteredSongs = songs.filter { song in
                    filters.allSatisfy { filter in
                        let filterDateStr = filteredDates[filter.id.uuidString] ?? filter.date
                        let date = filterDateStr != nil ? Helpers().dateFormatter.date(from: filterDateStr!) : nil
                        return matches(song: song, filter: filter, date: date)
                    }
                }
            } else if matchRules == MatchRules.any.rawValue, let filters {
                filteredSongs = songs.filter { song in
                    filters.contains { filter in
                        let filterDateStr = filteredDates[filter.id.uuidString] ?? filter.date
                        let date = filterDateStr != nil ? Helpers().dateFormatter.date(from: filterDateStr!) : nil
                        return matches(song: song, filter: filter, date: date)
                    }
                }
            }
        }
        
        if let limitSortType, let sort = LimitSortType(rawValue: limitSortType) {
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
                
        if limitActive, let limit {
            var limitedSongs = [Song]()
            switch limitType {
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
    
    @MainActor
    func generatePlaylist(songs: [Song], name: String, cover: Data? = nil, filters: [Filter], limit: Int?, limitType: String?, limitSortType: String?) async -> Playlista? {
        if let cover, let uiImage = UIImage(data: cover) {
            image = Image(uiImage: uiImage)
        }
        let songIDS = await fetchMatchingSongIDs(songs: songs, filters: filters, matchRules: matchRules, limit: limit, limitType: limitType, limitSortType: limitSortType)
        
        guard !songIDS.isEmpty else {
            genError = .emptySongs
            return nil
        }
        
        guard !playlistName.isEmpty else {
            genError = .emptyName
            return nil
        }
        
        do {
            let model = Playlista()
            model.name = name
            model.smartRules = smartRulesActive
            model.songs = songIDS
            model.cover = cover
            model.limit = limit
            model.matchRules = matchRules
            model.liveUpdating = liveUpdating
            model.limitType = limitType
            model.limitSortType = limitSortType
            
            for filter in filters {
                if let filterrDate = filteredDates[filter.id.uuidString] {
                    filter.date = filterrDate
                }
            }
            model.filters = filters.map {$0.id.uuidString}
            return model
        }
    }
    
    func createAppleMusicPlaylist(using playlist: Playlista, songs: [Song]) {
        Task { @MainActor in
            let lib = MusicLibrary.shared
            let listt = try await MusicLibrary.shared.createPlaylist(name: playlist.name)
            withAnimation {
                if let url = listt.url {
                    playlist.urlString = url.absoluteString
                }
            }
            var playlistSongs = [Song]()
            playlistSongs = songs.filter {
                playlist.songs.contains($0.id.rawValue)
            }
            for song in playlistSongs {
                try await lib.add(song, to: listt)
            }
        }
    }
    
    func smartFilterSongs(songs: [Song], using filter: SongFilterModel) -> [Song] {
        return songs.filter { filter.matches(song: $0) }
    }
    
    @MainActor
    func addPlaylist(songs: [Song]) async -> Playlista? {
        let playlista = await addPlaylistToDatabase(songs: songs)
        return playlista
    }
    
    @MainActor
    func addPlaylistToDatabase(songs: [Song]) async -> Playlista? {
        if let model = await generatePlaylist(songs: songs, name: playlistName, cover: coverData, filters: filterModels ?? [], limit: limit, limitType: limitType, limitSortType: limitSortType) {
            filters = []
            
            return model
        }
        showError = true
        return nil
    }
    
    func addModelAndFiltersToDatabase(model: Playlista, modelContext: ModelContext) -> Bool {
        modelContext.insert(model)
        if let playlistFilters = model.filters {
            let matchingFilters = filterModels?.filter {
                playlistFilters.contains($0.id.uuidString)
            }
            if let matchingFilters {
                for filter in matchingFilters {
                    modelContext.insert(filter)
                }
            }
        }
        do {
            try modelContext.save()
            return true
        } catch {
            return false
        }
    }
    
    func calculateScrollViewHeight(filterCount: Int) -> CGFloat {
        let filterHeight: CGFloat = 48 + 64
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(filterCount) * filterHeight + CGFloat(filterCount - 1) * spacing
        return min(totalHeight, UIScreen.main.bounds.height * 0.25)
    }
    
    func trackKeyboardHeight() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (notification) in
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                withAnimation {
                    self.keyboardHeight = keyboardSize.height * 0.65
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation {
                self.keyboardHeight = 0
            }
        }
    }
    
    @MainActor
    func assignViewModelValues(playlist: Playlista, filters: [Filter]) {
        playlistName = playlist.name
        matchRules = playlist.matchRules
        smartRulesActive = playlist.smartRules ?? false
        coverData = playlist.cover
        
        if let playlistFilters = playlist.filters, playlistFilters.isEmpty {
            let matchingFilters = filters.filter {
                playlistFilters.contains($0.id.uuidString)
            }
            self.filters = matchingFilters.map {$0.id.uuidString}
        } else {
            self.filters = playlist.filters ?? []
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
    func resetViewModelValues() {
        activePlaylist = nil
        playlistName = ""
        coverData = nil
        matchRules = MatchRules.all.rawValue
        smartRulesActive = true
        filters = []
        filterModels = []
        liveUpdating = true
        limit = 25
        limitType = LimitType.items.rawValue
        limitSortType = LimitSortType.mostPlayed.rawValue
        filteredDates = [:]
    }
}

enum MatchRules: String {
    case all = "all"
    case any = "any"
}

enum GenErrors: LocalizedError {
    case emptySongs
    case emptySongsInit
    case emptyName
    
    var errorDescription: String? { // Note the change to String?
        switch self {
        case .emptySongs:
            return "Filters do not match any songs in your library."
        case .emptySongsInit:
            return "Your Apple Music library did not return any songs"
        case .emptyName:
            return "Please enter a valid name for your playlist."
        }
    }
}
