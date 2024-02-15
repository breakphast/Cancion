//
//  SearchView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI

struct SearchView: View {
    @Environment(SongService.self) var songService
    @State private var song: String = ""
    
    var body: some View {
        @Bindable var service = songService
        
        NavigationView {
            if !songService.searchResultSongs.isEmpty {
                List(songService.searchResultSongs) { song in
                    Text(song.title)
                        .onTapGesture {
                            Task {
                                try await songService.fetchSong(id: song.id.rawValue)
                                songService.searchActive = false
                            }
                        }
                }
            } else {
                Text("No favorite song set")
                    .font(.title.bold())
            }
        }
        .searchable(text: $service.searchTerm, prompt: "Albums")
    }
}

#Preview {
    SearchView()
        .environment(SongService())
}
