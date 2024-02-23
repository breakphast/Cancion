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
            } else if let activeSong = songService.activeSong {
                Home(cancion: activeSong)
                    .environment(songService)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthService.shared)
        .environment(SongService())
}
