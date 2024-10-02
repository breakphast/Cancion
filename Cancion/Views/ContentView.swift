//
//  ContentView.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import MusicKit
import SwiftData

struct ContentView: View {
    @Environment(AuthService.self) var authService
    @Environment(PlaylistViewModel.self) var playlistViewModel
    @Query var items: [Playlistt]
    
    var body: some View {
        ZStack {
            @Bindable var authServicee = authService
            Color.gray.opacity(0.1).ignoresSafeArea()
            
            if authService.status != .authorized {
                AuthView(musicAuthorizationStatus: $authServicee.status)
            } else {
                Home()
            }
        }
        .environment(authService)
        .preferredColorScheme(.light)
        .task {
            playlistViewModel.playlistas = items
            print(playlistViewModel.playlistas.count, "ELLO")
        }
    }
}

