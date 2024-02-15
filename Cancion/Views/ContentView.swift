//
//  ContentView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit

struct ContentView: View {
    @State private var authService = AuthService.shared
    @State private var songService = SongService()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            if authService.status != .authorized {
                AuthView(musicAuthorizationStatus: $authService.status)
            } else if songService.searchActive {
                SearchView()
                    .environment(songService)
                    .onChange(of: songService.searchTerm) { _, term in
                        Task {
                            try await songService.requestUpdatedSearchResults(for: term)
                        }
                    }
            } else {
                if let song = songService.activeSong {
                    if let _ = song.artwork {
                        CancionView(cancion: song)
                            .environment(songService)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
