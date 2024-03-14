//
//  SongListViewModel.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/22/24.
//

import Foundation
import SwiftUI
import MusicKit

@Observable class SongListViewModel {
    var playCountAscending = false
    var searchActive = false
    var selectedFilter: String? = nil
        
    func filterSongsByText(text: String, songs: inout [Song], songItems: MusicItemCollection<Song>, using staticSongs: [Song]) {
        if !text.isEmpty {
            songs = Array(songItems).filter { $0.title.lowercased().contains(text) || $0.artistName.lowercased().contains(text) && $0.artwork != nil }
        } else {
            songs = Array(songItems).filter { $0.artwork != nil }
        }
    }
}
