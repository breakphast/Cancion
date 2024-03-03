//
//  CancionApp.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI
import SwiftData

@main
struct CancionApp: App {
    @State var songListViewModel = SongListViewModel()
    @State var homeViewModel = HomeViewModel()
    @State var authService = AuthService.shared
    @State var songService = SongService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(songListViewModel)
                .environment(homeViewModel)
                .environment(authService)
                .environment(songService)
        }
        .modelContainer(for: Playlista.self)
    }
}
