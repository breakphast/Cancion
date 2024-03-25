//
//  PlaylistViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 3/7/24.
//

import Foundation
import SwiftUI
import MusicKit

@Observable class PlaylistViewModel {
    var playCountAscending = false
    var searchActive = false
    var selectedFilter: String? = nil
    var songSort: PlaylistSongSortOption = .plays
        
    func filterSongsByText(text: String, songs: inout [Song], using staticSongs: [Song]){
        if !text.isEmpty {
            songs = staticSongs.filter { $0.title.lowercased().contains(text.lowercased()) || $0.artistName.lowercased().contains(text.lowercased()) && $0.artwork != nil }
        } else {
            songs = staticSongs.filter { $0.artwork != nil }
        }
    }
}
