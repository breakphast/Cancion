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
    static let options = ["Artist", "Title", "Play Count"]
    static let conditionals = ["is", "contains", "does not contain"]
    var keyboardHeight: CGFloat = 0
    var playlistName = ""
    var smartRulesActive = true
    var mainZIndex: CGFloat = 1000
    var filterText = ""
    var activeFilters: [FilterModel] = [FilterModel()]
    var activePlaylist: Playlista? = nil
    var showView = false
    var matchRules: MatchRules = .any
    
    func fetchMatchingSongIDs(songs: [Song], filters: [FilterModel], matchRules: MatchRules) async -> [String] {
        var filteredSongs = [Song]()
        
        if matchRules == .all {
            for filter in filters {
                filteredSongs = filteredSongs.filter { matches(song: $0, filter: filter) }
            }
        } else if matchRules == .any {
            filteredSongs = songs.filter { song in
                filters.contains { filter in
                    matches(song: song, filter: filter)
                }
            }
        }
        
        return filteredSongs.map { $0.id.rawValue }
    }
    
    func generatePlaylist(songs: [Song]) async -> Playlista? {
        let songIDS = await fetchMatchingSongIDs(songs: songs, filters: activeFilters, matchRules: matchRules)
        do {
            let model = Playlista()
            model.title = playlistName
            model.smartRules = smartRulesActive
            model.filters = activeFilters
            model.songs = songIDS
            
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
}

enum MatchRules: String {
    case all = "all"
    case any = "any"
}
