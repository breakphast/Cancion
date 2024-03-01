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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(songListViewModel)
        }
        .modelContainer(for: Playlista.self)
    }
}
