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
        
    func filterSongsByText(text: String, songs: inout [Song], using staticSongs: [Song]) {
        if !text.isEmpty {
            songs = Array(staticSongs).filter { $0.title.lowercased().contains(text.lowercased()) || $0.artistName.lowercased().contains(text.lowercased()) && $0.artwork != nil }
        } else {
            songs = Array(staticSongs).filter { $0.artwork != nil }
        }
    }
}
