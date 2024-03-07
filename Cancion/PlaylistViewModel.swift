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
        
    func filterSongsByText(text: String, songs: inout [Song], songItems: MusicItemCollection<Song>, using staticSongs: [Song]) {
        if !text.isEmpty {
            songs = Array(songItems).filter { $0.title.contains(text) || $0.artistName.contains(text) && $0.artwork != nil }
        } else {
            songs = Array(songItems).filter { $0.artwork != nil }
        }
    }
}
