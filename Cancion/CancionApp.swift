//
//  CancionApp.swift
//  Cancion
//
//  Created by Desmond Fitch on 2/15/24.
//

import SwiftUI

@main
struct CancionApp: App {
    @State var songListViewModel = SongListViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(songListViewModel)
        }
    }
}
