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
    
    func togglePlayCountSort(songs: inout [Song]) async {
        if playCountAscending {
            songs = songs.sorted { $0.playCount ?? 0 > $1.playCount ?? 0 }
        } else {
            songs = songs.sorted { $1.playCount ?? 0 > $0.playCount ?? 0 }
        }
        withAnimation {
            playCountAscending.toggle()
        }
    }
    
    func filterSongsByText(text: String, songs: inout [Song], songItems: MusicItemCollection<Song>, using staticSongs: [Song]) {
        if !text.isEmpty {
            songs = Array(songItems).filter { $0.title.contains(text) || $0.artistName.contains(text) && $0.artwork != nil }
        } else {
            songs = Array(songItems).filter { $0.artwork != nil }
        }
    }
}
