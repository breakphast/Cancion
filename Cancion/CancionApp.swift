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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(songListViewModel)
                .environment(homeViewModel)
        }
        .modelContainer(for: Playlista.self)
    }
}
