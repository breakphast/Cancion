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
    @State var playlistViewModel = PlaylistViewModel()
    @State var authService = AuthService.shared
    @State var songService = SongService()
    @State private var backgroundTimestamp: Date?
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(songListViewModel)
                .environment(homeViewModel)
                .environment(authService)
                .environment(songService)
                .environment(playlistViewModel)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                    // App is going to the background, store the current time
                    backgroundTimestamp = Date()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // App is coming back to the foreground
                    if let backgroundTime = backgroundTimestamp {
                        let currentTime = Date()
                        let timeDifference = currentTime.timeIntervalSince(backgroundTime)
                        
                        if timeDifference > 3600 { // More than an hour
                            // Perform your specific action here
                            // For example, refreshing app data
                            homeViewModel.isPlaybackQueueSet = false
                        }
                    }
                }
        }
        .modelContainer(for: [Playlista.self, Filter.self])
    }
}
