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
    var playlists = [PlaylistModel]()
    var model = PlaylistModel()
    var keyboardHeight: CGFloat = 0
    var playlistName = ""
    var smartRulesActive = true
    var mainZIndex: CGFloat = 1000
    var filterText = ""
    
    var activePlaylist: PlaylistModel? = nil
    var showView = false
    
    func generatePlaylist(filters: SongFilterModel, songs: [Song], limit: Int) -> PlaylistModel {
        var model = PlaylistModel()
        model.filters.append(filters)
        model.smartRules = smartRulesActive
        model.songs = songs
        model.title = playlistName
        model.limit = limit
        
        return model
    }
    
    func createAppleMusicPlaylist(using playlist: PlaylistModel) {
        Task {
            let lib = MusicLibrary.shared
            var listt = try await MusicLibrary.shared.createPlaylist(name: playlist.title)
            for song in playlist.songs {
                try await lib.add(song, to: listt)
            }
        }
    }
    
    func smartFilterSongs(songs: [Song], using filter: SongFilterModel) -> [Song] {
        return songs.filter { filter.matches(song: $0) }
    }
    
    func setActivePlaylist(playlist: PlaylistModel) {
        activePlaylist = playlist
        showView = true
    }
    
    func calculateScrollViewHeight(filterCount: Int) -> CGFloat {
        let filterHeight: CGFloat = 48 + 64
        let spacing: CGFloat = 8
        let totalHeight = CGFloat(filterCount) * filterHeight + CGFloat(filterCount - 1) * spacing
        print(UIScreen.main.bounds.height)
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
