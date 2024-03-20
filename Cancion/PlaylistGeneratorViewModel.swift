//
//  PlaylistGeneratorViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/21/24.
//

import Foundation
import SwiftUI
import MusicKit

@Observable class PlaylistGeneratorViewModel {
    // MARK: - UI State Properties
    var keyboardHeight: CGFloat = 0
    var mainZIndex: CGFloat = 1000
    var activePlaylist: Playlista? = nil
    var showView = false
    var dropdownActive = false
    
    // MARK: - Generator Properties & Values
    var image: Image?
    
    var playlistName = ""
    var coverData: Data?
    var matchRules: String? = MatchRules.any.rawValue
    var smartRulesActive: Bool = true
    var filters: [FilterModel] = []
    var filteredDate: Date = Date()
    var limitActive: Bool = true
    var limit: Int? = 25
    var limitType: String? = LimitType.items.rawValue
    var limitSortType: String? = LimitSortType.mostPlayed.rawValue
    var liveUpdating: Bool = true
    
    // MARK: - Generator Functions
    func fetchMatchingSongIDs(songs: [Song], filters: [FilterModel]?, matchRules: String?, limitType: String?) async -> [String] {
        var filteredSongs = songs
        var totalDuration = 0.0
        
        if let matchRules {
            if matchRules == MatchRules.all.rawValue, let filters {
                filteredSongs = songs
                for filter in filters {
                    filteredSongs = filteredSongs.filter { matches(song: $0, filter: filter, date: filteredDate) }
                }
            } else if matchRules == MatchRules.any.rawValue, let filters {
                filteredSongs = songs.filter { song in
                    filters.contains { filter in
                        matches(song: song, filter: filter, date: filteredDate)
                    }
                }
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

    func generatePlaylist(songs: [Song], name: String, cover: Data? = nil) async -> Playlista? {
        if let cover, let uiImage = UIImage(data: cover) {
            image = Image(uiImage: uiImage)
        }
        let songIDS = await fetchMatchingSongIDs(songs: songs, filters: filters, matchRules: matchRules, limitType: limitType)
        do {
            let model = Playlista()
            model.name = name
            model.smartRules = smartRulesActive
            model.filters = filters
            model.songs = songIDS
            model.cover = cover
            model.limit = limit
            model.matchRules = matchRules
            model.liveUpdating = liveUpdating
            model.limitType = limitType
            
            return model
        }
    }
    
//    func createAppleMusicPlaylist(using playlist: Playlista) {
//        Task {
//            let lib = MusicLibrary.shared
//            var listt = try await MusicLibrary.shared.createPlaylist(name: playlist.title)
//            for song in playlist.songs {
//                try await lib.add(song, to: listt)
//            }
//        }
//    }
    
    func smartFilterSongs(songs: [Song], using filter: SongFilterModel) -> [Song] {
        return songs.filter { filter.matches(song: $0) }
    }
    
    func setActivePlaylist(playlist: Playlista) {
        activePlaylist = playlist
        showView = true
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
    func assignViewModelValues(playlist: Playlista) {
        playlistName = playlist.name
        matchRules = playlist.matchRules
        smartRulesActive = playlist.smartRules ?? false
        filters = playlist.filters ?? []
        liveUpdating = playlist.liveUpdating
        limit = playlist.limit
        limitType = playlist.limitType
        limitSortType = playlist.limitSortType
    }
    
    @MainActor
    func resetViewModelValues() {
        playlistName = ""
        coverData = nil
        matchRules = MatchRules.any.rawValue
        smartRulesActive = true
        filters = []
        liveUpdating = true
        limit = 25
        limitType = LimitType.items.rawValue
        limitSortType = LimitSortType.mostPlayed.rawValue
    }
}

enum MatchRules: String {
    case all = "all"
    case any = "any"
}
